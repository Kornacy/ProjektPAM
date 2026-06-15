import 'dart:async';
import 'dart:convert';

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/offline/connectivity_service.dart';
import 'package:city_issues/services/offline/local_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

enum PendingOperationType {
  upvote,
  removeUpvote,
  addComment,
}

class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final int id;
  final PendingOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}

class OfflineSyncService extends ChangeNotifier {
  OfflineSyncService._({
    LocalDatabase? database,
    ConnectivityService? connectivity,
    AuthService? authService,
  })  : _database = database ?? LocalDatabase.instance,
        _connectivity = connectivity ?? ConnectivityService.instance,
        _authService = authService ?? AuthService.instance;

  static final OfflineSyncService instance = OfflineSyncService._();

  @visibleForTesting
  factory OfflineSyncService.forTesting({
    LocalDatabase? database,
    ConnectivityService? connectivity,
    AuthService? authService,
  }) =>
      OfflineSyncService._(
        database: database,
        connectivity: connectivity,
        authService: authService,
      );

  final LocalDatabase _database;
  final ConnectivityService _connectivity;
  final AuthService _authService;

  bool _syncInProgress = false;

  Future<void> enqueue({
    required PendingOperationType type,
    required Map<String, dynamic> payload,
  }) async {
    if (!_database.isAvailable) return;

    final db = _database.requireDb();
    await db.insert(
      'pending_operations',
      {
        'type': type.name,
        'payload': jsonEncode(payload),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
    notifyListeners();
  }

  Future<int> pendingCount() async {
    if (!_database.isAvailable) return 0;

    final db = _database.requireDb();
    final result =
        await db.rawQuery('SELECT COUNT(*) AS count FROM pending_operations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<PendingOperation>> pendingOperations() async {
    if (!_database.isAvailable) return const [];

    final db = _database.requireDb();
    final rows = await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );

    return rows.map((row) {
      final payload = jsonDecode(row['payload']! as String);
      return PendingOperation(
        id: row['id']! as int,
        type: PendingOperationType.values.byName(row['type']! as String),
        payload: Map<String, dynamic>.from(payload as Map),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      );
    }).toList();
  }

  Future<void> syncPendingOperations() async {
    if (!_connectivity.isOnline || _syncInProgress || !_database.isAvailable) {
      return;
    }
    if (!_authService.isSignedIn) return;

    _syncInProgress = true;
    try {
      final pending = await pendingOperations();
      for (final operation in pending) {
        try {
          await _executeOperation(operation);
          await _deleteOperation(operation.id);
        } catch (e, stack) {
          debugPrint(
            'OfflineSyncService: failed ${operation.type.name} (#${operation.id}): $e\n$stack',
          );
          break;
        }
      }
    } finally {
      _syncInProgress = false;
      notifyListeners();
    }
  }

  Future<void> _executeOperation(PendingOperation operation) async {
    switch (operation.type) {
      case PendingOperationType.upvote:
        final reportId = operation.payload['reportId'] as String;
        await DefaultConnector.instance
            .upvoteReport(reportId: reportId)
            .execute();
      case PendingOperationType.removeUpvote:
        final reportId = operation.payload['reportId'] as String;
        await DefaultConnector.instance
            .removeUpvote(reportId: reportId)
            .execute();
      case PendingOperationType.addComment:
        final reportId = operation.payload['reportId'] as String;
        final content = operation.payload['content'] as String;
        await DefaultConnector.instance
            .addComment(reportId: reportId, content: content)
            .execute();
    }
  }

  Future<void> _deleteOperation(int id) async {
    final db = _database.requireDb();
    await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

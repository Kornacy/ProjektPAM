import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/offline/connectivity_service.dart';
import 'package:city_issues/services/offline/offline_cache_store.dart';
import 'package:city_issues/services/offline/offline_exception.dart';
import 'package:city_issues/services/offline/offline_sync_service.dart';

class CommentService {
  CommentService._({
    FirebaseAuth? firebaseAuth,
    OfflineCacheStore? cacheStore,
    ConnectivityService? connectivity,
    OfflineSyncService? offlineSync,
  })  : _firebaseAuthOverride = firebaseAuth,
        _cacheStore = cacheStore ?? OfflineCacheStore.instance,
        _connectivity = connectivity ?? ConnectivityService.instance,
        _offlineSync = offlineSync ?? OfflineSyncService.instance;

  static final CommentService instance = CommentService._();

  static const offlinePendingId = '__offline_pending__';

  @visibleForTesting
  factory CommentService.forTesting({
    FirebaseAuth? firebaseAuth,
    OfflineCacheStore? cacheStore,
    ConnectivityService? connectivity,
    OfflineSyncService? offlineSync,
  }) =>
      CommentService._(
        firebaseAuth: firebaseAuth,
        cacheStore: cacheStore,
        connectivity: connectivity,
        offlineSync: offlineSync,
      );

  final FirebaseAuth? _firebaseAuthOverride;
  final OfflineCacheStore _cacheStore;
  final ConnectivityService _connectivity;
  final OfflineSyncService _offlineSync;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  Future<List<GetReportCommentsComments>> getComments(String reportId) async {
    try {
      final result = await DefaultConnector.instance
          .getReportComments(reportId: reportId)
          .execute();
      final comments = result.data.comments;
      await _cacheStore.saveComments(reportId, comments);
      return comments;
    } catch (e) {
      final cached = await _cacheStore.loadComments(reportId);
      if (cached != null) return cached;
      if (!_connectivity.isOnline) {
        throw OfflineException(
          'Brak połączenia z internetem i zapisanych komentarzy.',
        );
      }
      rethrow;
    }
  }

  Future<String> addComment({
    required String reportId,
    required String content,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby dodać komentarz.');
    }
    if (content.trim().isEmpty) {
      throw Exception('Komentarz nie może być pusty.');
    }

    if (!_connectivity.isOnline) {
      await _offlineSync.enqueue(
        type: PendingOperationType.addComment,
        payload: {
          'reportId': reportId,
          'content': content.trim(),
        },
      );
      return offlinePendingId;
    }

    final result = await DefaultConnector.instance
        .addComment(reportId: reportId, content: content.trim())
        .execute();

    return result.data.comment_insert.id;
  }

  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby edytować komentarz.');
    }
    if (content.trim().isEmpty) {
      throw Exception('Komentarz nie może być pusty.');
    }
    if (!_connectivity.isOnline) {
      throw OfflineException('Edycja komentarza wymaga połączenia z internetem.');
    }

    await DefaultConnector.instance
        .editComment(commentId: commentId, content: content.trim())
        .execute();
  }

  Future<void> deleteComment(String commentId) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby usunąć komentarz.');
    }
    if (!_connectivity.isOnline) {
      throw OfflineException('Usunięcie komentarza wymaga połączenia z internetem.');
    }

    await DefaultConnector.instance
        .deleteComment(commentId: commentId)
        .execute();
  }

  bool isOwner(GetReportCommentsComments comment) {
    return comment.user.id == _currentUserId;
  }
}

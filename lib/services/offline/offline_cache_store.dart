import 'dart:convert';

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/offline/local_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCacheStore {
  OfflineCacheStore._({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  static final OfflineCacheStore instance = OfflineCacheStore._();

  @visibleForTesting
  factory OfflineCacheStore.forTesting({LocalDatabase? database}) =>
      OfflineCacheStore._(database: database);

  final LocalDatabase _database;

  static const reportsKey = 'reports_all';
  static const categoriesKey = 'categories';

  static String myReportsKey(String userId) => 'my_reports_$userId';

  static String commentsKey(String reportId) => 'comments_$reportId';

  Future<void> saveJson(String key, List<Map<String, dynamic>> items) async {
    if (!_database.isAvailable) return;

    final db = _database.requireDb();
    await db.insert(
      'cache_entries',
      {
        'cache_key': key,
        'json': jsonEncode(items),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>?> loadJson(String key) async {
    if (!_database.isAvailable) return null;

    final db = _database.requireDb();
    final rows = await db.query(
      'cache_entries',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final decoded = jsonDecode(rows.first['json']! as String);
    if (decoded is! List) return null;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<DateTime?> lastUpdated(String key) async {
    if (!_database.isAvailable) return null;

    final db = _database.requireDb();
    final rows = await db.query(
      'cache_entries',
      columns: ['updated_at'],
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(rows.first['updated_at']! as int);
  }

  Future<void> saveReports(List<GetReportsReports> reports) {
    return saveJson(
      reportsKey,
      reports.map((report) => report.toJson()).toList(),
    );
  }

  Future<List<GetReportsReports>?> loadReports() async {
    final json = await loadJson(reportsKey);
    if (json == null) return null;
    return json.map(GetReportsReports.fromJson).toList();
  }

  Future<void> saveCategories(List<GetCategoriesCategories> categories) {
    return saveJson(
      categoriesKey,
      categories.map((category) => category.toJson()).toList(),
    );
  }

  Future<List<GetCategoriesCategories>?> loadCategories() async {
    final json = await loadJson(categoriesKey);
    if (json == null) return null;
    return json.map(GetCategoriesCategories.fromJson).toList();
  }

  Future<void> saveMyReports(
    String userId,
    List<GetReportsReports> reports,
  ) {
    return saveJson(
      myReportsKey(userId),
      reports.map((report) => report.toJson()).toList(),
    );
  }

  Future<List<GetReportsReports>?> loadMyReports(String userId) async {
    final json = await loadJson(myReportsKey(userId));
    if (json == null) return null;
    return json.map(GetReportsReports.fromJson).toList();
  }

  Future<void> saveComments(
    String reportId,
    List<GetReportCommentsComments> comments,
  ) {
    return saveJson(
      commentsKey(reportId),
      comments.map((comment) => comment.toJson()).toList(),
    );
  }

  Future<List<GetReportCommentsComments>?> loadComments(String reportId) async {
    final json = await loadJson(commentsKey(reportId));
    if (json == null) return null;
    return json.map(GetReportCommentsComments.fromJson).toList();
  }
}

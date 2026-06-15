import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;

  bool get isAvailable => _db != null;

  Future<void> initialize() async {
    if (_db != null) return;

    try {
      final dbPath = join(await getDatabasesPath(), 'city_issues_offline.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE cache_entries (
              cache_key TEXT PRIMARY KEY,
              json TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE pending_operations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              payload TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
        },
      );
    } catch (e, stack) {
      debugPrint('LocalDatabase: unavailable ($e)\n$stack');
      _db = null;
    }
  }

  Database requireDb() {
    final db = _db;
    if (db == null) {
      throw StateError('Lokalna baza danych nie jest dostępna.');
    }
    return db;
  }

  @visibleForTesting
  Future<void> closeForTesting() async {
    await _db?.close();
    _db = null;
  }
}

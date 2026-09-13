import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '/services/logging_service.dart';

class OfflineService {
  OfflineService._();
  static final OfflineService instance = OfflineService._();

  Database? _db;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _db = await openDatabase(
        p.join(await getDatabasesPath(), 'shph_cache.db'),
        version: 1,
        onCreate: _createTables,
      );
      _initialized = true;
      LoggingService.info('Offline database initialized', tag: 'Offline');
    } catch (e) {
      LoggingService.error('Failed to initialize offline DB: $e',
          tag: 'Offline');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cache (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        expires_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE pending_mutations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> cache(String key, String value,
      {Duration? ttl}) async {
    if (_db == null) return;
    final expiresAt = ttl != null
        ? DateTime.now().add(ttl).millisecondsSinceEpoch
        : null;
    await _db!.insert(
      'cache',
      {
        'key': key,
        'value': value,
        'expires_at': expiresAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCached(String key) async {
    if (_db == null) return null;
    final rows = await _db!.query(
      'cache',
      where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [key, DateTime.now().millisecondsSinceEpoch],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> evict(String key) async {
    if (_db == null) return;
    await _db!.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clearCache() async {
    if (_db == null) return;
    await _db!.delete('cache');
  }

  Future<int> enqueueMutation({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    if (_db == null) return -1;
    final id = await _db!.insert('pending_mutations', {
      'table_name': tableName,
      'operation': operation,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> pendingMutations() async {
    if (_db == null) return [];
    return _db!.query('pending_mutations', orderBy: 'created_at ASC');
  }

  Future<void> removeMutation(int id) async {
    if (_db == null) return;
    await _db!.delete('pending_mutations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearMutations() async {
    if (_db == null) return;
    await _db!.delete('pending_mutations');
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _initialized = false;
  }
}

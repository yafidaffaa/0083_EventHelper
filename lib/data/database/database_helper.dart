import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eventhelper.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE liked_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(event_id, user_id)
      )
    ''');
  }

  // Like operations - userId wajib
  Future<bool> isEventLiked(int eventId, String userId) async {
    final db = await database;
    final result = await db.query(
      'liked_events',
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleLike(int eventId, String userId) async {
    final db = await database;

    final isLiked = await isEventLiked(eventId, userId);

    if (isLiked) {
      await db.delete(
        'liked_events',
        where: 'event_id = ? AND user_id = ?',
        whereArgs: [eventId, userId],
      );
    } else {
      await db.insert('liked_events', {
        'event_id': eventId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<int>> getAllLikedEventIds(String userId) async {
    final db = await database;
    final result = await db.query(
      'liked_events',
      columns: ['event_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((row) => row['event_id'] as int).toList();
  }

  // Method untuk mendapatkan total like count dari semua user
  Future<int> getTotalLikeCount(int eventId) async {
    final db = await database;
    final result = await db.query(
      'liked_events',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return result.length;
  }

  // Method untuk mendapatkan like count
  Future<bool> isEventLikedByUser(int eventId, String userId) async {
    return await isEventLiked(eventId, userId);
  }

  // Clear likes untuk user tertentu
  Future<void> clearUserLikes(String userId) async {
    final db = await database;
    await db.delete('liked_events', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Clear all likes (for testing or reset)
  Future<void> clearAllLikes() async {
    final db = await database;
    await db.delete('liked_events');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

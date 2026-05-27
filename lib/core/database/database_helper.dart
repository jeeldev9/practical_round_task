import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Private Constructor
  DatabaseHelper._internal();

  // Singleton Instance
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Factory Constructor to return singleton
  factory DatabaseHelper() => instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_task.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER DEFAULT 1,
        status INTEGER DEFAULT 0,
        due_date TEXT,
        user_id TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 2. Create pending_actions table
    await db.execute('''
      CREATE TABLE pending_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        task_id TEXT,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // 3. Create users_cache table
    await db.execute('''
      CREATE TABLE users_cache (
        uid TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        photo_url TEXT,
        fcm_token TEXT,
        cached_at TEXT
      )
    ''');

    // 4. Create notifications table
    await _createNotificationsTable(db);
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        task_id TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2: Add notifications history table
      await _createNotificationsTable(db);
    }
  }
}

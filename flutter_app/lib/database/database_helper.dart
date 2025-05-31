import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'medicinal_plants.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to users table
      await db.execute('ALTER TABLE users ADD COLUMN name TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN profile_image_path TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute('''
      CREATE TABLE plants (
        plant_id INTEGER PRIMARY KEY AUTOINCREMENT,
        common_name TEXT NOT NULL,
        scientific_name TEXT NOT NULL UNIQUE,
        origin TEXT,
        growth_environment TEXT,
        category TEXT,
        image_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        last_viewed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE toxicity (
        toxicity_id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_id INTEGER NOT NULL,
        is_toxic INTEGER NOT NULL,
        toxic_parts TEXT,
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id) ON DELETE CASCADE,
        UNIQUE (plant_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE toxicity_effects (
        effect_id INTEGER PRIMARY KEY AUTOINCREMENT,
        toxicity_id INTEGER NOT NULL,
        effect_description TEXT NOT NULL,
        FOREIGN KEY (toxicity_id) REFERENCES toxicity(toxicity_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE medicinal_uses (
        use_id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_id INTEGER NOT NULL,
        use_description TEXT NOT NULL,
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE natural_remedies (
        remedy_id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        instructions TEXT NOT NULL,
        use_category TEXT,
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE remedy_ingredients (
        ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
        remedy_id INTEGER NOT NULL,
        ingredient_name TEXT NOT NULL,
        quantity TEXT,
        FOREIGN KEY (remedy_id) REFERENCES natural_remedies(remedy_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        name TEXT,
        profile_image_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE user_favorites (
        favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        plant_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id) ON DELETE CASCADE,
        UNIQUE (user_id, plant_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE identification_history (
        history_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        plant_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        identification_date TEXT DEFAULT CURRENT_TIMESTAMP,
        was_toxic INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id) ON DELETE CASCADE
      )
    ''');
  }

  // Helper method to close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
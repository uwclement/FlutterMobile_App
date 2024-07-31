import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'user_profile.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        image_path TEXT
      )
    ''');
  }

  Future<void> saveProfileImage(String imagePath) async {
    Database db = await database;

    // Check if a record already exists
    List<Map<String, dynamic>> existingRecords = await db.query('user_profile');

    if (existingRecords.isEmpty) {
      // If no record exists, insert a new one
      await db.insert('user_profile', {'image_path': imagePath});
    } else {
      // If a record exists, update it
      await db.update(
        'user_profile',
        {'image_path': imagePath},
        where: 'id = ?',
        whereArgs: [existingRecords.first['id']],
      );
    }
  }

  Future<String?> getProfileImage() async {
    Database db = await database;
    var result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first['image_path'] as String?;
    }
    return null;
  }
}
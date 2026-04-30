import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/url_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shortly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const boolType = 'INTEGER';
    const integerType = 'INTEGER';

    await db.execute('''
CREATE TABLE url_data ( 
  id $idType, 
  provider $textType,
  originalUrl $textType,
  shortenedUrl $textType,
  expandedUrl $textType,
  success $boolType,
  timestamp $integerType
  )
''');
  }

  Future<int> insert(UrlData urlData) async {
    final db = await instance.database;
    return await db.insert('url_data', urlData.toMap());
  }

  Future<List<UrlData>> getAllUrls() async {
    try {
      final db = await instance.database;
      const orderBy = 'timestamp DESC';
      final result = await db.query('url_data', orderBy: orderBy);
      return result.map((json) => UrlData.fromMap(json)).toList();
    } catch (e) {
      print('Error getting all urls: $e');
      return [];
    }
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('url_data', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('url_data');
  }
}

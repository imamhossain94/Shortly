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

  Future<void> seedData([Database? db]) async {
    final database = db ?? await instance.database;
    final List<UrlData> sampleUrls = [
      UrlData(
        provider: 'Cleanuri',
        originalUrl: 'https://www.google.com',
        shortenedUrl: 'https://cleanuri.com/b12345',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 100000,
      ),
      UrlData(
        provider: 'Shorte.st',
        originalUrl: 'https://www.facebook.com',
        shortenedUrl: 'http://sh.st/abcde',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 200000,
      ),
      UrlData(
        provider: 'Bitly',
        originalUrl: 'https://www.github.com',
        shortenedUrl: 'https://bit.ly/3xyz789',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 300000,
      ),
      UrlData(
        provider: 'TinyURL',
        originalUrl: 'https://www.twitter.com',
        shortenedUrl: 'https://tinyurl.com/y6u7v8w',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 400000,
      ),
      UrlData(
        provider: 'Is.gd',
        originalUrl: 'https://www.reddit.com',
        shortenedUrl: 'https://is.gd/m9n0o1',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 500000,
      ),
      UrlData(
        provider: 'Cutt.ly',
        originalUrl: 'https://www.linkedin.com',
        shortenedUrl: 'https://cutt.ly/p2q3r4',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 600000,
      ),
      UrlData(
        provider: 'V.gd',
        originalUrl: 'https://www.instagram.com',
        shortenedUrl: 'https://v.gd/s5t6u7',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 700000,
      ),
      UrlData(
        provider: 'T.ly',
        originalUrl: 'https://www.youtube.com',
        shortenedUrl: 'https://t.ly/v8w9x0',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 800000,
      ),
      UrlData(
        provider: 'S.id',
        originalUrl: 'https://www.netflix.com',
        shortenedUrl: 'https://s.id/a1b2c3',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 900000,
      ),
      UrlData(
        provider: 'Buff.ly',
        originalUrl: 'https://www.spotify.com',
        shortenedUrl: 'https://buff.ly/d4e5f6',
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch - 1000000,
      ),
    ];

    for (final url in sampleUrls) {
      await database.insert('url_data', url.toMap());
    }
  }
}

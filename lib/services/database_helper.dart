import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sipilab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _createDB(Database db, int version) async {
  
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        role TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

  
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES users (username)
      )
    ''');

   
    await db.insert('users', {
      'username': 'BM',
      'password': _hashPassword('2425'),
      'fullName': 'Bina Marga',
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'Lab',
      'password': _hashPassword('1225'),
      'fullName': 'Laboratorium',
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'DPU',
      'password': _hashPassword('3009'),
      'fullName': 'Dinas Pekerjaan Umum',
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

 

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'username ASC');
  }

  Future<int> addUser({
    required String username,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    final db = await database;
    
    return await db.insert('users', {
      'username': username,
      'password': password, 
      'fullName': fullName,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateUser({
    required String username,
    String? password,
    String? fullName,
    String? role,
  }) async {
    final db = await database;
    
    Map<String, dynamic> values = {};
    if (password != null) values['password'] = password;
    if (fullName != null) values['fullName'] = fullName;
    if (role != null) values['role'] = role;

    return await db.update(
      'users',
      values,
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> deleteUser(String username) async {
    final db = await database;
    
    await db.delete('reports', where: 'username = ?', whereArgs: [username]);
    
    return await db.delete(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  

  Future<int> insertReport(Map<String, dynamic> report) async {
    final db = await database;
    return await db.insert('reports', report);
  }

  Future<List<Map<String, dynamic>>> getReportsByUsername(String username) async {
    final db = await database;
    return await db.query(
      'reports',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReportsByUsernameAndType(
    String username,
    String type,
  ) async {
    final db = await database;
    return await db.query(
      'reports',
      where: 'username = ? AND type = ?',
      whereArgs: [username, type],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getReportById(String id) async {
    final db = await database;
    final results = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> deleteReport(String id, String username) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
  }

  Future<int> deleteAllReportsByUsername(String username) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<Map<String, int>> getReportStatisticsByUsername(String username) async {
    final db = await database;
    
    final allReports = await db.query(
      'reports',
      where: 'username = ?',
      whereArgs: [username],
    );

    return {
      'total': allReports.length,
      'sand_cone': allReports.where((r) => r['type'] == 'sand_cone').length,
      'hammer_test': allReports.where((r) => r['type'] == 'hammer_test').length,
      'uji_kuat': allReports.where((r) => r['type'] == 'uji_kuat').length,
      'konversi_beton': allReports.where((r) => r['type'] == 'konversi_beton').length,
    };
  }

  Future<List<Map<String, dynamic>>> searchReports(
    String username,
    String keyword,
  ) async {
    final db = await database;
    return await db.query(
      'reports',
      where: 'username = ? AND (title LIKE ? OR summary LIKE ?)',
      whereArgs: [username, '%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );
  }

 

  Future<int> getDatabaseSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()');
    return result.first['size'] as int;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('reports');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
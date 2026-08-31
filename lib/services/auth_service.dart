import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_helper.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUsername = 'username';
  static const String _keyFullName = 'fullName';
  static const String _keyRole = 'role';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
    
      String hashedPassword = _hashPassword(password);
      
      final user = await _dbHelper.loginUser(username, hashedPassword);

      if (user == null) {
        return {
          'success': false,
          'message': 'Username atau password salah',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, user['username']);
      await prefs.setString(_keyFullName, user['fullName']);
      await prefs.setString(_keyRole, user['role']);

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

 
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
  }

 
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

 
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_keyUsername),
      'fullName': prefs.getString(_keyFullName),
      'role': prefs.getString(_keyRole),
    };
  }
  
 
  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }


  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    try {
     
      final existing = await _dbHelper.getUserByUsername(username);
      if (existing != null) {
        return {
          'success': false,
          'message': 'Username sudah digunakan',
        };
      }

    
      String hashedPassword = _hashPassword(password);

     
      await _dbHelper.addUser(
        username: username,
        password: hashedPassword,
        fullName: fullName,
        role: role,
      );

      return {
        'success': true,
        'message': 'Registrasi berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal registrasi: $e',
      };
    }
  }

 
  Future<Map<String, dynamic>> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
     
      String hashedOldPassword = _hashPassword(oldPassword);
      final user = await _dbHelper.loginUser(username, hashedOldPassword);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'Password lama salah',
        };
      }

      
      String hashedNewPassword = _hashPassword(newPassword);
      await _dbHelper.updateUser(username: username, password: hashedNewPassword);

      return {
        'success': true,
        'message': 'Password berhasil diubah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengubah password: $e',
      };
    }
  }


  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _dbHelper.getAllUsers();
  }


  Future<Map<String, dynamic>> deleteUser(String username) async {
    try {
      await _dbHelper.deleteUser(username);
      return {
        'success': true,
        'message': 'User berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus user: $e',
      };
    }
  }
}
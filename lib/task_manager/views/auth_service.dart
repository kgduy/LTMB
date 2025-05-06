import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/users.dart';
import '../dtb/databasehelper.dart';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DBHelper _dbHelper = DBHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Đăng ký tài khoản mới
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? avatar,
  }) async {
    final db = await _dbHelper.database;

    // Kiểm tra trùng email hoặc username
    final existing = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [email, username],
    );
    if (existing.isNotEmpty) return false;
    // Tự động xác định isAdmin nếu là người dùng đầu tiên
    final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );

    final id = Uuid().v4();
    final now = DateTime.now();

    final newUser = User(
      id: id,
      username: username,
      email: email,
      password: hashPassword(password),
      avatar: avatar,
      createdAt: now,
      lastActive: now,
      isAdmin: userCount == 0,
    );

    await db.insert('users', newUser.toMap());

    _currentUser = newUser;
    // Lưu userId vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _currentUser!.id);
    return true;
  }

  // Đăng nhập
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.database;
    final hashed = hashPassword(password);

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashed],
    );

    if (result.isNotEmpty) {
      _currentUser = User.fromMap(result.first);

      // Cập nhật lastActive
      await db.update(
        'users',
        {'lastActive': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );
      // Lưu userId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      return true;
    }
    return false;
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
  }

  // Lấy user hiện tại từ ID
  Future<User?> getUserById(String id) async {
    return await _dbHelper.getUserById(id);
  }
}
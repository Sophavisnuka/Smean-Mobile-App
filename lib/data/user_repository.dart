import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:smean_mobile_app/models/user_class.dart';

class AuthRepository {
  static const _usersKey = 'users_json';
  static const _currentUserKey = 'current_user_id';
  static const _saltKey = 'auth_salt'; // simple app-level salt for MVP

  static Future<String> _getOrCreateSalt(SharedPreferences prefs) async {
    final existing = prefs.getString(_saltKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final salt = const Uuid().v4();
    await prefs.setString(_saltKey, salt);
    return salt;
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  static Future<List<User>> _loadUsers(SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['users'] as List<dynamic>? ?? []);
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> _saveUsers(SharedPreferences prefs, List<User> users) async {
    final map = {'users': users.map((u) => u.toJson()).toList()};
    await prefs.setString(_usersKey, jsonEncode(map));
  }

  static Future<User> register({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = await _getOrCreateSalt(prefs);

    final users = await _loadUsers(prefs);

    final normalized = username.trim().toLowerCase();
    final exists = users.any((u) => u.userName.trim().toLowerCase() == normalized);
    if (exists) {
      throw Exception('Username already exists');
    }

    final user = User(
      userId: const Uuid().v4(),
      userName: username.trim(),
      passwordHash: _hashPassword(password, salt),
    );

    users.add(user);
    await _saveUsers(prefs, users);

    // Auto-login after register:
    await prefs.setString(_currentUserKey, user.userId);

    return user;
  }

  static Future<User> login({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = await _getOrCreateSalt(prefs);

    final users = await _loadUsers(prefs);
    final normalized = username.trim().toLowerCase();

    final user = users.firstWhere(
      (u) => u.userName.trim().toLowerCase() == normalized,
      orElse: () => throw Exception('User not found'),
    );

    final hash = _hashPassword(password, salt);
    if (hash != user.passwordHash) {
      throw Exception('Wrong password');
    }

    await prefs.setString(_currentUserKey, user.userId);
    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final users = await _loadUsers(prefs);
    try {
      return users.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_class.dart';

class AuthService {
  static const _usersKey = 'users_json';
  static const _currentUserKey = 'current_user_id';

  String _hashPassword(String password) {
    // Demo hash (not as strong as bcrypt/argon2, but better than plain text)
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _newId() {
    return 'u_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<List<AppUser>> _loadUsers(SharedPreferences sp) async {
    final raw = sp.getString(_usersKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> _saveUsers(SharedPreferences sp, List<AppUser> users) async {
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await sp.setString(_usersKey, raw);
  }

  Future<AppUser?> getCurrentUser() async {
    final sp = await SharedPreferences.getInstance();
    final currentId = sp.getString(_currentUserKey);
    if (currentId == null) return null;

    final users = await _loadUsers(sp);
    try {
      return users.firstWhere((u) => u.id == currentId);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_currentUserKey);
  }

  Future<(bool ok, String message)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final users = await _loadUsers(sp);

    final normalizedEmail = email.trim().toLowerCase();

    final exists = users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) {
      return (false, 'Email already exists.');
    }

    if (password.length < 6) {
      return (false, 'Password must be at least 6 characters.');
    }

    final user = AppUser(
      id: _newId(),
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    users.add(user);
    await _saveUsers(sp, users);

    // auto-login after register (nice for demo)
    await sp.setString(_currentUserKey, user.id);

    return (true, 'Registered successfully.');
  }

  Future<(bool ok, String message)> login({
    required String email,
    required String password,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final users = await _loadUsers(sp);

    final normalizedEmail = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    final user = users.where((u) => u.email.toLowerCase() == normalizedEmail).toList();
    if (user.isEmpty) return (false, 'Email not found.');

    if (user.first.passwordHash != hash) {
      return (false, 'Incorrect password.');
    }

    await sp.setString(_currentUserKey, user.first.id);
    return (true, 'Login successful.');
  }

  // Optional: for debugging/demo
  Future<void> debugClearAll() async {
    if (!kDebugMode) return;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_usersKey);
    await sp.remove(_currentUserKey);
  }
}

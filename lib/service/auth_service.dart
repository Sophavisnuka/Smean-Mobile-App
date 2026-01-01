import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:smean_mobile_app/repository/user_repository.dart';
import 'package:smean_mobile_app/models/user_class.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final AuthRepository _repo = AuthRepository();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _newId() => Uuid().v4();

  Future<AppUser?> getCurrentUser() async {
    final id = await _repo.getCurrentUserId();
    if (id == null) return null;

    final users = await _repo.loadUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => _repo.clearCurrentUser();

  Future<(bool ok, String message)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await _repo.loadUsers();
    final normalizedEmail = email.trim().toLowerCase();

    if (users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
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
    await _repo.saveUsers(users);
    await _repo.setCurrentUserId(user.id);

    return (true, 'Registered successfully.');
  }

  Future<(bool ok, String message)> login({
    required String email,
    required String password,
  }) async {
    final users = await _repo.loadUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    final matches = users.where((u) => u.email.toLowerCase() == normalizedEmail);
    if (matches.isEmpty) return (false, 'Email not found.');

    final user = matches.first;
    if (user.passwordHash != hash) return (false, 'Incorrect password.');

    await _repo.setCurrentUserId(user.id);
    return (true, 'Login successful.');
  }
}

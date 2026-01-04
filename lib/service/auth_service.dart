import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:smean_mobile_app/data/repository/user_repository.dart';
import 'package:smean_mobile_app/data/models/user_class.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final AuthRepository _repo;

  AuthService(AppDatabase db) : _repo = AuthRepository(db);
  
  // Expose repository for direct access when needed
  AuthRepository get repo => _repo;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _newId() => Uuid().v4();

  Future<AppUser?> getCurrentUser() async {
    final id = await _repo.getCurrentUserId();
    if (id == null) return null;

    return await _repo.getUserById(id);
  }

  Future<void> logout() => _repo.clearCurrentUser();

  Future<(bool ok, String message)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Check if email already exists
    final existingUser = await _repo.getUserByEmail(normalizedEmail);
    if (existingUser != null) {
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
      imagePath: null, // Default avatar placeholder
    );

    await _repo.createUser(user);
    await _repo.setCurrentUserId(user.id);

    return (true, 'Registered successfully.');
  }

  Future<(bool ok, String message)> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    final user = await _repo.getUserByEmail(normalizedEmail);
    if (user == null) return (false, 'Email not found.');

    if (user.passwordHash != hash) return (false, 'Incorrect password.');

    await _repo.setCurrentUserId(user.id);
    return (true, 'Login successful.');
  }

  Future<(bool ok, String message)> deleteUserAccount(String userId) async {
    final currentUserId = await _repo.getCurrentUserId();
    
    // Verify the user is deleting their own account
    if (currentUserId != userId) {
      return (false, 'Unauthorized: Cannot delete another user\'s account.');
    }

    final user = await _repo.getUserById(userId);
    if (user == null) {
      return (false, 'User not found.');
    }

    // Clear current user session first
    await _repo.clearCurrentUser();
    
    // Delete the user from database
    await _repo.deleteUser(userId);
    
    return (true, 'Account deleted successfully.');
  }
}

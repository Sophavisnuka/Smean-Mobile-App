import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../models/user_class.dart';
import '../database/database.dart';

class AuthRepository {
  final AppDatabase db;
  static const currentUserKey = 'current_user_id';

  AuthRepository(this.db);

  /// Get all users from the database
  Future<List<AppUser>> loadUsers() async {
    final users = await db.select(db.users).get();
    return users.map((user) => AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
    )).toList();
  }

  /// Create a new user in the database
  Future<void> createUser(AppUser user) async {
    await db.into(db.users).insert(
      UsersCompanion(
        id: drift.Value(user.id),
        name: drift.Value(user.name),
        email: drift.Value(user.email),
        passwordHash: drift.Value(user.passwordHash),
        createdAt: drift.Value(user.createdAt),
      ),
    );
  }

  /// Get user by email
  Future<AppUser?> getUserByEmail(String email) async {
    final query = db.select(db.users)
      ..where((u) => u.email.equals(email.toLowerCase()));
    
    final user = await query.getSingleOrNull();
    if (user == null) return null;

    return AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
    );
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String id) async {
    final query = db.select(db.users)
      ..where((u) => u.id.equals(id));
    
    final user = await query.getSingleOrNull();
    if (user == null) return null;

    return AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
    );
  }

  /// Store current user ID in SharedPreferences (lightweight session management)
  Future<String?> getCurrentUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(currentUserKey);
  }

  Future<void> setCurrentUserId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(currentUserKey, id);
  }

  Future<void> clearCurrentUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(currentUserKey);
  }
}

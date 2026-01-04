import 'package:drift/drift.dart' as drift;
import '../models/user_class.dart';
import '../database/database.dart';

class AuthRepository {
  final AppDatabase db;

  AuthRepository(this.db);

  /// Get all users from the database
  Future<List<AppUser>> loadUsers() async {
    final users = await db.select(db.users).get();
    return users
        .map(
          (user) => AppUser(
            id: user.id,
            name: user.name,
            email: user.email,
            passwordHash: user.passwordHash,
            createdAt: user.createdAt,
            imagePath: user.imagePath
          ),
        )
        .toList();
  }

  /// Create a new user in the database
  Future<void> createUser(AppUser user) async {
    await db
        .into(db.users)
        .insert(
          UsersCompanion(
            id: drift.Value(user.id),
            name: drift.Value(user.name),
            email: drift.Value(user.email),
            passwordHash: drift.Value(user.passwordHash),
            createdAt: drift.Value(user.createdAt),
            imagePath: drift.Value(user.imagePath)
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
      imagePath: user.imagePath
    );
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String id) async {
    final query = db.select(db.users)..where((u) => u.id.equals(id));

    final user = await query.getSingleOrNull();
    if (user == null) return null;

    return AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
      imagePath: user.imagePath
    );
  }

  /// Get current user ID from database session
  Future<String?> getCurrentUserId() async {
    final session = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();
    return session?.currentUserId;
  }

  /// Set current user ID in database session
  Future<void> setCurrentUserId(String id) async {
    final existing = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();

    if (existing == null) {
      // Insert new session
      await db
          .into(db.appSession)
          .insert(
            AppSessionCompanion(
              currentUserId: drift.Value(id),
              lastUpdated: drift.Value(DateTime.now()),
            ),
          );
    } else {
      // Update existing session
      await (db.update(
        db.appSession,
      )..where((t) => t.id.equals(existing.id))).write(
        AppSessionCompanion(
          currentUserId: drift.Value(id),
          lastUpdated: drift.Value(DateTime.now()),
        ),
      );
    }
  }

  /// Clear current user session
  Future<void> clearCurrentUser() async {
    final existing = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();

    if (existing != null) {
      await (db.update(
        db.appSession,
      )..where((t) => t.id.equals(existing.id))).write(
        AppSessionCompanion(
          currentUserId: const drift.Value(null),
          lastUpdated: drift.Value(DateTime.now()),
        ),
      );
    }
  }
  
  Future<void> editUsername(String userId,String newUsername) async {
    await (db.update(db.users)..where((user) => user.id.equals(userId))).write(
      UsersCompanion(
        name: drift.Value(newUsername),
      ),
    );
  }

  Future<void> editProfile(String userId, String? newProfile) async {
    await (db.update(db.users)..where((user) => user.id.equals(userId))).write(
      UsersCompanion(
        imagePath: drift.Value(newProfile)
      )
    );
  }
  Future<void> deleteUser(String userId) async {
    await (db.delete(db.users)..where((user) => user.id.equals(userId))).go();
  }
}

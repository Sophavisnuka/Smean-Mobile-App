import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_class.dart';

class AuthRepository {
  static const usersKey = 'users_json';
  static const currentUserKey = 'current_user_id';

  Future<List<AppUser>> loadUsers() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(usersKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await sp.setString(usersKey, raw);
  }

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

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/service/auth_service.dart';

class AudioRepository {

  static const String _assetPath = 'assets/json/audio_repositories.json';

  static Future<String> _userKey() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      throw Exception('No logged in user');
    }
    return 'audio_json_${user.id}';
  }

  static Future<List<AudioRecord>> getAudios() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _userKey();

    String? jsonString = prefs.getString(key);

    // Seed ONLY for first-time user
    if (jsonString == null) {
      jsonString = await rootBundle.loadString(_assetPath);
      await prefs.setString(key, jsonString);
    }

    final data = jsonDecode(jsonString);
    final List<dynamic> audioJson = data['audios'] ?? [];

    return audioJson.map((json) => AudioRecord.fromJson(json)).toList();
  }

  static Future<void> saveAudios(List<AudioRecord> audios) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _userKey();

    final map = {
      'audios': audios.map((a) => a.toJson()).toList()
    };

    await prefs.setString(key, jsonEncode(map));
  }
}

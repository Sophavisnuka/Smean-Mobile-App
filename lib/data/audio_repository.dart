import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioRepository {

  static const String _preferenceKey =  'audio_json';
  static const String _assetPath = 'assets/json/audio_repositories.json';

  static Future<List<AudioRecord>> getAudios() async {
    print('--- getAudios() ---');
    print('Origin: ${Uri.base.origin}');

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();
    print('Prefs keys: $keys');

    String? jsonString = prefs.getString(_preferenceKey);
    print('Read key "$_preferenceKey": ${jsonString == null ? "NULL" : "LEN ${jsonString.length}"}');

    if (jsonString == null) {
      print('Seeding from ASSET: $_assetPath');
      jsonString = await rootBundle.loadString(_assetPath);
      await prefs.setString(_preferenceKey, jsonString);
      print('Seeded length: ${jsonString.length}');
    } else {
      print('Loaded from PREFS');
    }

    final data = jsonDecode(jsonString);
    final List<dynamic> audioJson = data['audios'] ?? [];
    print('Audios count: ${audioJson.length}');
    print('First title: ${audioJson.isNotEmpty ? audioJson.first["audioTitle"] : "none"}');

    return audioJson.map((json) => AudioRecord.fromJson(json)).toList();
  }


  static Future<void> saveAudios(List<AudioRecord> audios) async {
    final prefs = await SharedPreferences.getInstance();

    final map = {
      'audios': audios.map((a) => a.toJson()).toList()
    };

    await prefs.setString(_preferenceKey, jsonEncode(map));
  }
}

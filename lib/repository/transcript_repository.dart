import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smean_mobile_app/models/transcript_class.dart';
import 'package:smean_mobile_app/service/auth_service.dart';

class TranscriptRepository {
  static Future<String> _userKey() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) throw Exception('No logged in user');
    return 'transcripts_json_${user.id}';
  }

  static Future<List<Transcript>> getTranscripts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _userKey();

    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) return [];

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['transcripts'] as List<dynamic>? ?? []);
    return list.map((e) => Transcript.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveTranscripts(List<Transcript> transcripts) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _userKey();

    final map = {'transcripts': transcripts.map((t) => t.toJson()).toList()};
    await prefs.setString(key, jsonEncode(map));
  }
}

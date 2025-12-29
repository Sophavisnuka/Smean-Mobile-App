import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioRepository {
  static Future<List<AudioRecord>> getAudios () async {
    final String path = '../assets/json/audio_repositories.json';
    final String response = await rootBundle.loadString(path);
    final data = json.decode(response);
    final List<dynamic> audioJson = data['audios'];
    return audioJson.map((json) => AudioRecord.fromJson(json)).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioProvider extends ChangeNotifier {
  final List<AudioRecord> _audios = [];

  List<AudioRecord> get audios => List.unmodifiable(_audios);

  void setAudios(List<AudioRecord> list) {
    _audios
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  void addAudio(AudioRecord audio) {
    _audios.add(audio);
    notifyListeners();
  }

  void deleteAudio(String id) {
    _audios.removeWhere((a) => a.audioId == id);
    notifyListeners();
  }
}

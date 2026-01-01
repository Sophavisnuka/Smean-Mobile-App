import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RecordAudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  Timer? _timer;
  
  // State variables
  bool isRecording = false;
  Duration elapsed = Duration.zero;
  String? recordedFilePath;
  
  bool isPlaying = false;
  Duration playPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  
  // Callbacks for UI updates
  Function()? onStateChanged;
  
  RecordAudioService() {
    _setupPlayerListeners();
  }
  
  void _setupPlayerListeners() {
    // Listen when player state changes (playing/pause/stopped)
    _player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      onStateChanged?.call();
    });

    // Listen to playback position (updates every second)
    _player.onPositionChanged.listen((position) {
      playPosition = position;
      onStateChanged?.call();
    });

    // Listen to audio duration when loaded
    _player.onDurationChanged.listen((duration) {
      totalDuration = duration;
      onStateChanged?.call();
    });
  }
  
  // Ask for microphone permission
  Future<bool> requestPermission() async {
    final ok = await _recorder.hasPermission();
    return ok;
  }
  
  // Start recording audio
  Future<bool> startRecording() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return false;

    if (kIsWeb) {
      // Web: don't pass a path. Use a web encoder.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.opus, // best for web
        ), 
        path: '',
      );
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // matches .m4a better
        ),
        path: filePath,
      );
    }

    isRecording = true;
    elapsed = Duration.zero;
    onStateChanged?.call();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsed = Duration(seconds: timer.tick);
      onStateChanged?.call();
    });
    
    return true;
  }
  
  // Stop recording
  Future<void> stopRecording() async {
    _timer?.cancel();
    final pathOrUrl = await _recorder.stop(); // mobile: path, web: blob url

    isRecording = false;
    recordedFilePath = pathOrUrl;
    onStateChanged?.call();
  }
  
  // Toggle playback (play/pause)
  Future<void> togglePlayback() async {
    if (recordedFilePath == null) return;

    if (isPlaying) {
      await _player.pause();
    } else {
      if (kIsWeb) {
        await _player.play(UrlSource(recordedFilePath!)); // blob url
      } else {
        await _player.play(DeviceFileSource(recordedFilePath!)); // file path
      }
    }
  }
  
  // Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
    playPosition = Duration.zero;
    onStateChanged?.call();
  }
  
  // Seek to a specific position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }
  
  // Delete the current recording
  Future<void> deleteRecording() async {
    await stopPlayback();
    recordedFilePath = null;
    elapsed = Duration.zero;
    playPosition = Duration.zero;
    totalDuration = Duration.zero;
    onStateChanged?.call();
  }
  
  // Format duration to MM:SS
  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
  
  // Clean up resources
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
  }
}

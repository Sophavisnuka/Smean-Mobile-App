import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralized service for managing audio playback across the app
class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();

  // State variables
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isLoading = false;
  String? currentAudioPath;

  // Callbacks for UI updates
  Function()? onStateChanged;

  AudioPlaybackService() {
    _setupListeners();
  }

  void _setupListeners() {
    _player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      onStateChanged?.call();
    });

    _player.onPositionChanged.listen((pos) {
      position = pos;
      onStateChanged?.call();
    });

    _player.onDurationChanged.listen((dur) {
      duration = dur;
      onStateChanged?.call();
    });
  }

  /// Load an audio file and retrieve its duration
  Future<bool> loadAudio(String audioPath) async {
    if (audioPath.isEmpty) return false;

    try {
      isLoading = true;
      currentAudioPath = audioPath;
      onStateChanged?.call();

      // Set the source
      if (kIsWeb) {
        await _player.setSource(UrlSource(audioPath));
      } else {
        await _player.setSource(DeviceFileSource(audioPath));
      }

      // Try to get duration multiple times if needed
      Duration? d;
      for (int i = 0; i < 5 && d == null; i++) {
        d = await _player.getDuration();
        if (d == null) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (d != null) {
        duration = d;
      }

      isLoading = false;
      onStateChanged?.call();
      return true;
    } catch (e) {
      isLoading = false;
      onStateChanged?.call();
      return false;
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayback() async {
    if (currentAudioPath == null || currentAudioPath!.isEmpty) return;

    try {
      if (isPlaying) {
        await _player.pause();
      } else {
        if (kIsWeb) {
          await _player.play(UrlSource(currentAudioPath!));
        } else {
          await _player.play(DeviceFileSource(currentAudioPath!));
        }
      }
    } catch (e) {
      // Handle playback errors silently
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      // Handle errors silently
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      await _player.stop();
      position = Duration.zero;
      onStateChanged?.call();
    } catch (e) {
      // Handle errors silently
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration newPosition) async {
    try {
      await _player.seek(newPosition);
    } catch (e) {
      // Handle errors silently
    }
  }

  /// Reset the service state
  void reset() {
    stop();
    currentAudioPath = null;
    position = Duration.zero;
    duration = Duration.zero;
    isPlaying = false;
    onStateChanged?.call();
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}

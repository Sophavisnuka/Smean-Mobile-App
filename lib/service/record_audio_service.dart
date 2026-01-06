import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smean_mobile_app/service/base_audio_service.dart';
import 'package:http/http.dart' as http;

class RecordAudioService implements BaseAudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Timer? _timer;

  // State variables
  bool isRecording = false;
  Duration elapsed = Duration.zero;
  String? recordedFilePath;

  @override
  bool isPlaying = false;
  @override
  Duration playPosition = Duration.zero;
  @override
  Duration totalDuration = Duration.zero;
  @override
  int? fileSize; // in bytes

  // Callbacks for UI updates
  @override
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
    if (kIsWeb && pathOrUrl != null && pathOrUrl.startsWith('blob:')) {
      // Persist blob into a data URL so it survives page refreshes
      recordedFilePath = await _persistWebRecording(pathOrUrl);
    } else {
      recordedFilePath = pathOrUrl;
    }

    // Set total duration from recording elapsed time
    totalDuration = elapsed;

    // Calculate file size
    await _calculateFileSize();

    onStateChanged?.call();
  }

  // Calculate file size after recording
  Future<void> _calculateFileSize() async {
    if (recordedFilePath == null) {
      fileSize = null;
      return;
    }

    if (kIsWeb) {
      // Stored as a data URL; extract byte length
      try {
        final parts = recordedFilePath!.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          fileSize = bytes.length;
        } else {
          fileSize = null;
        }
      } catch (e) {
        fileSize = null;
      }
    } else {
      try {
        final file = File(recordedFilePath!);
        if (await file.exists()) {
          fileSize = await file.length();
        }
      } catch (e) {
        fileSize = null;
      }
    }
  }

  // Toggle playback (play/pause)
  @override
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
  @override
  Future<void> stopPlayback() async {
    await _player.stop();
    playPosition = Duration.zero;
    onStateChanged?.call();
  }

  // Seek to a specific position
  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  // Get file name
  @override
  String? get fileName {
    if (recordedFilePath == null) return null;
    return 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  // Get file path
  @override
  String? get filePath => recordedFilePath;

  // Convert the web blob URL to a data URL for persistence
  Future<String?> _persistWebRecording(String blobUrl) async {
    try {
      final response = await http.get(Uri.parse(blobUrl));
      if (response.statusCode == 200) {
        final base64Data = base64Encode(response.bodyBytes);
        // Default mime type for opus in webm container
        return 'data:audio/webm;base64,$base64Data';
      }
    } catch (_) {
      // Ignore and fall back
    }
    // Fall back to the volatile blob URL if conversion fails
    return blobUrl;
  }

  // Format file size for display
  @override
  String getFormattedFileSize() {
    if (fileSize == null) return '';

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // Delete the current recording
  Future<void> deleteRecording() async {
    await stopPlayback();
    recordedFilePath = null;
    elapsed = Duration.zero;
    playPosition = Duration.zero;
    totalDuration = Duration.zero;
    fileSize = null;
    onStateChanged?.call();
  }

  // Clean up resources
  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:smean_mobile_app/core/constants/app_constants.dart';
import 'package:smean_mobile_app/service/base_audio_service.dart';

class UploadAudioService implements BaseAudioService {
  final AudioPlayer _player = AudioPlayer();

  // State variables
  String? uploadedFilePath;
  @override
  String? fileName;
  @override
  int? fileSize; // in bytes
  @override
  bool isPlaying = false;
  @override
  Duration playPosition = Duration.zero;
  @override
  Duration totalDuration = Duration.zero;

  // Temporary storage for picked file before processing
  FilePickerResult? _pickedFileResult;

  // Callbacks for UI updates
  @override
  Function()? onStateChanged;

  // Get file path
  @override
  String? get filePath => uploadedFilePath;

  UploadAudioService() {
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    // Listen when player state changes (playing/pause/stopped)
    _player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      onStateChanged?.call();
    });

    // Listen to playback position
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

  /// Pick an audio file with allowed extensions (just shows picker, doesn't process)
  Future<bool> pickFileOnly() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedAudioExtensionsForPicker,
        allowMultiple: false,
      );

      if (result != null) {
        _pickedFileResult = result;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Process the picked file (copy and load audio)
  Future<bool> processPickedFile() async {
    if (_pickedFileResult == null) {
      return false;
    }

    try {
      final result = _pickedFileResult!;

      if (kIsWeb) {
        // Web: persist audio as data URL so it survives refresh
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          final extension = result.files.single.extension ?? 'webm';
          final mime = _mimeFromExtension(extension);
          final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
          uploadedFilePath = dataUrl;
          fileName = result.files.single.name;
          fileSize = bytes.length;
        } else {
          return false;
        }
      } else {
        // Mobile/Desktop: copy file to app documents directory for persistence
        final file = File(result.files.single.path!);
        final directory = await getApplicationDocumentsDirectory();
        final fileExtension = path.extension(result.files.single.name);
        final newFileName =
            'upload_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final newPath = path.join(directory.path, newFileName);

        // Copy the file
        final copiedFile = await file.copy(newPath);

        uploadedFilePath = copiedFile.path;
        fileName = result.files.single.name;
        fileSize = await copiedFile.length();
      }

      // Load the audio to get duration
      await loadAudio();

      onStateChanged?.call();

      // Clear the temporary result
      _pickedFileResult = null;
      return true;
    } catch (e) {
      _pickedFileResult = null;
      return false;
    }
  }

  // Best-effort mime detection for web data URLs
  String _mimeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
      case 'aac':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
      case 'oga':
        return 'audio/ogg';
      case 'webm':
      case 'weba':
        return 'audio/webm';
      case 'flac':
        return 'audio/flac';
      case 'opus':
        return 'audio/opus';
      default:
        return 'audio/$ext';
    }
  }

  /// Load audio file and get its duration
  Future<void> loadAudio() async {
    if (uploadedFilePath == null) return;

    try {
      // Stop any existing playback first
      await _player.stop();

      // Reset duration
      totalDuration = Duration.zero;

      if (kIsWeb) {
        await _player.setSourceUrl(uploadedFilePath!);
      } else {
        // Verify file exists before trying to load
        final file = File(uploadedFilePath!);
        if (!await file.exists()) {
          return;
        }
        await _player.setSourceDeviceFile(uploadedFilePath!);
      }

      // On some platforms, we need to start playing briefly to load metadata
      try {
        if (kIsWeb) {
          await _player.play(UrlSource(uploadedFilePath!));
        } else {
          await _player.play(DeviceFileSource(uploadedFilePath!));
        }

        // Wait a bit for metadata to load
        await Future.delayed(const Duration(milliseconds: 300));

        // Stop immediately
        await _player.pause();
        await _player.seek(Duration.zero);
      } catch (e) {
        // Ignore playback errors during metadata loading
      }

      // Wait for duration to be available
      int attempts = 0;
      while (attempts < 40) {
        // 4 seconds max
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;

        // Try getting duration from player
        Duration? directDuration = await _player.getDuration();

        if (directDuration != null && directDuration.inSeconds > 0) {
          totalDuration = directDuration;
          onStateChanged?.call();
          return;
        }

        // Also check if the listener has updated totalDuration
        if (totalDuration.inSeconds > 0) {
          onStateChanged?.call();
          return;
        }
      }

      onStateChanged?.call();
    } catch (e) {
      // Error loading audio
    }
  }

  /// Toggle play/pause
  @override
  Future<void> togglePlayback() async {
    if (uploadedFilePath == null) return;

    if (isPlaying) {
      await _player.pause();
    } else {
      // Play from the file source
      if (kIsWeb) {
        await _player.play(UrlSource(uploadedFilePath!));
      } else {
        await _player.play(DeviceFileSource(uploadedFilePath!));
      }
    }
  }

  /// Stop playback
  @override
  Future<void> stopPlayback() async {
    await _player.stop();
    playPosition = Duration.zero;
    onStateChanged?.call();
  }

  /// Seek to a specific position
  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Clear the uploaded file
  void clearFile() {
    stopPlayback();
    uploadedFilePath = null;
    fileName = null;
    fileSize = null;
    playPosition = Duration.zero;
    totalDuration = Duration.zero;
    onStateChanged?.call();
  }

  /// Dispose resources
  @override
  void dispose() {
    _player.dispose();
  }

  /// Format file size for display
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

  /// Process a dropped file (handle file copying and loading)
  Future<bool> processDroppedFile(XFile file) async {
    try {
      if (kIsWeb) {
        uploadedFilePath = file.path;
        fileName = file.name;
        fileSize = await file.length();
      } else {
        // Mobile/Desktop: copy file to app documents directory for persistence
        final ioFile = File(file.path);
        final directory = await getApplicationDocumentsDirectory();
        final fileExtension = path.extension(file.name);
        final newFileName =
            'upload_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final newPath = path.join(directory.path, newFileName);

        // Copy the file
        final copiedFile = await ioFile.copy(newPath);

        uploadedFilePath = copiedFile.path;
        fileName = file.name;
        fileSize = await copiedFile.length();
      }

      // Load audio to get duration
      await loadAudio();

      onStateChanged?.call();
      return true;
    } catch (e) {
      return false;
    }
  }
}

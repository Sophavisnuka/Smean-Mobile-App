/// Base interface for audio services (upload and record)
/// Provides consistent API for audio preview and playback
abstract class BaseAudioService {
  // Playback state
  bool get isPlaying;
  Duration get playPosition;
  Duration get totalDuration;

  // File information
  String? get fileName;
  String? get filePath;
  int? get fileSize; // in bytes

  // Callbacks
  Function()? get onStateChanged;
  set onStateChanged(Function()? callback);

  // Playback controls
  Future<void> togglePlayback();
  Future<void> stopPlayback();
  Future<void> seekTo(Duration position);

  // Utility
  String getFormattedFileSize();
  void dispose();
}

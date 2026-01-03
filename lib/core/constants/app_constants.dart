import 'package:uuid/uuid.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// UUID generator instance
  static const uuid = Uuid();

  /// Supported audio file extensions
  static const List<String> supportedAudioExtensions = [
    '.mp3',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
    '.flac',
  ];

  /// Supported audio file extensions for file picker
  static const List<String> supportedAudioExtensionsForPicker = [
    'mp3',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'flac',
  ];
}

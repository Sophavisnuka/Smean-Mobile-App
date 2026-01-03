import 'package:path/path.dart' as path;
import 'package:smean_mobile_app/core/constants/app_constants.dart';

/// Utility class for file validation operations
class FileValidationUtil {
  FileValidationUtil._();

  /// Validates if a file has a supported audio extension
  ///
  /// Checks both the file name and path for the extension
  /// Returns true if the file extension is in the supported list
  static bool isAudioFileSupported(String fileName, String filePath) {
    String fileExtension = path.extension(fileName).toLowerCase();

    // If extension is not found in name, try the path
    if (fileExtension.isEmpty) {
      fileExtension = path.extension(filePath).toLowerCase();
    }

    return AppConstants.supportedAudioExtensions.contains(fileExtension);
  }

  /// Gets the file extension from a file name or path
  static String getFileExtension(String fileName, String filePath) {
    String fileExtension = path.extension(fileName).toLowerCase();

    // If extension is not found in name, try the path
    if (fileExtension.isEmpty) {
      fileExtension = path.extension(filePath).toLowerCase();
    }

    return fileExtension;
  }

  /// Formats supported audio formats as a display string
  static String getSupportedFormatsDisplay(bool isKhmer) {
    const formats = 'MP3, WAV, M4A, AAC, OGG, FLAC';
    return isKhmer ? 'គាំទ្រទម្រង់: $formats' : 'Supported formats: $formats';
  }

  /// Gets an error message for unsupported file format
  static String getUnsupportedFormatMessage(bool isKhmer) {
    return isKhmer
        ? 'ទម្រង់ឯកសារមិនត្រឹមត្រូវ។ សូមប្រើ MP3, WAV, ឬទម្រង់ផ្សេងទៀតដែលគាំទ្រ។'
        : 'Invalid file format. Please use MP3, WAV, or other supported formats.';
  }
}

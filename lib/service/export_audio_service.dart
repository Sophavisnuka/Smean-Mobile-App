import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

/// Service for exporting and sharing audio recordings
class ExportAudioService {
  /// Share audio file to other apps (WhatsApp, Email, Drive, etc.)
  ///
  /// [filePath] - The full path to the audio file (or data URL for web)
  /// [fileName] - The name of the file (used as share text)
  /// [subject] - Optional subject line for sharing (useful for email)
  ///
  /// Returns true if share was initiated successfully, false otherwise
  Future<bool> shareAudio({
    required String filePath,
    required String fileName,
    String? subject,
  }) async {
    try {
      // On web, use direct download instead of share
      if (kIsWeb) {
        return await _downloadOnWeb(filePath, fileName);
      }

      // Mobile: Handle data URLs by converting to file first
      if (filePath.startsWith('data:')) {
        final tempFile = await _convertDataUrlToFile(filePath, fileName);
        if (tempFile == null) {
          print('Failed to convert data URL to file');
          return false;
        }
        filePath = tempFile.path;
      }

      // Verify file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return false;
      }

      // Create XFile from path
      final xFile = XFile(filePath);

      // Share the file on mobile
      final result = await Share.shareXFiles(
        [xFile],
        text: fileName,
        subject: subject,
      );

      // Check if share was successful (not dismissed or unavailable)
      return result.status == ShareResultStatus.success;
    } catch (e, stackTrace) {
      print('Error sharing audio: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Direct download for web browsers
  Future<bool> _downloadOnWeb(String filePath, String fileName) async {
    if (!kIsWeb) {
      print('_downloadOnWeb should only be called on web platform');
      return false;
    }
    
    try {
      // Ensure fileName has proper extension
      if (!fileName.endsWith('.webm') && 
          !fileName.endsWith('.m4a') && 
          !fileName.endsWith('.mp3')) {
        fileName = '$fileName.webm';
      }

      String downloadUrl;
      
      if (filePath.startsWith('data:')) {
        // Already a data URL, use directly
        downloadUrl = filePath;
      } else if (filePath.startsWith('blob:')) {
        // Blob URL, use directly
        downloadUrl = filePath;
      } else {
        // Regular path - shouldn't happen on web, but handle it
        print('Warning: Unexpected file path format on web: $filePath');
        return false;
      }

      // Create anchor element and trigger download
      final anchor = html.AnchorElement(href: downloadUrl)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      print('Download triggered for: $fileName');
      return true;
    } catch (e, stackTrace) {
      print('Error downloading on web: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }



  /// Convert data URL to temporary file (for mobile)
  Future<File?> _convertDataUrlToFile(String dataUrl, String fileName) async {
    try {
      // Parse data URL
      final uri = Uri.parse(dataUrl);
      final bytes = uri.data?.contentAsBytes();
      
      if (bytes == null) return null;

      // Create temp file
      final tempDir = await getTemporaryDirectory();
      final extension = fileName.contains('.') 
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.m4a';
      final tempFile = File('${tempDir.path}/share_$fileName$extension');

      // Write bytes to file
      await tempFile.writeAsBytes(bytes);
      
      return tempFile;
    } catch (e) {
      print('Error converting data URL to file: $e');
      return null;
    }
  }

  /// Share multiple audio files at once
  ///
  /// [filePaths] - List of file paths to share
  /// [message] - Optional message to include with shared files
  ///
  /// Returns true if share was initiated successfully
  Future<bool> shareMultipleAudios({
    required List<String> filePaths,
    String? message,
  }) async {
    try {
      if (filePaths.isEmpty) return false;

      // On web, download each file separately
      if (kIsWeb) {
        for (int i = 0; i < filePaths.length; i++) {
          final fileName = 'recording_${i + 1}.webm';
          await _downloadOnWeb(filePaths[i], fileName);
          // Small delay between downloads
          await Future.delayed(const Duration(milliseconds: 500));
        }
        return true;
      }

      // Mobile: Create XFiles from paths
      final xFiles = <XFile>[];
      for (final path in filePaths) {
        if (path.startsWith('data:')) {
          final tempFile = await _convertDataUrlToFile(
            path,
            'recording_${DateTime.now().millisecondsSinceEpoch}',
          );
          if (tempFile != null) {
            xFiles.add(XFile(tempFile.path));
          }
        } else {
          final file = File(path);
          if (await file.exists()) {
            xFiles.add(XFile(path));
          }
        }
      }

      if (xFiles.isEmpty) {
        print('No valid files to share');
        return false;
      }

      // Share all files
      final result = await Share.shareXFiles(
        xFiles,
        text: message ?? 'Shared recordings',
      );

      return result.status == ShareResultStatus.success;
    } catch (e, stackTrace) {
      print('Error sharing multiple audios: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Share audio with custom text/description
  ///
  /// Useful for including transcript or summary with the audio
  Future<bool> shareAudioWithDescription({
    required String filePath,
    required String fileName,
    required String description,
  }) async {
    try {
      // On web, just download (can't include description with download)
      if (kIsWeb) {
        return await _downloadOnWeb(filePath, fileName);
      }

      // Mobile: Handle data URLs
      if (filePath.startsWith('data:')) {
        final tempFile = await _convertDataUrlToFile(filePath, fileName);
        if (tempFile == null) {
          print('Failed to convert data URL to file');
          return false;
        }
        filePath = tempFile.path;
      }

      // Verify file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return false;
      }

      final xFile = XFile(filePath);

      final result = await Share.shareXFiles(
        [xFile],
        text: description,
        subject: fileName,
      );

      return result.status == ShareResultStatus.success;
    } catch (e, stackTrace) {
      print('Error sharing audio with description: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
}

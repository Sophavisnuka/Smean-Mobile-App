import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/models/profile_image_result.dart';
import 'package:smean_mobile_app/service/auth_service.dart';

/// Service for managing user profile operations including image handling
class ProfileService {
  final AppDatabase _database;
  late final AuthService _authService;

  ProfileService(this._database) {
    _authService = AuthService(_database);
  }

  /// Pick an image from the specified source (returns path for review)
  Future<ProfileImageResult> pickImageForReview(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        source: source,
      );

      if (pickedFile == null) {
        return ProfileImageResult(success: false, cancelled: true);
      }

      return ProfileImageResult(success: true, imagePath: pickedFile.path);
    } catch (e) {
      return ProfileImageResult(success: false, error: e.toString());
    }
  }

  /// Save the reviewed/cropped image to profile
  Future<ProfileImageResult> saveReviewedImage(
    String userId,
    String imagePath,
  ) async {
    try {
      // Delete old profile images for this user (mobile only)
      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profile_pictures');
        if (await profileDir.exists()) {
          final files = await profileDir.list().toList();
          for (var file in files) {
            if (file is File && file.path.contains('profile_$userId')) {
              try {
                await file.delete();
              } catch (_) {
                // Ignore errors when deleting old files
              }
            }
          }
        }
      }

      final String imageData;
      if (kIsWeb) {
        imageData = await _processWebImageFromPath(imagePath);
      } else {
        imageData = await _processMobileImageFromPath(imagePath, userId);
      }

      await _authService.repo.editProfile(userId, imageData);

      return ProfileImageResult(success: true, imagePath: imageData);
    } catch (e) {
      return ProfileImageResult(success: false, error: e.toString());
    }
  }

  /// Process image from existing file path
  Future<String> _processMobileImageFromPath(
    String imagePath,
    String userId,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_pictures');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    // Add timestamp to filename to ensure cache invalidation on update
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'profile_${userId}_$timestamp${path.extension(imagePath)}';
    final saveImage = File('${profileDir.path}/$fileName');
    await File(imagePath).copy(saveImage.path);

    return saveImage.path;
  }

  /// Process image for web platform (convert to base64)
  Future<String> _processWebImageFromPath(String imagePath) async {
    final pickedFile = XFile(imagePath);
    final bytes = await pickedFile.readAsBytes();
    final extension = pickedFile.path.split('.').last;
    return 'data:image/$extension;base64,${base64Encode(bytes)}';
  }

  /// Remove user profile picture
  Future<bool> removeProfilePicture(
    String userId,
    String? currentImagePath,
  ) async {
    try {
      // Delete file if exists (mobile only)
      if (!kIsWeb && currentImagePath != null) {
        if (!currentImagePath.startsWith('data:image')) {
          final file = File(currentImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Update database - set to null to remove
      await _authService.repo.editProfile(userId, null);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update username
  Future<bool> updateUsername(String userId, String newUsername) async {
    try {
      await _authService.repo.editUsername(userId, newUsername);
      return true;
    } catch (e) {
      return false;
    }
  }
}

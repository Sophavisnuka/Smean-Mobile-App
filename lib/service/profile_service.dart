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

  /// Pick an image from the specified source and update user profile
  Future<ProfileImageResult> pickAndSaveImage(
    String userId,
    ImageSource source,
  ) async {
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

      final imageData = await _processImage(pickedFile, userId);
      await _authService.repo.editProfile(userId, imageData);

      return ProfileImageResult(success: true, imagePath: imageData);
    } catch (e) {
      return ProfileImageResult(success: false, error: e.toString());
    }
  }

  /// Process image based on platform (web vs mobile)
  Future<String> _processImage(XFile pickedFile, String userId) async {
    if (kIsWeb) {
      return await _processWebImage(pickedFile);
    } else {
      return await _processMobileImage(pickedFile, userId);
    }
  }

  /// Process image for web platform (convert to base64)
  Future<String> _processWebImage(XFile pickedFile) async {
    final bytes = await pickedFile.readAsBytes();
    final extension = pickedFile.path.split('.').last;
    return 'data:image/$extension;base64,${base64Encode(bytes)}';
  }

  /// Process image for mobile platform (save to app directory)
  Future<String> _processMobileImage(XFile pickedFile, String userId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_pictures');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final fileName = 'profile_$userId${path.extension(pickedFile.path)}';
    final saveImage = File('${profileDir.path}/$fileName');
    await File(pickedFile.path).copy(saveImage.path);

    return saveImage.path;
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

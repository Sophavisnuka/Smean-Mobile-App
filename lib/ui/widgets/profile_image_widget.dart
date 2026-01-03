import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    required this.imagePath,
    required this.size,
  });

  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return Image.asset(
        'assets/images/Elite.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    // Check if it's base64 (web) or file path (mobile)
    if (imagePath!.startsWith('data:image')) {
      // Web: base64 data URL
      try {
        final base64String = imagePath!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Image.asset(
            'assets/images/Elite.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return Image.asset(
          'assets/images/Elite.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    } else {
      // Mobile: file path (don't use on web)
      if (kIsWeb) {
        // Fallback for web if path doesn't start with data:image
        return Image.asset(
          'assets/images/Elite.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }

      return Image.file(
        File(imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/Elite.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}

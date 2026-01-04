import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/widgets/profile_image_widget.dart';

/// A widget that displays user profile header with image, name, and email
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.imagePath,
    required this.username,
    required this.email,
    this.onImageTap,
  });

  final String? imagePath;
  final String username;
  final String email;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Profile Picture
        GestureDetector(
          onTap: onImageTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: ProfileImageWidget(imagePath: imagePath, size: 100),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Username
        Text(
          username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        // Email
        Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),

        const SizedBox(height: 32),
      ],
    );
  }
}

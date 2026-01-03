import 'package:flutter/material.dart';

class ProfilePictureSheet extends StatelessWidget {
  const ProfilePictureSheet({
    super.key,
    required this.isKhmer,
    required this.hasPhoto,
    required this.onTakePhoto,
    required this.onChooseGallery,
    required this.onRemovePhoto,
  });

  final bool isKhmer;
  final bool hasPhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseGallery;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(isKhmer ? 'ថតរូប' : 'Take Photo'),
            onTap: onTakePhoto,
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(isKhmer ? 'ជ្រើសពីវិចិត្រសាល' : 'Choose from Gallery'),
            onTap: onChooseGallery,
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                isKhmer ? 'លុបរូបភាព' : 'Remove Photo',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: onRemovePhoto,
            ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';

/// Dialog for reviewing and cropping profile images
/// Allows users to zoom, pan, rotate and crop images in a circular frame
class ImageReviewDialog extends StatefulWidget {
  const ImageReviewDialog({
    super.key,
    required this.imagePath,
    required this.isKhmer,
    required this.onConfirm,
    required this.onCancel,
  });

  final String imagePath;
  final bool isKhmer;
  final Function(String croppedPath) onConfirm;
  final VoidCallback onCancel;

  @override
  State<ImageReviewDialog> createState() => _ImageReviewDialogState();
}

class _ImageReviewDialogState extends State<ImageReviewDialog> {
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final isEditingSupported =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.crop, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.isKhmer ? 'កែសម្រួលរូបភាព' : 'Edit Image',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Preview
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: kIsWeb
                          ? Image.network(
                              _currentImagePath,
                              key: ValueKey(_currentImagePath), // Force refresh
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_currentImagePath),
                              key: ValueKey(_currentImagePath), // Force refresh
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info text
                  Text(
                    isEditingSupported
                        ? (widget.isKhmer
                              ? 'ចុចកែសម្រួលដើម្បីកាត់ និងសម្រួលរូបភាព'
                              : 'Tap Edit to crop and adjust your image')
                        : (widget.isKhmer
                              ? 'ការកែសម្រួលមិនត្រូវបានគាំទ្រលើវេទិកានេះទេ'
                              : 'Editing is not supported on this platform'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isEditingSupported ? _openCropper : null,
                      icon: const Icon(Icons.edit),
                      label: Text(widget.isKhmer ? 'កែសម្រួល' : 'Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(widget.isKhmer ? 'បោះបង់' : 'Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Confirm Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => widget.onConfirm(_currentImagePath),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(widget.isKhmer ? 'បញ្ជាក់' : 'Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCropper() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentImagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: widget.isKhmer ? 'កែសម្រួលរូបភាព' : 'Edit Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
          hideBottomControls: false,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: widget.isKhmer ? 'កែសម្រួលរូបភាព' : 'Edit Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _currentImagePath = croppedFile.path;
      });
    }
  }
}

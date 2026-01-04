import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/widgets/upload/file_format_info.dart';

/// A widget that displays the upload area with drag-and-drop support
class UploadAreaWidget extends StatelessWidget {
  const UploadAreaWidget({
    super.key,
    required this.isKhmer,
    required this.isDragging,
    required this.onSelectFile,
  });

  final bool isKhmer;
  final bool isDragging;
  final VoidCallback onSelectFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload area with drag-and-drop indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDragging
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: isDragging
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: Icon(
                isDragging ? Icons.file_download : Icons.cloud_upload_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              isKhmer ? 'បញ្ចូលឯកសារសម្លេងរបស់អ្នក' : 'Upload Your Audio File',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              isKhmer
                  ? 'ជ្រើសរើសឯកសារសម្លេងពីឧបករណ៍​របស់អ្នកដើម្បីបម្លែងវាទៅជា​អត្ថបទ'
                  : 'Select an audio file from your device to convert it into a transcript.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            if (isDragging) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Text(
                  isKhmer ? 'ទម្លាក់ឯកសារនៅទីនេះ' : 'Drop file here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),

            // Upload button
            ElevatedButton.icon(
              onPressed: onSelectFile,
              icon: const Icon(Icons.audio_file, size: 24),
              label: Text(
                isKhmer ? 'ជ្រើសរើសឯកសារ' : 'Select File',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(250, 56),
              ),
            ),

            const SizedBox(height: 16),

            // Drag and drop hint (only on desktop)
            if (!kIsWeb &&
                (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
              Text(
                isKhmer
                    ? 'ឬអូសនិងទម្លាក់ឯកសារនៅទីនេះ'
                    : 'Or drag and drop a file here',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),

            const SizedBox(height: 24),

            // Info text
            FileFormatInfo(isKhmer: isKhmer),
          ],
        ),
      ),
    );
  }
}

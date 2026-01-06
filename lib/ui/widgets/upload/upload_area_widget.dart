import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:smean_mobile_app/ui/widgets/upload/file_format_info.dart';

/// A widget that displays the upload area with drag-and-drop support
class UploadAreaWidget extends StatelessWidget {
  const UploadAreaWidget({
    super.key,
    required this.isKhmer,
    required this.isDragging,
    required this.onSelectFile,
    this.primaryColor = const Color(0xFF0DB2AC),
    this.secondaryColor = const Color(0xFF4FE2D2),
    this.pulseAnimation,
    this.reduceMotion = false,
  });

  final bool isKhmer;
  final bool isDragging;
  final VoidCallback onSelectFile;
  final Color primaryColor;
  final Color secondaryColor;
  final Animation<double>? pulseAnimation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final pulseValue = reduceMotion ? 0.0 : (pulseAnimation?.value ?? 0.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload area with drag-and-drop indicator
            AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondaryColor.withOpacity(isDragging ? 0.32 : 0.18),
                    primaryColor.withOpacity(isDragging ? 0.22 : 0.12),
                  ],
                ),
                border: Border.all(
                  color: primaryColor.withOpacity(isDragging ? 0.8 : 0.55),
                  width: isDragging ? 2.6 : 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18 + 0.18 * pulseValue),
                    blurRadius: 30 + (10 * pulseValue),
                    spreadRadius: 4 + (4 * pulseValue),
                  ),
                ],
              ),
              child: Icon(
                isDragging ? Icons.file_download : Icons.cloud_upload_outlined,
                size: 82,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              isKhmer ? 'បញ្ចូលឯកសារសម្លេងរបស់អ្នក' : 'Upload your audio file',
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isKhmer
                  ? 'ជ្រើស ឬអូសទម្លាក់ ហើយពិនិត្យមើលមុនរក្សាទុក'
                  : 'Choose or drag a file, preview it, then save.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            if (isDragging) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 1.6),
                ),
                child: Text(
                  isKhmer ? 'ទម្លាក់ឯកសារនៅទីនេះ' : 'Drop file here',
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 38),

            AnimatedScale(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              scale: 1 + (pulseValue * 0.04),
              child: ElevatedButton.icon(
                onPressed: onSelectFile,
                icon: const Icon(Icons.audio_file_rounded, size: 24),
                label: Text(
                  isKhmer ? 'ជ្រើសរើសឯកសារ' : 'Select file',
                  style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(260, 56),
                  elevation: 0,
                  shadowColor: primaryColor.withOpacity(
                    0.25 + 0.15 * pulseValue,
                  ),
                  overlayColor: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (!kIsWeb &&
                (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
              Text(
                isKhmer
                    ? 'ឬអូសនិងទម្លាក់ឯកសារនៅទីនេះ'
                    : 'Or drag and drop a file here',
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

            const SizedBox(height: 20),

            FileFormatInfo(isKhmer: isKhmer),
          ],
        ),
      ),
    );
  }
}

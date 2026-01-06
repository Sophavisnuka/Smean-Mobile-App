import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/file_validation_util.dart';

/// A widget that displays information about supported file formats
class FileFormatInfo extends StatelessWidget {
  const FileFormatInfo({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0DB2AC);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary.withOpacity(0.9)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              FileValidationUtil.getSupportedFormatsDisplay(isKhmer),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

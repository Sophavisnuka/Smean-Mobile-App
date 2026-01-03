import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/file_validation_util.dart';

/// A widget that displays information about supported file formats
class FileFormatInfo extends StatelessWidget {
  const FileFormatInfo({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              FileValidationUtil.getSupportedFormatsDisplay(isKhmer),
              style: TextStyle(color: Colors.blue[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

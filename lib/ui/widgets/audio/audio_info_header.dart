import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';

/// A widget that displays audio information header with title, date, and icon
class AudioInfoHeader extends StatelessWidget {
  const AudioInfoHeader({
    super.key,
    required this.title,
    required this.formattedDate,
    this.onEdit,
  });

  final String title;
  final String formattedDate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Icon(Icons.edit, size: 20, color: AppColors.primary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_mic_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_upload_icon.dart';

/// A widget that displays audio information header with title, date, and icon
class AudioInfoHeader extends StatelessWidget {
  const AudioInfoHeader({
    super.key,
    required this.title,
    required this.formattedDate,
    this.sourceType,
    this.onEdit,
  });

  final String title;
  final String formattedDate;
  final String? sourceType;
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
          child: Center(
            child: (sourceType?.toLowerCase() == 'uploaded')
                ? ItshoverUploadIcon(
                    color: Colors.white,
                    size: 30,
                    animate: true,
                  )
                : ItshoverMicIcon(color: Colors.white, size: 30, animate: true),
          ),
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

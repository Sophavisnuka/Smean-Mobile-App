import 'package:flutter/material.dart';

/// Section header with title and optional action icon
class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.onIconPressed,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onIconPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (icon != null && onIconPressed != null)
          IconButton(
            icon: Icon(icon, color: iconColor ?? Colors.grey, size: 28),
            onPressed: onIconPressed,
          ),
      ],
    );
  }
}

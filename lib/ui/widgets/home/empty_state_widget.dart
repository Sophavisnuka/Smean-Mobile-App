import 'package:flutter/material.dart';

/// Generic empty state widget with customizable message
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.fontSize = 18,
    this.color,
  });

  final String message;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: fontSize, color: color ?? Colors.grey[600]),
      ),
    );
  }
}

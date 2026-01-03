import 'package:flutter/material.dart';

/// A reusable dialog for delete confirmation
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.isKhmer,
    required this.title,
    required this.message,
  });

  final bool isKhmer;
  final String title;
  final String message;

  /// Shows the delete confirmation dialog
  /// Returns true if user confirms, false or null if cancelled
  static Future<bool?> show(
    BuildContext context, {
    required bool isKhmer,
    String? title,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        isKhmer: isKhmer,
        title: title ?? (isKhmer ? 'លុបកំណត់ត្រា' : 'Delete Recording'),
        message:
            message ??
            (isKhmer
                ? 'តើអ្នកប្រាកដថាចង់លុបកំណត់ត្រានេះទេ?'
                : 'Are you sure you want to delete this recording?'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            isKhmer ? 'លុប' : 'Delete',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

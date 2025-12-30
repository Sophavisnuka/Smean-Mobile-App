import 'package:flutter/material.dart';

class ShowConfirmDialog extends StatelessWidget {
  const ShowConfirmDialog({super.key, required this.cancelText, required this.confirmText, required this.titleText});
  final String titleText;
  final String confirmText;
  final String cancelText;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText)
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText)
        ),
      ],
    );
  }
}
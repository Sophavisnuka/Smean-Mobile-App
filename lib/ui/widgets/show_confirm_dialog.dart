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

class ShowInputDialog extends StatefulWidget {
  final String titleText;
  final String hintText;
  final String cancelText;
  final String confirmText;
  final String? initialValue;
  final int? maxLength;

  const ShowInputDialog({
    super.key,
    required this.titleText,
    required this.hintText,
    this.cancelText = 'Cancel',
    this.confirmText = 'Save',
    this.initialValue,
    this.maxLength,
  });

  @override
  State<ShowInputDialog> createState() => _ShowInputDialogState();
}

class _ShowInputDialogState extends State<ShowInputDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleText),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          errorText: _errorText,
        ),
        onChanged: (value) {
          if (_errorText != null && value.trim().isNotEmpty) {
            setState(() {
              _errorText = null;
            });
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) {
              setState(() {
                _errorText = "Title can't be empty";
              });
              return;
            }
            Navigator.pop(context, text);
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
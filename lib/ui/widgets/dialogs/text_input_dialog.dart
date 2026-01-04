import 'package:flutter/material.dart';

/// A reusable dialog for text input
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    this.initialValue = '',
    this.validator,
  });

  final String title;
  final String hintText;
  final String initialValue;
  final String? Function(String?)? validator;

  /// Shows the dialog and returns the entered text or null if cancelled
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hintText,
    String initialValue = '',
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => TextInputDialog(
        title: title,
        hintText: hintText,
        initialValue: initialValue,
        validator: validator,
      ),
    );
  }

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _controller;
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

  void _handleSubmit() {
    final value = _controller.text.trim();

    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }

    if (value.isEmpty) {
      setState(() {
        _errorText = 'This field cannot be empty';
      });
      return;
    }

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: _errorText,
        ),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        onSubmitted: (_) => _handleSubmit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSubmit, child: const Text('Save')),
      ],
    );
  }
}

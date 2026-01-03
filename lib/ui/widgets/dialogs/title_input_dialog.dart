import 'package:flutter/material.dart';

/// A reusable dialog for inputting a title
class TitleInputDialog extends StatefulWidget {
  const TitleInputDialog({
    super.key,
    required this.isKhmer,
    this.initialValue = '',
  });

  final bool isKhmer;
  final String initialValue;

  /// Shows the dialog and returns the entered title or null if cancelled
  static Future<String?> show(
    BuildContext context, {
    required bool isKhmer,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          TitleInputDialog(isKhmer: isKhmer, initialValue: initialValue),
    );
  }

  @override
  State<TitleInputDialog> createState() => _TitleInputDialogState();
}

class _TitleInputDialogState extends State<TitleInputDialog> {
  late final TextEditingController _controller;

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
      title: Text(widget.isKhmer ? 'រក្សាទុកឯកសារ' : 'Save File'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.isKhmer ? 'បញ្ចូលចំណងជើង' : 'Enter title',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.isKhmer ? 'បោះបង់' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(context, title);
          },
          child: Text(widget.isKhmer ? 'រក្សាទុក' : 'Save'),
        ),
      ],
    );
  }
}

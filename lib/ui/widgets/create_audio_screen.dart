import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:smean_mobile_app/data/models/audio_class.dart';

class CreateAudioScreen extends StatefulWidget {
  const CreateAudioScreen({super.key});

  @override
  State<CreateAudioScreen> createState() => _CreateAudioScreenState();
}

class _CreateAudioScreenState extends State<CreateAudioScreen> {
  final _titleCtrl = TextEditingController();
  bool _saving = false;

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    final record = AudioRecord(
      audioId: const Uuid().v4(),
      audioTitle: title,
      createdAt: DateTime.now(),
      filePath: '',
      duration: 0,
      sourceType: 'recorded',
    );

    Navigator.pop(context, record);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Audio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Audio title',
                hintText: 'Enter title',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/service/record_audio_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late RecordAudioService _audioService;

  Future<void> _saveToHome() async {
    if (_audioService.recordedFilePath == null) return;

    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save recording'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(context, t);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (title == null) return;

    final record = AudioRecord(
      audioId: 'a_${DateTime.now().millisecondsSinceEpoch}',
      filePath: _audioService.recordedFilePath!,
      audioTitle: title,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    Navigator.pop(context, record); //return to HomeScreen
  }

  @override
  void initState() {
    super.initState();
    _audioService = RecordAudioService();
    _audioService.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  Future<void> _handleRecordingToggle() async {
    if (_audioService.isRecording) {
      await _audioService.stopRecording();
    } else {
      final success = await _audioService.startRecording();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Text(isKhmer ? 'កំណត់ត្រា' : 'Record'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Display
            Text(
              _audioService.isRecording
                  ? _audioService.formatDuration(_audioService.elapsed)
                  : _audioService.recordedFilePath != null
                  ? _audioService.formatDuration(_audioService.playPosition)
                  : '00:00',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            if (_audioService.recordedFilePath != null && !_audioService.isRecording) ...[
              const SizedBox(height: 20),
              Slider(
                value: _audioService.playPosition.inSeconds.toDouble(),
                max: _audioService.totalDuration.inSeconds.toDouble() > 0
                    ? _audioService.totalDuration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) async {
                  await _audioService.seekTo(Duration(seconds: value.toInt()));
                },
              ),
              Text(
                '${_audioService.formatDuration(_audioService.playPosition)} / ${_audioService.formatDuration(_audioService.totalDuration)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],

            const SizedBox(height: 40),

            Center(
              child: GestureDetector(
                onTap: _handleRecordingToggle,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: _audioService.isRecording ? Colors.red : Colors.grey[300],
                  child: Icon(
                    _audioService.isRecording ? Icons.stop : Icons.mic,
                    color: _audioService.isRecording ? Colors.white : Colors.black,
                    size: 48,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              _audioService.isRecording
                  ? (isKhmer ? 'កំពុងថតសម្លេង...' : 'Recording...')
                  : _audioService.recordedFilePath != null
                  ? (isKhmer ? 'ថតរួច' : 'Recording saved')
                  : (isKhmer
                        ? 'ចុចដើម្បីចាប់ផ្តើមថត'
                        : 'Tap to start recording'),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),

            if (_audioService.recordedFilePath != null && !_audioService.isRecording) ...[
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause button
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      _audioService.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: _audioService.togglePlayback,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  // Stop button
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.stop_circle),
                    onPressed: _audioService.stopPlayback,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 20),
                  // Delete button
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.delete),
                    onPressed: _audioService.deleteRecording,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveToHome,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

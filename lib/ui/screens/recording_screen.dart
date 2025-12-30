import 'dart:async';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool isRecording = false;
  Duration elapsed = Duration.zero;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? recordedFilePath;
  Timer? _timer;

  Future<bool> _requeestPermission() async {
    final status = await Permission.microphone.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Microphone permission is required to record audio.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _requeestPermission();
    if (!hasPermission) return;

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(), path: filePath);

    setState(() {
      isRecording = true;
      elapsed = Duration.zero;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsed = Duration(seconds: timer.tick);
      });
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    final path = await _recorder.stop();

    setState(() {
      isRecording = false;
      recordedFilePath = path;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDuration(elapsed),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: () {
                if (isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: CircleAvatar(
                radius: 48,
                backgroundColor: isRecording ? Colors.red : Colors.grey[300],
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.white : Colors.black,
                  size: 48,
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Text(
            isRecording ? 'Recording...' : 'Tap to start recording',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

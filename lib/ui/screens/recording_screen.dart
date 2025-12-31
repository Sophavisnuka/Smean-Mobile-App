import 'dart:async';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  bool isPlaying = false;
  Duration playPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Future<void> _saveToHome() async {
    if (recordedFilePath == null) return;

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
      filePath: recordedFilePath!, // mobile path OR web blob url (MVP)
      audioTitle: title,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    Navigator.pop(context, record); // ✅ return to HomeScreen
  }

  @override
  void initState() {
    super.initState();

    // Listen when player state changes (playing/pause/stopped)
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to playback position (updates every second)
    _player.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          playPosition = position;
        });
      }
    });

    // Listen to audio duration when loaded
    _player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });
  }
  

  // Ask for microphone access from user Device
  // Future<bool> _requeestPermission() async {
  //   final status = await Permission.microphone.request();

  //   if (!status.isGranted) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Microphone permission is required to record audio.'),
  //         ),
  //       );
  //     }
  //     return false;
  //   }
  //   return true;
  // }
  Future<bool> _requeestPermission() async {
    final ok = await _recorder.hasPermission();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
    }
    return ok;
  }

  // Future<void> _startRecording() async {
  //   // Check if user give microphone access
  //   final hasPermission = await _requeestPermission();
  //   if (!hasPermission) return;

  //   // Createa a directory and path to store in user private device storage
  //   final directory = await getApplicationDocumentsDirectory();
  //   final filePath =
  //       '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

  //   await _recorder.start(const RecordConfig(), path: filePath);

  //   if (mounted) {
  //     setState(() {
  //       isRecording = true;
  //       elapsed = Duration.zero;
  //     });
  //   }

  //   // Change the timer to start count
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (mounted) {
  //       setState(() {
  //         elapsed = Duration(seconds: timer.tick);
  //       });
  //     }
  //   });
  // }
  Future<void> _startRecording() async {
    final hasPermission = await _requeestPermission();
    if (!hasPermission) return;

    if (kIsWeb) {
      // Web: don’t pass a path. Use a web encoder.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.opus, // best for web
        ), path: '',
      );
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // matches .m4a better
        ),
        path: filePath,
      );
    }

    if (mounted) {
      setState(() {
        isRecording = true;
        elapsed = Duration.zero;
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => elapsed = Duration(seconds: timer.tick));
      }
    });
  }

  // Stop the recorder
  // Future<void> _stopRecording() async {
  //   _timer?.cancel();

  //   final path = await _recorder.stop();

  //   if (mounted) {
  //     setState(() {
  //       isRecording = false;
  //       recordedFilePath = path;
  //     });
  //   }
  // }
  Future<void> _stopRecording() async {
    _timer?.cancel();
    final pathOrUrl = await _recorder.stop(); // mobile: path, web: blob url

    if (mounted) {
      setState(() {
        isRecording = false;
        recordedFilePath = pathOrUrl;
      });
    }
  }

  // Future<void> _togglePlayback() async {
  //   if (recordedFilePath == null) return; // No record to play

  //   if (isPlaying) {
  //     await _player.pause();
  //   } else {
  //     await _player.play(DeviceFileSource(recordedFilePath!));
  //   }
  // }
  Future<void> _togglePlayback() async {
    if (recordedFilePath == null) return;

    if (isPlaying) {
      await _player.pause();
    } else {
      if (kIsWeb) {
        await _player.play(UrlSource(recordedFilePath!)); // blob url
      } else {
        await _player.play(DeviceFileSource(recordedFilePath!)); // file path
      }
    }
  }

  Future<void> _stopPlayback() async {
    await _player.stop();

    if (mounted) {
      setState(() {
        playPosition = Duration.zero;
      });
    }
  }

  Future<void> _deleteRecording() async {
    await _stopPlayback();
    if (mounted) {
      setState(() {
        recordedFilePath = null;
        elapsed = Duration.zero;
        playPosition = Duration.zero;
        totalDuration = Duration.zero;
      });
    }
  }

  // Duration timer count format
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
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
              isRecording
                  ? _formatDuration(elapsed)
                  : recordedFilePath != null
                  ? _formatDuration(playPosition)
                  : '00:00',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            if (recordedFilePath != null && !isRecording) ...[
              SizedBox(height: 20),
              Slider(
                value: playPosition.inSeconds.toDouble(),
                max: totalDuration.inSeconds.toDouble() > 0
                    ? totalDuration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) async {
                  await _player.seek(Duration(seconds: value.toInt()));
                },
              ),
              Text(
                '${_formatDuration(playPosition)} / ${_formatDuration(totalDuration)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],

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
              isRecording
                  ? (isKhmer ? 'កំពុងថតសម្លេង...' : 'Recording...')
                  : recordedFilePath != null
                  ? (isKhmer ? 'ថតរួច' : 'Recording saved')
                  : (isKhmer
                        ? 'ចុចដើម្បីចាប់ផ្តើមថត'
                        : 'Tap to start recording'),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),

            if (recordedFilePath != null && !isRecording) ...[
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause button
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: _togglePlayback,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 20),
                  // Stop button
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.stop_circle),
                    onPressed: _stopPlayback,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 20),
                  // Delete button
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.delete),
                    onPressed: _deleteRecording,
                    color: Colors.red,
                  ),
                ],
              ),
                if (recordedFilePath != null && !isRecording) ...[
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
          ],
        ),
      ),
    );
  }
}

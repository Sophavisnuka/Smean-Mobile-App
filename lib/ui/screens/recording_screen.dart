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
            // Just a placeholder timer
            "00:00",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: () {
                
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
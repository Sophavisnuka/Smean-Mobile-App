import 'package:flutter/material.dart';

/// Main recording button widget with record/stop states
class RecordingButtonWidget extends StatelessWidget {
  const RecordingButtonWidget({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.radius = 48,
  });

  final bool isRecording;
  final VoidCallback onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: isRecording ? Colors.red : Colors.grey[300],
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: isRecording ? Colors.white : Colors.black,
          size: radius,
        ),
      ),
    );
  }
}

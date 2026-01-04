import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';

/// Widget that displays the recording or playback timer
class RecordingTimerWidget extends StatelessWidget {
  const RecordingTimerWidget({
    super.key,
    required this.duration,
    this.fontSize = 48,
  });

  final Duration duration;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(duration),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}

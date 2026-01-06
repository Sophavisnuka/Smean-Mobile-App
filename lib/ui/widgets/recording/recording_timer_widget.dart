import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';

/// Widget that displays the recording or playback timer
class RecordingTimerWidget extends StatelessWidget {
  const RecordingTimerWidget({
    super.key,
    required this.duration,
    this.fontSize = 48,
    this.textStyle,
    this.textAlign = TextAlign.center,
  });

  final Duration duration;
  final double fontSize;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(duration),
      textAlign: textAlign,
      style:
          textStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
    );
  }
}

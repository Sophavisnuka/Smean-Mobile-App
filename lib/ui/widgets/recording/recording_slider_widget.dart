import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';

/// Slider widget for audio playback with time display
class RecordingSliderWidget extends StatelessWidget {
  const RecordingSliderWidget({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
  });

  final Duration currentPosition;
  final Duration totalDuration;
  final Function(Duration) onSeek;

  @override
  Widget build(BuildContext context) {
    final maxSeconds = totalDuration.inSeconds.toDouble();
    final currentSeconds = currentPosition.inSeconds.toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: currentSeconds,
          max: maxSeconds > 0 ? maxSeconds : 1,
          onChanged: (value) {
            onSeek(Duration(seconds: value.toInt()));
          },
        ),
        Text(
          '${formatDuration(currentPosition)} / ${formatDuration(totalDuration)}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

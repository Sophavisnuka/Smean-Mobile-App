import 'package:flutter/material.dart';

/// Playback controls widget with play/pause, stop, and delete buttons
class RecordingControlsWidget extends StatelessWidget {
  const RecordingControlsWidget({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onStop,
    required this.onDelete,
    this.iconSize = 48,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onDelete;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play/Pause button
        IconButton(
          iconSize: iconSize,
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
          onPressed: onPlayPause,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),

        // Stop button
        IconButton(
          iconSize: iconSize,
          icon: const Icon(Icons.stop_circle),
          onPressed: onStop,
          color: Colors.orange,
        ),
        const SizedBox(width: 20),

        // Delete button
        IconButton(
          iconSize: iconSize,
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
          color: Colors.red,
        ),
      ],
    );
  }
}

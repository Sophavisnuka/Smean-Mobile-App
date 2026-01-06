import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';
import 'package:smean_mobile_app/service/audio_playback_service.dart';

/// A reusable widget for audio playback with controls
class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard({
    super.key,
    required this.audioService,
    this.onStateChanged,
  });

  final AudioPlaybackService audioService;
  final VoidCallback? onStateChanged;

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  @override
  void initState() {
    super.initState();
    widget.audioService.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
      widget.onStateChanged?.call();
    };
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds =
        (widget.audioService.duration.inSeconds > 0
                ? widget.audioService.duration.inSeconds
                : 1)
            .toDouble();
    final valueSeconds = widget.audioService.position.inSeconds.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time and Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(widget.audioService.position),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: valueSeconds.clamp(0.0, maxSeconds).toDouble(),
                  min: 0.0,
                  max: maxSeconds,
                  onChanged: (v) async {
                    await widget.audioService.seek(
                      Duration(seconds: v.toInt()),
                    );
                  },
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              Text(
                formatDuration(widget.audioService.duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Play/Pause Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                widget.audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 36,
                color: Colors.white,
              ),
              onPressed: widget.audioService.togglePlayback,
            ),
          ),
        ],
      ),
    );
  }
}

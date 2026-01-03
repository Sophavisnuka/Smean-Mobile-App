import 'package:flutter/material.dart';
import 'package:smean_mobile_app/service/upload_audio_service.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';

class AudioFilePreviewDialog extends StatefulWidget {
  final UploadAudioService audioService;
  final bool isKhmer;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const AudioFilePreviewDialog({
    super.key,
    required this.audioService,
    required this.isKhmer,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<AudioFilePreviewDialog> createState() => _AudioFilePreviewDialogState();
}

class _AudioFilePreviewDialogState extends State<AudioFilePreviewDialog> {
  @override
  void initState() {
    super.initState();
    widget.audioService.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.audio_file, color: Colors.blue[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isKhmer ? 'ព័ត៌មានឯកសារ' : 'File Details',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),

            const Divider(height: 32),

            // File Name
            _buildInfoRow(
              Icons.description,
              widget.isKhmer ? 'ឈ្មោះ' : 'Name',
              widget.audioService.fileName ?? '',
            ),

            const SizedBox(height: 16),

            // File Size
            _buildInfoRow(
              Icons.data_usage,
              widget.isKhmer ? 'ទំហំ' : 'Size',
              widget.audioService.getFormattedFileSize(),
            ),

            const SizedBox(height: 16),

            // Duration
            _buildInfoRow(
              Icons.timer,
              widget.isKhmer ? 'រយៈពេល' : 'Duration',
              formatDuration(widget.audioService.totalDuration),
            ),

            const SizedBox(height: 24),

            // Audio Player Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Progress slider
                  Slider(
                    value: widget.audioService.playPosition.inSeconds
                        .toDouble(),
                    max:
                        widget.audioService.totalDuration.inSeconds.toDouble() >
                            0
                        ? widget.audioService.totalDuration.inSeconds.toDouble()
                        : 1,
                    onChanged: (value) async {
                      await widget.audioService.seekTo(
                        Duration(seconds: value.toInt()),
                      );
                    },
                  ),

                  // Time display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(widget.audioService.playPosition),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          formatDuration(widget.audioService.totalDuration),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause button
                      IconButton(
                        iconSize: 48,
                        icon: Icon(
                          widget.audioService.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: widget.audioService.togglePlayback,
                        color: Colors.blue[700],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isKhmer ? 'បោះបង់' : 'Cancel',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isKhmer ? 'បញ្ជាក់' : 'Confirm',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

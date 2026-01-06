import 'package:flutter/material.dart';
import 'package:smean_mobile_app/service/base_audio_service.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';

/// A reusable dialog for previewing audio files (both uploaded and recorded)
/// Shows file details, allows playback, requires title input before accepting
class AudioPreviewDialog extends StatefulWidget {
  final BaseAudioService audioService;
  final bool isKhmer;
  final String initialTitle;
  final VoidCallback onCancel;
  final Function(String title) onConfirm;

  const AudioPreviewDialog({
    super.key,
    required this.audioService,
    required this.isKhmer,
    this.initialTitle = '',
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<AudioPreviewDialog> createState() => _AudioPreviewDialogState();
}

class _AudioPreviewDialogState extends State<AudioPreviewDialog> {
  late final TextEditingController _titleController;
  bool _isTitleValid = false;
  VoidCallback? _previousListener;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _isTitleValid = widget.initialTitle.trim().isNotEmpty;

    _titleController.addListener(() {
      setState(() {
        _isTitleValid = _titleController.text.trim().isNotEmpty;
      });
    });

    _previousListener = widget.audioService.onStateChanged;
    widget.audioService.onStateChanged = () {
      _previousListener?.call();
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    widget.audioService.onStateChanged = _previousListener;
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Row(
                children: [
                  Icon(Icons.audio_file, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isKhmer ? 'ព័ត៌មានឯកសារ' : 'Audio Details',
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

              // Title Input Field
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: widget.isKhmer ? 'ចំណងជើង *' : 'Title *',
                  hintText: widget.isKhmer ? 'បញ្ចូលចំណងជើង' : 'Enter title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  errorText: _titleController.text.isNotEmpty && !_isTitleValid
                      ? (widget.isKhmer
                            ? 'ត្រូវការចំណងជើង'
                            : 'Title is required')
                      : null,
                ),
              ),

              const SizedBox(height: 24),

              // File Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // File Size (if available)
                    if (widget.audioService.fileSize != null) ...[
                      _buildInfoRow(
                        Icons.data_usage,
                        widget.isKhmer ? 'ទំហំ' : 'Size',
                        widget.audioService.getFormattedFileSize(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Duration
                    _buildInfoRow(
                      Icons.timer,
                      widget.isKhmer ? 'រយៈពេល' : 'Duration',
                      formatDuration(widget.audioService.totalDuration),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Audio Player Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.primary.withOpacity(0.18),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.20),
                        trackHeight: 5,
                      ),
                      child: Slider(
                        value: widget.audioService.playPosition.inSeconds
                            .clamp(
                              0,
                              widget.audioService.totalDuration.inSeconds,
                            )
                            .toDouble(),
                        max: widget.audioService.totalDuration.inSeconds > 0
                            ? widget.audioService.totalDuration.inSeconds
                                  .toDouble()
                            : 1,
                        onChanged: (value) async {
                          await widget.audioService.seekTo(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(widget.audioService.playPosition),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatDuration(widget.audioService.totalDuration),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            iconSize: 48,
                            icon: Icon(
                              widget.audioService.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                            ),
                            color: AppColors.primary,
                            onPressed: widget.audioService.togglePlayback,
                          ),
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
                      onPressed: _isTitleValid
                          ? () {
                              final title = _titleController.text.trim();
                              widget.onConfirm(title);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        widget.isKhmer ? 'រក្សាទុក' : 'Save',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

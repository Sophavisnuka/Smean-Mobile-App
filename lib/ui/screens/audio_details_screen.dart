import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/utils/formatting.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioDetailsScreen extends StatefulWidget {
  final AudioRecord audios;
  const AudioDetailsScreen({super.key, required this.audios});

  @override
  State<AudioDetailsScreen> createState() => _AudioDetailsScreenState();
}

class _AudioDetailsScreenState extends State<AudioDetailsScreen> {
  final AudioPlayer _player = AudioPlayer();
  final TranscriptService transcriptService = TranscriptService();
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String? transcriptText;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();

    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => isPlaying = (s == PlayerState.playing));
    });

    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => position = p);
    });

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => duration = d);
    });
  }

  Future<void> _togglePlay() async {
    final source = widget.audios.filePath;

    if (isPlaying) {
      await _player.pause();
      return;
    }

    // Web: filePath may be blob url, Mobile: file path
    if (kIsWeb) {
      await _player.play(UrlSource(source));
    } else {
      await _player.play(DeviceFileSource(source));
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => position = Duration.zero);
  }

  Future<void> _generateMockTranscript() async {
    if (isGenerating) return;

    setState(() {
      isGenerating = true;
    });

    try {
      final t = await transcriptService.generateMock(
        widget.audios.audioId,
        widget.audios.audioTitle,
      );

      if (!mounted) return;

      setState(() {
        transcriptText = t?.text ?? 'No transcript generated.';
        isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate transcript: $e')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy · hh:mm a').format(widget.audios.createdAt);
    final maxSeconds = (duration.inSeconds > 0 ? duration.inSeconds : 1).toDouble();
    final valueSeconds = position.inSeconds.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 36,
                    width: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Waveform',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(position), style: const TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: valueSeconds.clamp(0.0, maxSeconds).toDouble(),
                          min: 0.0,
                          max: maxSeconds,
                          onChanged: (v) async {
                            await _player.seek(Duration(seconds: v.toInt()));
                          },
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      Text(formatDuration(duration), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.audios.audioTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 20, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(formattedDate, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateMockTranscript,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.text_snippet, size: 20),
              label: Text(isGenerating ? 'Generating...' : 'Generate Transcript'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            if (transcriptText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.article_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Transcript',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => transcriptText = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transcriptText!,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.stop_circle, size: 32, color: AppColors.primary),
                  onPressed: _stop,
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlay,
                  ),
                ),
              ],
            ),
          ],
          
        ),
      ),
    );
  }
}

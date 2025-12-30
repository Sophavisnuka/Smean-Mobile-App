import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioDetailsScreen extends StatelessWidget {

  final AudioRecord audios;
  const AudioDetailsScreen({super.key, required this.audios});

  static const Duration _duration = Duration(minutes: 3, seconds: 42);
  static const Duration _currentPosition = Duration(seconds: 56);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy · hh:mm a').format(audios.createdAt);

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

            // Audio visual
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

                  // Waveform placeholder (no asset needed yet)
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
                      Text(_formatDuration(_currentPosition), style: const TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                          min: 0,
                          max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                          onChanged: (_) {
                            // later: seek
                          },
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title + edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    audios.audioTitle,
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
              onPressed: () {
                // later: transcribe
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transcribe clicked (static UI)')),
                );
              },
              icon: const Icon(Icons.text_snippet, size: 20),
              label: const Text('Generate Transcribe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, size: 32, color: AppColors.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 32, color: AppColors.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.play_arrow, size: 36, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 32, color: AppColors.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.forward_10, size: 32, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$m:$s";
  }
}

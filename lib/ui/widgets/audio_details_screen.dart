import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioDetailsScreen extends StatefulWidget {
  final CardModel card;
  const AudioDetailsScreen({super.key, required this.card});

  @override
  State<AudioDetailsScreen> createState() => _AudioDetailsScreenState();
}

class _AudioDetailsScreenState extends State<AudioDetailsScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String? transcriptText;
  String? summaryText;
  bool isGenerating = false;

  // Text editing controllers for editable fields
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _transcriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    transcriptText = widget.card.transcriptionText;

    // Initialize mock data
    summaryText =
        'This is a mock summary of the audio transcription. It provides a brief overview of the key points discussed in the recording. The summary captures the main ideas and essential information for quick reference.';

    // Set initial text for controllers
    _summaryController.text = summaryText ?? '';
    _transcriptController.text = transcriptText ?? '';

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

    _loadDuration();
  }

  Future<void> _loadDuration() async {
    final sourcePath = widget.card.audioFilePath ?? '';
    if (sourcePath.isEmpty) return;

    if (kIsWeb) {
      await _player.setSource(UrlSource(sourcePath));
    } else {
      await _player.setSource(DeviceFileSource(sourcePath));
    }

    // Try duration a few times in case metadata isn’t ready immediately
    Duration? d;
    for (int i = 0; i < 5 && d == null; i++) {
      d = await _player.getDuration();
      if (d == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    if (d != null && mounted) {
      final dur = d;
      setState(() => duration = dur);
    }
  }

  Future<void> _togglePlay() async {
    final source = widget.card.audioFilePath ?? '';

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

  @override
  void dispose() {
    _player.dispose();
    _summaryController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _deleteCard() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKhmer ? 'លុបកំណត់ត្រា' : 'Delete Recording'),
        content: Text(
          isKhmer
              ? 'តើអ្នកប្រាកដថាចង់លុបកំណត់ត្រានេះទេ?'
              : 'Are you sure you want to delete this recording?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isKhmer ? 'លុប' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Delete the card from database
      final db = Provider.of<AppDatabase>(context, listen: false);
      final audioRepo = AudioRepository(db);
      await audioRepo.deleteCard(widget.card.cardId);

      if (!mounted) return;

      // Navigate back after successful deletion
      Navigator.pop(context);
      CustomSnackBar.success(
        context,
        isKhmer ? 'លុបកំណត់ត្រាបានជោគជ័យ' : 'Recording deleted successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final formattedDate = DateFormat(
      'MMM dd, yyyy · hh:mm a',
    ).format(widget.card.createdAt);
    final maxSeconds = (duration.inSeconds > 0 ? duration.inSeconds : 1)
        .toDouble();
    final valueSeconds = position.inSeconds.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'ព័ត៌មានលម្អិត' : 'Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Audio Info Card and Player
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
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
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.card.cardName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(position),
                                style: const TextStyle(fontSize: 12),
                              ),
                              Expanded(
                                child: Slider(
                                  value: valueSeconds
                                      .clamp(0.0, maxSeconds)
                                      .toDouble(),
                                  min: 0.0,
                                  max: maxSeconds,
                                  onChanged: (v) async {
                                    await _player.seek(
                                      Duration(seconds: v.toInt()),
                                    );
                                  },
                                  activeColor: AppColors.primary,
                                  inactiveColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              Text(
                                formatDuration(duration),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
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
                  // Delete button at bottom right
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _deleteCard,
                      tooltip: isKhmer ? 'លុបកំណត់ត្រា' : 'Delete Details',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Summary Section (standout color, above transcription)
              if (summaryText != null) ...[
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade600, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.summarize,
                            size: 18,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isKhmer ? 'សង្ខេប' : 'Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Mock',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _summaryController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Full Transcription Section
              if (transcriptText != null) ...[
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 250),
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
                          Text(
                            isKhmer
                                ? 'អត្ថបទបម្លែងពេញលេញ'
                                : 'Full Transcription',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Mock',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _transcriptController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Highlight home as it's where we came from
        onTap: (index) {
          // Navigate back to main screen and switch to the tapped tab
          Navigator.pop(context);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: isKhmer ? 'ទំព័រដើម' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: isKhmer ? 'ស្វែងរក' : 'Search',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mic),
            label: isKhmer ? 'ថត' : 'Record',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.upload_file),
            label: isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: isKhmer ? 'គណនី' : 'Account',
          ),
        ],
      ),
    );
  }
}

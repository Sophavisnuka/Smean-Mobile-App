import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/service/audio_playback_service.dart';
import 'package:smean_mobile_app/service/mock_transcript_generator.dart';
import 'package:smean_mobile_app/service/export_audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/audio/audio_info_header.dart';
import 'package:smean_mobile_app/ui/widgets/audio/audio_player_card.dart';
import 'package:smean_mobile_app/ui/widgets/audio/summary_section.dart';
import 'package:smean_mobile_app/ui/widgets/audio/transcript_section.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

/// Screen that displays detailed information about an audio recording
class AudioDetailsScreen extends StatefulWidget {
  final CardModel card;

  const AudioDetailsScreen({super.key, required this.card});

  @override
  State<AudioDetailsScreen> createState() => _AudioDetailsScreenState();
}

class _AudioDetailsScreenState extends State<AudioDetailsScreen> {
  late AudioPlaybackService _audioService;
  late List<TranscriptSegment> _segments;
  int? _durationSeconds;
  final ExportAudioService _exportService = ExportAudioService();

  @override
  void initState() {
    super.initState();
    _audioService = AudioPlaybackService();

    _durationSeconds = widget.card.audioDuration;
    _segments = _buildSegments(_durationSeconds ?? 60);

    // Load audio
    _loadAudio();
  }

  List<TranscriptSegment> _buildSegments(int durationSeconds) {
    final safeDuration = durationSeconds <= 0 ? 1 : durationSeconds;
    return MockTranscriptGenerator.generateSegments(
      durationSeconds: safeDuration,
      seed: widget.card.cardId.hashCode,
    );
  }

  /// Load audio file
  Future<void> _loadAudio() async {
    final audioPath = widget.card.audioFilePath;
    if (audioPath == null || audioPath.isEmpty) return;

    await _audioService.loadAudio(audioPath);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _handleAudioStateChanged() {
    final newDuration = _audioService.duration.inSeconds;
    if (newDuration > 0 && newDuration != _durationSeconds) {
      setState(() {
        _durationSeconds = newDuration;
        _segments = _buildSegments(newDuration);
      });
    }
  }

  Future<void> _onSegmentTap(TranscriptSegment segment) async {
    await _audioService.seek(Duration(seconds: segment.startSeconds));
    if (!_audioService.isPlaying) {
      await _audioService.togglePlayback();
    }
  }

  /// Handle card deletion
  Future<void> _handleDelete() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final confirm = await DeleteConfirmationDialog.show(
      context,
      isKhmer: isKhmer,
    );

    if (confirm == true) {
      if (!mounted) return;

      try {
        final db = Provider.of<AppDatabase>(context, listen: false);
        final cardRepo = CardRepository(db);

        // Store card data for potential undo
        final deletedCard = widget.card;

        await cardRepo.deleteCard(widget.card.cardId);

        if (!mounted) return;

        // Pop the screen first and indicate deletion occurred
        Navigator.pop(context, true);

        // Show snackbar with undo
        CustomSnackBar.showWithAction(
          context,
          message: isKhmer
              ? 'លុបកំណត់ត្រាបានជោគជ័យ'
              : 'Recording deleted successfully',
          actionLabel: isKhmer ? 'មិនធ្វើវិញ' : 'UNDO',
          onAction: () async {
            // Restore the deleted card
            await cardRepo.createCard(
              userId: deletedCard.userId,
              cardName: deletedCard.cardName,
              audioFilePath: deletedCard.audioFilePath!,
              sourceType:
                  'recorded', // Default to recorded since we don't store this in CardModel
              audioDuration: deletedCard.audioDuration ?? 0,
              cardId: deletedCard.cardId,
              audioId: deletedCard.audioId!,
              isFavorite: deletedCard.isFavorite,
              createdAt: deletedCard.createdAt,
            );
            // Note: Transcript restoration would require navigating back or a callback
            // For now, undo only restores the card and audio
          },
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;

        CustomSnackBar.error(
          context,
          isKhmer ? 'មានបញ្ហាក្នុងការលុប' : 'Error deleting recording',
        );
      }
    }
  }

  /// Handle audio export/share
  Future<void> _handleExport() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final audioPath = widget.card.audioFilePath;
    if (audioPath == null || audioPath.isEmpty) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        isKhmer ? 'មិនមានឯកសារសម្លេង' : 'No audio file found',
      );
      return;
    }

    // Debug: Print file path
    print('Attempting to share audio from path: $audioPath');

    final success = await _exportService.shareAudio(
      filePath: audioPath,
      fileName: widget.card.cardName,
      subject: isKhmer
          ? 'សម្លេងថតចំណាំពី SMEAN'
          : 'Audio recording from SMEAN',
    );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.success(
        context,
        kIsWeb
            ? (isKhmer ? 'បានទាញយក' : 'Downloaded successfully')
            : (isKhmer ? 'បានចែករំលែក' : 'Shared successfully'),
      );
    } else {
      CustomSnackBar.error(
        context,
        isKhmer 
            ? 'មានបញ្ហាក្នុងការចែករំលែក'
            : 'Failed to share. Try again',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'ព័ត៌មានលម្អិត' : 'Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.additional,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(kIsWeb ? Icons.download_outlined : Icons.share_outlined),
            onPressed: _handleExport,
            tooltip: kIsWeb 
                ? (isKhmer ? 'ទាញយក' : 'Download')
                : (isKhmer ? 'ចែករំលែក' : 'Share'),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
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
                        // Audio Info Header
                        AudioInfoHeader(
                          title: widget.card.cardName,
                          formattedDate: formattedDate,
                          sourceType: widget.card.audioSourceType,
                        ),

                        const SizedBox(height: 16),

                        // Audio Player
                        AudioPlayerCard(
                          audioService: _audioService,
                          onStateChanged: _handleAudioStateChanged,
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _handleDelete,
                      tooltip: isKhmer ? 'លុបកំណត់ត្រា' : 'Delete Recording',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Summary Section
              ...[
                SummarySection(
                  isKhmer: isKhmer,
                  summaryText: MockTranscriptGenerator.summary(
                    isKhmer: isKhmer,
                  ),
                  showMockBadge: true,
                ),
                const SizedBox(height: 16),
              ],

              // Transcript Section
              if (_segments.isNotEmpty) ...[
                TranscriptSection(
                  isKhmer: isKhmer,
                  segments: _segments,
                  onSegmentTap: _onSegmentTap,
                  showMockBadge: true,
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

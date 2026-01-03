import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/service/audio_playback_service.dart';
import 'package:smean_mobile_app/ui/widgets/audio/audio_info_header.dart';
import 'package:smean_mobile_app/ui/widgets/audio/audio_player_card.dart';
import 'package:smean_mobile_app/ui/widgets/audio/summary_section.dart';
import 'package:smean_mobile_app/ui/widgets/audio/transcript_section.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/delete_confirmation_dialog.dart';

/// Screen that displays detailed information about an audio recording
class AudioDetailsScreen extends StatefulWidget {
  final CardModel card;

  const AudioDetailsScreen({super.key, required this.card});

  @override
  State<AudioDetailsScreen> createState() => _AudioDetailsScreenState();
}

class _AudioDetailsScreenState extends State<AudioDetailsScreen> {
  late AudioPlaybackService _audioService;
  late TextEditingController _summaryController;
  late TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _audioService = AudioPlaybackService();

    // Initialize controllers with data
    _transcriptController = TextEditingController(
      text: widget.card.transcriptionText ?? '',
    );
    _summaryController = TextEditingController(text: _getMockSummary());

    // Load audio
    _loadAudio();
  }

  /// Get mock summary text
  String _getMockSummary() {
    return 'This is a mock summary of the audio transcription. It provides a brief overview of the key points discussed in the recording. The summary captures the main ideas and essential information for quick reference.';
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
    _summaryController.dispose();
    _transcriptController.dispose();
    super.dispose();
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
        final audioRepo = AudioRepository(db);

        // Store card data for potential undo
        final deletedCard = widget.card;

        await audioRepo.deleteCard(widget.card.cardId);

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
            await audioRepo.createCardWithAudio(
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
                        // Audio Info Header
                        AudioInfoHeader(
                          title: widget.card.cardName,
                          formattedDate: formattedDate,
                        ),

                        const SizedBox(height: 16),

                        // Audio Player
                        AudioPlayerCard(audioService: _audioService),
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
              if (_summaryController.text.isNotEmpty) ...[
                SummarySection(
                  isKhmer: isKhmer,
                  controller: _summaryController,
                  showMockBadge: true,
                ),
                const SizedBox(height: 16),
              ],

              // Transcript Section
              if (_transcriptController.text.isNotEmpty) ...[
                TranscriptSection(
                  isKhmer: isKhmer,
                  controller: _transcriptController,
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

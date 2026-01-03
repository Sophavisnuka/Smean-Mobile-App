import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/service/record_audio_service.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/text_input_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_timer_widget.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_button_widget.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_slider_widget.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_controls_widget.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, this.onRecordingSaved});

  final VoidCallback? onRecordingSaved;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late RecordAudioService _audioService;
  late AudioRepository _audioRepo;
  late TranscriptService _transcriptService;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _audioRepo = AudioRepository(db);
    _transcriptService = TranscriptService(db);
    _authService = AuthService(db);
  }

  Future<void> _saveToHome() async {
    if (_audioService.recordedFilePath == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final title = await TextInputDialog.show(
      context,
      title: isKhmer ? 'រក្សាទុកការថត' : 'Save the Record',
      hintText: isKhmer ? 'បញ្ចូលចំណងជើង' : 'Enter the record title',
    );

    if (title == null || title.isEmpty) return;

    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final cardId = uuid.v4();
    final audioId = uuid.v4();

    // Create card with audio
    await _audioRepo.createCardWithAudio(
      userId: user.id,
      cardName: title,
      audioFilePath: _audioService.recordedFilePath!,
      sourceType: 'recorded',
      audioDuration: _audioService.totalDuration.inSeconds,
      cardId: cardId,
      audioId: audioId,
    );

    if (!mounted) return;

    // Show generating message
    CustomSnackBar.info(
      context,
      isKhmer ? 'កំពុងបង្កើតអត្ថបទ...' : 'Generate Transcript...',
    );

    // Generate mock transcription (2 second delay)
    await _transcriptService.generateMockTranscription(
      cardId: cardId,
      cardName: title,
    );

    if (!mounted) return;

    // Clean up recording state
    await _audioService.deleteRecording();

    // Show success message
    if (mounted) {
      CustomSnackBar.success(
        context,
        isKhmer ? 'រក្សាទុកបានជោគជ័យ' : 'Record have been saved',
      );
    }

    // Call callback to switch back to home and reload
    widget.onRecordingSaved?.call();
  }

  Future<void> _handleRecordingToggle() async {
    if (_audioService.isRecording) {
      await _audioService.stopRecording();
    } else {
      final success = await _audioService.startRecording();
      if (!success && mounted) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        final isKhmer = languageProvider.currentLocale.languageCode == 'km';

        CustomSnackBar.info(
          context,
          isKhmer
              ? 'ត្រូវការសិទ្ធិប្រើមីក្រូហ្វូន!'
              : 'Microphone Permission Required!',
        );
      }
    }
  }

  String _getStatusMessage(bool isKhmer) {
    if (_audioService.isRecording) {
      return isKhmer ? 'កំពុងថតសម្លេង...' : 'Recording...';
    } else if (_audioService.recordedFilePath != null) {
      return isKhmer ? 'ថតរួច' : 'Recording saved';
    } else {
      return isKhmer ? 'ចុចដើម្បីចាប់ផ្តើមថត' : 'Tap to start recording';
    }
  }

  Duration _getDisplayDuration() {
    if (_audioService.isRecording) {
      return _audioService.elapsed;
    } else if (_audioService.recordedFilePath != null) {
      return _audioService.playPosition;
    }
    return Duration.zero;
  }

  @override
  void initState() {
    super.initState();
    _audioService = RecordAudioService();
    _audioService.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final hasRecording = _audioService.recordedFilePath != null;
    final showPlaybackControls = hasRecording && !_audioService.isRecording;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(isKhmer ? 'កំណត់ត្រា' : 'Record'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Display
            RecordingTimerWidget(duration: _getDisplayDuration()),

            // Playback Slider
            if (showPlaybackControls) ...[
              const SizedBox(height: 20),
              RecordingSliderWidget(
                currentPosition: _audioService.playPosition,
                totalDuration: _audioService.totalDuration,
                onSeek: _audioService.seekTo,
              ),
            ],

            const SizedBox(height: 40),

            // Recording Button
            Center(
              child: RecordingButtonWidget(
                isRecording: _audioService.isRecording,
                onTap: _handleRecordingToggle,
              ),
            ),

            const SizedBox(height: 40),

            // Status Message
            Text(
              _getStatusMessage(isKhmer),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),

            // Playback Controls & Save Button
            if (showPlaybackControls) ...[
              const SizedBox(height: 40),
              RecordingControlsWidget(
                isPlaying: _audioService.isPlaying,
                onPlayPause: _audioService.togglePlayback,
                onStop: _audioService.stopPlayback,
                onDelete: _audioService.deleteRecording,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveToHome,
                icon: const Icon(Icons.text_snippet, size: 20),
                label: Text(isKhmer ? 'រក្សាទុក' : 'Save to home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

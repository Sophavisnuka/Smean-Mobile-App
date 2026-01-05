import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/service/record_audio_service.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/audio_preview_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_timer_widget.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_button_widget.dart';
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
  late CardRepository _cardRepo;
  late TranscriptService _transcriptService;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _cardRepo = CardRepository(db);
    _transcriptService = TranscriptService(db);
    _authService = AuthService(db);
  }

  void _showPreviewDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AudioPreviewDialog(
        audioService: _audioService,
        isKhmer: isKhmer,
        initialTitle: '',
        onCancel: () {
          // Delete recording and close dialog
          _audioService.deleteRecording();
          Navigator.of(context).pop();
        },
        onConfirm: (title) async {
          Navigator.of(context).pop();
          await _confirmAndSave(title);
        },
      ),
    );
  }

  Future<void> _confirmAndSave(String title) async {
    if (_audioService.recordedFilePath == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final cardId = uuid.v4();
    final audioId = uuid.v4();

    // Create card with audio
    await _cardRepo.createCard(
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
      // Show preview dialog after stopping recording
      if (mounted && _audioService.recordedFilePath != null) {
        _showPreviewDialog();
      }
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
      // Force UI update after starting recording
      if (mounted && success) {
        setState(() {});
      }
    }
  }

  String _getStatusMessage(bool isKhmer) {
    if (_audioService.isRecording) {
      return isKhmer ? 'កំពុងថតសម្លេង...' : 'Recording...';
    } else {
      return isKhmer ? 'ចុចដើម្បីចាប់ផ្តើមថត' : 'Tap to start recording';
    }
  }

  Duration _getDisplayDuration() {
    if (_audioService.isRecording) {
      return _audioService.elapsed;
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/Smean-Logo.png', height: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKhmer ? 'កំណត់ត្រា' : 'Record',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Text(
                  'SMEAN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Display
            RecordingTimerWidget(duration: _getDisplayDuration()),
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
          ],
        ),
      ),
    );
  }
}

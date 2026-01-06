import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/service/record_audio_service.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/audio_preview_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/record/record_header_widgets.dart';
import 'package:smean_mobile_app/ui/widgets/record/record_timer_section.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_button_widget.dart';
import 'package:smean_mobile_app/ui/widgets/shared/glass_card.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, this.onRecordingSaved});

  final VoidCallback? onRecordingSaved;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  late RecordAudioService _audioService;
  late CardRepository _cardRepo;
  late TranscriptService _transcriptService;
  late AuthService _authService;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  DateTime? _recordingStartedAt;

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

    CustomSnackBar.info(
      context,
      isKhmer ? 'កំពុងបង្កើតអត្ថបទ...' : 'Generate Transcript...',
    );

    final durationSeconds = _audioService.totalDuration.inSeconds > 0
        ? _audioService.totalDuration.inSeconds
        : _audioService.elapsed.inSeconds;
    final safeDuration = durationSeconds <= 0 ? 1 : durationSeconds;

    await _transcriptService.generateMockTranscription(
      cardId: cardId,
      cardName: title,
      durationSeconds: safeDuration,
    );

    if (!mounted) return;

    await _audioService.deleteRecording();

    if (mounted) {
      CustomSnackBar.success(
        context,
        isKhmer ? 'រក្សាទុកបានជោគជ័យ' : 'Record have been saved',
      );
    }

    widget.onRecordingSaved?.call();
  }

  Future<void> _handleRecordingToggle() async {
    if (_audioService.isRecording) {
      await _audioService.stopRecording();
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
      if (mounted && success) {
        _recordingStartedAt = DateTime.now();
        setState(() {});
      }
    }
    _syncPulseWithRecording();
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _pulseController.addListener(() {
      if (_audioService.isRecording && mounted) {
        setState(() {});
      }
    });
    _audioService.onStateChanged = () {
      if (mounted) {
        setState(() {});
        _syncPulseWithRecording();
      }
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    const primary = Color(0xFF0DB2AC);
    const secondary = Color(0xFF4FE2D2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 16,
        title: RecordScreenHeaderTitle(isKhmer: isKhmer),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 320,
                      maxWidth: (constraints.maxWidth * 0.85).clamp(
                        360.0,
                        900.0,
                      ),
                      minHeight: 320,
                    ),
                    child: GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RecordCardHeader(isKhmer: isKhmer),
                          const SizedBox(height: 24),
                          RecordTimerSection(
                            duration: _getDisplayDuration(),
                            isRecording: _audioService.isRecording,
                            pulseAnimation: _pulseAnimation,
                            sweepAngle: _computeSweepAngle(
                              _getDisplayDuration(),
                            ),
                            primary: primary,
                            secondary: secondary,
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: RecordingButtonWidget(
                              isRecording: _audioService.isRecording,
                              onTap: _handleRecordingToggle,
                              radius: 62,
                              pulseValue: _audioService.isRecording
                                  ? _pulseAnimation.value
                                  : 0,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildStatus(isKhmer),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatus(bool isKhmer) {
    return Column(
      children: [
        Text(
          _getStatusMessage(isKhmer),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isKhmer
              ? 'ចាប់ផ្តើម គេបញ្ឈប់ ត្រួតពិនិត្យ ហើយរក្សាទុក'
              : 'Tap to start, stop to preview, then save',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  void _syncPulseWithRecording() {
    if (_audioService.isRecording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
      _recordingStartedAt = null;
    }
  }

  double _computeSweepAngle(Duration duration) {
    final elapsedMs = _audioService.isRecording && _recordingStartedAt != null
        ? DateTime.now().difference(_recordingStartedAt!).inMilliseconds
        : duration.inMilliseconds;
    final ms = elapsedMs % 1000;
    return (ms / 1000) * 2 * math.pi;
  }
}

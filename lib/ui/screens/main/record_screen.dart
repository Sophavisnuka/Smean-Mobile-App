import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:smean_mobile_app/ui/widgets/recording/recording_button_widget.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_timer_widget.dart';
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
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 16,
        title: _HeaderTitle(isKhmer: isKhmer, textTheme: textTheme),
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
                    child: _GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CardHeader(isKhmer: isKhmer, textTheme: textTheme),
                          const SizedBox(height: 24),
                          _buildTimerSection(textTheme),
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
                          _buildStatus(isKhmer, textTheme),
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

  Widget _buildTimerSection(TextTheme textTheme) {
    const primary = Color(0xFF0DB2AC);
    const secondary = Color(0xFF4FE2D2);
    final duration = _getDisplayDuration();
    final isRecording = _audioService.isRecording;
    final sweepAngle = _computeSweepAngle(duration);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 220,
          width: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(
                              0.25 + (0.12 * _pulseAnimation.value),
                            ),
                            blurRadius: 32 + (10 * _pulseAnimation.value),
                            spreadRadius: 4 + (4 * _pulseAnimation.value),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: primary.withOpacity(0.22),
                            blurRadius: 26,
                            spreadRadius: 2,
                          ),
                        ],
                ),
              ),
              if (isRecording)
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.14),
                    border: Border.all(color: primary, width: 1.4),
                  ),
                )
              else
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondary.withOpacity(0.10),
                    border: Border.all(
                      color: primary.withOpacity(0.85),
                      width: 1.4,
                    ),
                  ),
                ),
              CustomPaint(
                size: const Size.square(190),
                painter: _RingPainter(
                  progress: _pulseAnimation.value,
                  isActive: isRecording,
                  primary: primary,
                  secondary: secondary,
                ),
              ),
              if (isRecording) ...[
                // Outer border frame
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: 214,
                        width: 214,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withOpacity(0.32),
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Inner border frame
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: 188,
                        width: 188,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withOpacity(0.26),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (isRecording)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: sweepAngle,
                    child: Transform.translate(
                      offset: const Offset(0, -100),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.32),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              RecordingTimerWidget(
                duration: duration,
                textStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _WaveformBar(
          animation: _pulseAnimation,
          isActive: isRecording,
          secondary: secondary,
        ),
      ],
    );
  }

  Widget _buildStatus(bool isKhmer, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          _getStatusMessage(isKhmer),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
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
          style: textTheme.bodyMedium?.copyWith(
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

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.isKhmer, required this.textTheme});

  final bool isKhmer;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/Smean-Logo.png', height: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKhmer ? 'កំណត់ត្រាសម្លេង' : 'Voice capture',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'SMEAN',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.black54,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.isKhmer, required this.textTheme});

  final bool isKhmer;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKhmer
              ? 'ថត ឈប់ ពិនិត្យ និងរក្សាទុក'
              : 'Record, preview, and save with ease',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isKhmer
              ? 'ការរាប់ពេលវេលាច្បាស់លាស់ ដោយប៊ូតុងថតមានពន្លឺ'
              : 'Intentional controls, live timer, and a glowing record button.',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.92),
                Colors.white.withOpacity(0.86),
              ],
            ),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.isActive,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final bool isActive;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = SweepGradient(
        colors: isActive
            ? [primary, secondary, primary]
            : [secondary, secondary.withOpacity(0.55), secondary],
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    final backgroundPaint = Paint()
      ..color = secondary.withOpacity(isActive ? 0.18 : 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

class _WaveformBar extends StatelessWidget {
  const _WaveformBar({
    required this.animation,
    required this.isActive,
    required this.secondary,
  });

  final Animation<double> animation;
  final bool isActive;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final baseColor = secondary;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isActive ? 1 : 0.6,
      child: SizedBox(
        height: 36,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(18, (index) {
                final phase = animation.value * 2 * math.pi + index * 0.35;
                final height = 10 + (math.sin(phase).abs() * 20);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 6,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: baseColor,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

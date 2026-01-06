import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_constants.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/core/utils/file_validation_util.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/service/upload_audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/audio_preview_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/loading_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/shared/glass_card.dart';
import 'package:smean_mobile_app/ui/widgets/upload/upload_area_widget.dart';
import 'package:smean_mobile_app/ui/widgets/upload/upload_header_widgets.dart';
import 'package:smean_mobile_app/ui/widgets/upload/upload_progress_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.onUploadComplete});

  final VoidCallback? onUploadComplete;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  late UploadAudioService _uploadService;
  late CardRepository _cardRepo;
  late TranscriptService _transcriptService;
  late AuthService _authService;
  late final AnimationController _cardController;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardOffset;
  late final AnimationController _ctaPulseController;
  late final AnimationController _sheenController;
  bool _isDragging = false;
  bool _isUploading = false;
  bool _reduceMotion = false;
  bool _animationsConfigured = false;

  @override
  void initState() {
    super.initState();
    _uploadService = UploadAudioService();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardOpacity = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    _cardOffset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
        );

    _ctaPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0,
      upperBound: 1,
    );

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _cardRepo = CardRepository(db);
    _transcriptService = TranscriptService(db);
    _authService = AuthService(db);

    _configureAnimations();
  }

  @override
  void dispose() {
    _uploadService.dispose();
    _cardController.dispose();
    _ctaPulseController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  void _configureAnimations() {
    final mediaQuery = MediaQuery.maybeOf(context);
    final shouldReduce = mediaQuery?.disableAnimations ?? false;

    final changed = !_animationsConfigured || (_reduceMotion != shouldReduce);
    _reduceMotion = shouldReduce;
    _animationsConfigured = true;

    if (_reduceMotion) {
      _cardController.value = 1;
      _ctaPulseController.stop();
      _ctaPulseController.value = 0;
      _sheenController.stop();
      _sheenController.value = 0;
      return;
    }

    if (changed && _cardController.value == 0) {
      _cardController.forward();
    }
    if (!_ctaPulseController.isAnimating && !_isUploading) {
      _ctaPulseController.repeat(reverse: true);
    }
    if (!_sheenController.isAnimating) {
      _sheenController.repeat();
    }
  }

  Future<void> _handleFilePicked() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // First, let user pick a file (no loading dialog yet)
    final picked = await _uploadService.pickFileOnly();

    if (!picked) {
      // User cancelled or error occurred
      return;
    }

    if (!mounted) return;

    // Now show loading overlay while processing the selected file
    LoadingDialog.show(
      context,
      isKhmer ? 'កំពុងដំណើរការឯកសារ...' : 'Processing file...',
    );

    // Process the file (copy and load audio)
    final success = await _uploadService.processPickedFile();

    // Close loading dialog
    if (mounted) LoadingDialog.hide(context);

    if (!mounted) return;

    if (success) {
      // Verify we have the required data
      if (_uploadService.totalDuration.inSeconds == 0) {
        CustomSnackBar.error(
          context,
          isKhmer
              ? 'មិនអាចទាញយកព័ត៌មានឯកសារបានទេ'
              : 'Could not load file information',
        );
        _uploadService.clearFile();
        return;
      }
      _showPreviewDialog();
    } else {
      CustomSnackBar.error(
        context,
        isKhmer ? 'មានបញ្ហាក្នុងការដំណើរការឯកសារ' : 'Error processing file',
      );
    }
  }

  Future<void> _handleDroppedFile(XFile file) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // Validate file extension
    if (!FileValidationUtil.isAudioFileSupported(file.name, file.path)) {
      CustomSnackBar.error(
        context,
        FileValidationUtil.getUnsupportedFormatMessage(isKhmer),
      );
      return;
    }

    // Show loading overlay
    LoadingDialog.show(
      context,
      isKhmer ? 'កំពុងដំណើរការឯកសារ...' : 'Processing file...',
    );

    try {
      // Process the dropped file (copy and load)
      final success = await _uploadService.processDroppedFile(file);

      // Close loading dialog
      if (mounted) LoadingDialog.hide(context);

      if (!success) {
        throw Exception('Failed to process file');
      }

      // Verify we have the required data
      if (_uploadService.totalDuration.inSeconds == 0) {
        if (!mounted) return;

        CustomSnackBar.error(
          context,
          isKhmer
              ? 'មិនអាចទាញយកព័ត៌មានឯកសារបានទេ'
              : 'Could not load file information',
        );
        _uploadService.clearFile();
        return;
      }

      _showPreviewDialog();
    } catch (e) {
      // Close loading dialog
      if (mounted) LoadingDialog.hide(context);

      if (!mounted) return;

      CustomSnackBar.error(
        context,
        isKhmer ? 'មានបញ្ហាក្នុងការដំណើរការឯកសារ' : 'Error processing file',
      );
    }
  }

  void _showPreviewDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // Get initial title from file name without extension
    final initialTitle =
        _uploadService.fileName?.replaceAll(RegExp(r'\.[^.]+$'), '') ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AudioPreviewDialog(
        audioService: _uploadService,
        isKhmer: isKhmer,
        initialTitle: initialTitle,
        onCancel: () {
          _uploadService.clearFile();
          Navigator.of(context).pop();
        },
        onConfirm: (title) async {
          Navigator.of(context).pop();
          await _confirmUpload(title);
        },
      ),
    );
  }

  Future<void> _confirmUpload(String title) async {
    if (_uploadService.uploadedFilePath == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // Show loading
    setState(() {
      _isUploading = true;
    });

    if (!_reduceMotion) {
      _ctaPulseController.stop();
    }

    try {
      final cardId = await _saveAudioToDatabase(title);

      if (!mounted) return;

      // Generate transcription using the correct cardId
      await _generateTranscription(cardId, title, isKhmer);

      if (!mounted) return;

      // Clean up
      _uploadService.clearFile();
      setState(() {
        _isUploading = false;
      });

      _resumeIdleAnimations();

      // Show success message
      CustomSnackBar.success(
        context,
        isKhmer ? 'រក្សាទុកបានជោគជ័យ: $title' : 'Successfully saved: $title',
      );

      // Call callback to switch back to home and reload
      widget.onUploadComplete?.call();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      _resumeIdleAnimations();

      if (!mounted) return;

      CustomSnackBar.error(
        context,
        isKhmer ? 'មានបញ្ហាក្នុងការរក្សាទុក' : 'Error saving file',
      );
    }
  }

  /// Save audio file to database
  Future<String> _saveAudioToDatabase(String title) async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      throw Exception('No user found');
    }

    final cardId = AppConstants.uuid.v4();
    final audioId = AppConstants.uuid.v4();

    // Create card with audio
    await _cardRepo.createCard(
      userId: user.id,
      cardName: title,
      audioFilePath: _uploadService.uploadedFilePath!,
      sourceType: 'uploaded',
      audioDuration: _uploadService.totalDuration.inSeconds,
      cardId: cardId,
      audioId: audioId,
    );

    return cardId;
  }

  /// Generate mock transcription for the audio
  Future<void> _generateTranscription(
    String cardId,
    String title,
    bool isKhmer,
  ) async {
    CustomSnackBar.info(
      context,
      isKhmer ? 'កំពុងបង្កើតការចម្លងអត្ថបទ...' : 'Generating transcription...',
    );

    final durationSeconds = _uploadService.totalDuration.inSeconds;
    final safeDuration = durationSeconds <= 0 ? 1 : durationSeconds;

    await _transcriptService.generateMockTranscription(
      cardId: cardId,
      cardName: title,
      durationSeconds: safeDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    const primary = Color(0xFF0DB2AC);
    const secondary = Color(0xFF4FE2D2);

    // Ensure animations are aligned with current accessibility setting
    _configureAnimations();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 16,
        title: UploadScreenHeaderTitle(isKhmer: isKhmer),
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
                      minHeight: 360,
                    ),
                    child: SlideTransition(
                      position: _cardOffset,
                      child: FadeTransition(
                        opacity: _cardOpacity,
                        child: GlassCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              UploadCardHeader(isKhmer: isKhmer),
                              const SizedBox(height: 24),
                              DropTarget(
                                onDragEntered: (details) {
                                  setState(() {
                                    _isDragging = true;
                                  });
                                },
                                onDragExited: (details) {
                                  setState(() {
                                    _isDragging = false;
                                  });
                                },
                                onDragDone: (details) {
                                  setState(() {
                                    _isDragging = false;
                                  });
                                  if (details.files.isNotEmpty) {
                                    _handleDroppedFile(details.files.first);
                                  }
                                },
                                child: AnimatedSwitcher(
                                  duration: Duration(
                                    milliseconds: _reduceMotion ? 0 : 320,
                                  ),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: _isUploading
                                      ? UploadProgressView(
                                          key: const ValueKey(
                                            'upload-progress',
                                          ),
                                          isKhmer: isKhmer,
                                          primary: primary,
                                          secondary: secondary,
                                          sheenAnimation: _reduceMotion
                                              ? null
                                              : CurvedAnimation(
                                                  parent: _sheenController,
                                                  curve: Curves.easeInOut,
                                                ),
                                          reduceMotion: _reduceMotion,
                                        )
                                      : UploadAreaWidget(
                                          key: const ValueKey('upload-area'),
                                          isKhmer: isKhmer,
                                          isDragging: _isDragging,
                                          onSelectFile: _handleFilePicked,
                                          primaryColor: primary,
                                          secondaryColor: secondary,
                                          pulseAnimation: _reduceMotion
                                              ? null
                                              : CurvedAnimation(
                                                  parent: _ctaPulseController,
                                                  curve: Curves.easeInOut,
                                                ),
                                          reduceMotion: _reduceMotion,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  void _resumeIdleAnimations() {
    if (_reduceMotion) return;
    if (!_cardController.isAnimating && _cardController.value == 0) {
      _cardController.forward();
    }
    if (!_ctaPulseController.isAnimating && !_isUploading) {
      _ctaPulseController.repeat(reverse: true);
    }
    if (!_sheenController.isAnimating) {
      _sheenController.repeat();
    }
  }
}

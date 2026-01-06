import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_constants.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/file_validation_util.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/loading_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/upload/upload_area_widget.dart';
import 'package:smean_mobile_app/ui/widgets/upload/upload_progress_view.dart';
import 'package:smean_mobile_app/service/upload_audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/audio_preview_dialog.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.onUploadComplete});

  final VoidCallback? onUploadComplete;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late UploadAudioService _uploadService;
  late CardRepository _cardRepo;
  late TranscriptService _transcriptService;
  late AuthService _authService;
  bool _isDragging = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadService = UploadAudioService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _cardRepo = CardRepository(db);
    _transcriptService = TranscriptService(db);
    _authService = AuthService(db);
  }

  @override
  void dispose() {
    _uploadService.dispose();
    super.dispose();
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
                  isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
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
      body: DropTarget(
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
        child: _isUploading
            ? UploadProgressView(isKhmer: isKhmer)
            : UploadAreaWidget(
                isKhmer: isKhmer,
                isDragging: _isDragging,
                onSelectFile: _handleFilePicked,
              ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/service/upload_audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/audio_file_preview_dialog.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/service/transcript_service.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

const uuid = Uuid();

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.onUploadComplete});

  final VoidCallback? onUploadComplete;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late UploadAudioService _uploadService;
  late AudioRepository _audioRepo;
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
    _audioRepo = AudioRepository(db);
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

    // Now show loading overlay while processing the selected file
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  isKhmer ? 'កំពុងដំណើរការឯកសារ...' : 'Processing file...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Process the file (copy and load audio)
    final success = await _uploadService.processPickedFile();

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    if (success) {
      // Verify we have the required data
      if (_uploadService.totalDuration.inSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isKhmer
                  ? 'មិនអាចទាញយកព័ត៌មានឯកសារបានទេ'
                  : 'Could not load file information',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _uploadService.clearFile();
        return;
      }
      _showPreviewDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isKhmer ? 'មានបញ្ហាក្នុងការដំណើរការឯកសារ' : 'Error processing file',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDroppedFile(XFile file) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // Check file extension - try both name and path
    String fileExtension = path.extension(file.name).toLowerCase();
    if (fileExtension.isEmpty) {
      fileExtension = path.extension(file.path).toLowerCase();
    }
    final allowedExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'];

    if (!allowedExtensions.contains(fileExtension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isKhmer
                ? 'ទម្រង់ឯកសារមិនត្រឹមត្រូវ។ សូមប្រើ MP3, WAV, ឬទម្រង់ផ្សេងទៀតដែលគាំទ្រ។'
                : 'Invalid file format. Please use MP3, WAV, or other supported formats.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  isKhmer ? 'កំពុងដំណើរការឯកសារ...' : 'Processing file...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Set the file info
      if (kIsWeb) {
        _uploadService.uploadedFilePath = file.path;
        _uploadService.fileName = file.name;
        _uploadService.fileSize = await file.length();
      } else {
        // Mobile/Desktop: copy file to app documents directory for persistence
        final ioFile = File(file.path);
        final directory = await getApplicationDocumentsDirectory();
        final fileExtension = path.extension(file.name);
        final newFileName =
            'upload_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final newPath = path.join(directory.path, newFileName);

        // Copy the file
        final copiedFile = await ioFile.copy(newPath);

        _uploadService.uploadedFilePath = copiedFile.path;
        _uploadService.fileName = file.name;
        _uploadService.fileSize = await copiedFile.length();
      }

      // Load audio to get duration
      await _uploadService.loadAudio();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Verify we have the required data
      if (_uploadService.totalDuration.inSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isKhmer
                  ? 'មិនអាចទាញយកព័ត៌មានឯកសារបានទេ'
                  : 'Could not load file information',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _uploadService.clearFile();
        return;
      }

      _showPreviewDialog();
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isKhmer ? 'មានបញ្ហាក្នុងការដំណើរការឯកសារ' : 'Error processing file',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      builder: (context) => AudioFilePreviewDialog(
        audioService: _uploadService,
        isKhmer: isKhmer,
        onCancel: () {
          _uploadService.clearFile();
          Navigator.of(context).pop();
        },
        onConfirm: () {
          Navigator.of(context).pop();
          _confirmUpload();
        },
      ),
    );
  }

  Future<void> _confirmUpload() async {
    if (_uploadService.uploadedFilePath == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    // Ask for title
    final controller = TextEditingController(
      text: _uploadService.fileName?.replaceAll(RegExp(r'\.[^.]+$'), '') ?? '',
    );

    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isKhmer ? 'រក្សាទុកឯកសារ' : 'Save File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isKhmer ? 'បញ្ចូលចំណងជើង' : 'Enter title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadService.clearFile();
            },
            child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(context, t);
            },
            child: Text(isKhmer ? 'រក្សាទុក' : 'Save'),
          ),
        ],
      ),
    );

    if (title == null) {
      _uploadService.clearFile();
      return;
    }

    // Show loading
    setState(() {
      _isUploading = true;
    });

    // Save to database
    final user = await _authService.getCurrentUser();
    if (user == null) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final cardId = uuid.v4();
    final audioId = uuid.v4();

    // Create card with audio
    await _audioRepo.createCardWithAudio(
      userId: user.id,
      cardName: title,
      audioFilePath: _uploadService.uploadedFilePath!,
      sourceType: 'uploaded',
      audioDuration: _uploadService.totalDuration.inSeconds,
      cardId: cardId,
      audioId: audioId,
    );

    if (!mounted) return;

    // Show generating transcription message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isKhmer
              ? 'កំពុងបង្កើតការចម្លងអត្ថបទ...'
              : 'Generating transcription...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Generate mock transcription
    await _transcriptService.generateMockTranscription(
      cardId: cardId,
      cardName: title,
    );

    if (!mounted) return;

    // Clean up
    _uploadService.clearFile();
    setState(() {
      _isUploading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isKhmer ? 'រក្សាទុកបានជោគជ័យ: $title' : 'Successfully saved: $title',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    // Call callback to switch back to home and reload
    widget.onUploadComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(isKhmer ? 'ផ្ទុកឡើង' : 'Upload'),
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
            ? _buildLoadingView(isKhmer)
            : _buildUploadView(isKhmer),
      ),
    );
  }

  Widget _buildLoadingView(bool isKhmer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(strokeWidth: 6),
          ),
          const SizedBox(height: 32),
          Text(
            isKhmer
                ? 'កំពុងដំណើរការឯកសាររបស់អ្នក...'
                : 'Processing your file...',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            isKhmer
                ? 'សូមរង់ចាំបន្តិច នេះនឹងចំណាយពេលពីរបីវិនាទីប៉ុណ្ណោះ'
                : 'Please wait, this will only take a few seconds',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadView(bool isKhmer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload area with drag-and-drop indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _isDragging
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: _isDragging
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: Icon(
                _isDragging ? Icons.file_download : Icons.cloud_upload_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              isKhmer ? 'បញ្ចូលឯកសារសម្លេងរបស់អ្នក' : 'Upload Your Audio File',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              isKhmer
                  ? 'ជ្រើសរើសឯកសារសម្លេងពីឧបករណ៍​របស់អ្នកដើម្បីបម្លែងវាទៅជា​អត្ថបទ'
                  : 'Select an audio file from your device to convert it into a transcript.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            if (_isDragging) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Text(
                  isKhmer ? 'ទម្លាក់ឯកសារនៅទីនេះ' : 'Drop file here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),

            // Upload button
            ElevatedButton.icon(
              onPressed: _handleFilePicked,
              icon: const Icon(Icons.audio_file, size: 24),
              label: Text(
                isKhmer ? 'ជ្រើសរើសឯកសារ' : 'Select File',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(250, 56),
              ),
            ),

            const SizedBox(height: 16),

            // Drag and drop hint (only on desktop)
            if (!kIsWeb &&
                (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
              Text(
                isKhmer
                    ? 'ឬអូសនិងទម្លាក់ឯកសារនៅទីនេះ'
                    : 'Or drag and drop a file here',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),

            const SizedBox(height: 24),

            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isKhmer
                          ? 'គាំទ្រទម្រង់: MP3, WAV, M4A, AAC, OGG, FLAC'
                          : 'Supported formats: MP3, WAV, M4A, AAC, OGG, FLAC',
                      style: TextStyle(color: Colors.blue[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

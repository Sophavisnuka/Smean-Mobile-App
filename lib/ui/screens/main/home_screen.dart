import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/service/audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/profile_card.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/fan_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSwitchTab});

  final void Function(int) onSwitchTab;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String searchText = '';
  final AudioService _audioService = AudioService();
  List<AudioRecord> _audios = [];
  bool _isFanMenuOpen = false;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    displayAudio();
  }

  void displayAudio() async {
    final audios = await _audioService.loadAudios();
    setState(() {
      _audios = audios;
    });
  }

  Future<void> _editTitle(AudioRecord audio) async {
    final controller = TextEditingController(text: audio.audioTitle);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(context, t);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle == null) return;

    final updateAudio = await _audioService.updateAudio(
      newTitle,
      audio.audioId,
      _audios,
    );
    setState(() {
      _audios = updateAudio;
    });
  }

  Future<void> _deleteCard(AudioRecord audio) async {
    final onConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => ShowConfirmDialog(
        cancelText: 'Cancel',
        confirmText: 'Confirm',
        titleText: 'Are you sure you want to delete?',
      ),
    );

    if (onConfirm != true) return;
    final removedIndex = _audios.indexWhere((a) => a.audioId == audio.audioId);
    if (removedIndex == -1) return;
    final removedAudio = _audios[removedIndex];

    setState(() {
      _audios.removeAt(removedIndex);
    });
    await _audioService.saveAudios(_audios);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Removed ${removedAudio.audioTitle}'),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 4),
              tween: Tween(begin: 1.0, end: 0.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                );
              },
              onEnd: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            setState(() {
              _audios.insert(removedIndex, removedAudio);
            });
            _audioService.saveAudios(_audios);
          },
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(AudioRecord audio) async {
    final updatedAudios = await _audioService.toggleFavorite(
      audio.audioId,
      _audios,
    );
    setState(() {
      _audios = updatedAudios;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/Smean-Logo.png', height: 50),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      floatingActionButton: FanMenu(
        isOpen: _isFanMenuOpen,
        onToggle: () {
          setState(() {
            _isFanMenuOpen = !_isFanMenuOpen;
          });
        },
        items: [
          FanMenuItem(
            icon: Icons.mic,
            label: isKhmer ? 'កំណត់ត្រា' : 'Record',
            color: Colors.red,
            onTap: () {
              widget.onSwitchTab(2); // Switch to Record tab (index 2)
            },
          ),
          FanMenuItem(
            icon: Icons.upload_file,
            label: isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
            color: Colors.blue,
            onTap: () {
              widget.onSwitchTab(3); // Switch to Upload tab (index 3)
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: ListView(
          children: [
            // profile card
            ProfileCard(
              isKhmer: isKhmer,
              onTap: () =>
                  widget.onSwitchTab(4), // Switch to Account tab (index 4)
            ),
            SizedBox(height: 15),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                widget.onSwitchTab(1); // Switch to Search tab (index 1)
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 10),
                    Text(
                      'Search audio...',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showOnlyFavorites
                      ? (isKhmer ? 'សំឡេងដែលចូលចិត្ត' : 'Favorite Recorded')
                      : (isKhmer ? 'សំឡេងទាំងអស់' : 'All Voice Recorded'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color: _showOnlyFavorites ? Colors.amber : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _showOnlyFavorites = !_showOnlyFavorites;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            _audios.isEmpty
                ? Center(
                    child: Text(
                      'No Recent Records',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  )
                : () {
                    final displayAudios = _showOnlyFavorites
                        ? _audios.where((audio) => audio.isFavorite).toList()
                        : _audios;

                    if (displayAudios.isEmpty) {
                      return Center(
                        child: Text(
                          isKhmer
                              ? 'គ្មានសំឡេងដែលចូលចិត្ត'
                              : 'No Favorite Records',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: displayAudios.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) => SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final audio = displayAudios[index];
                        return RecentActivityCard(
                          isKhmer: isKhmer,
                          audio: audio,
                          onEdit: () => _editTitle(audio),
                          onDelete: () => _deleteCard(audio),
                          onFavoriteToggle: () => _toggleFavorite(audio),
                        );
                      },
                    );
                  }(),
          ],
        ),
      ),
    );
  }
}

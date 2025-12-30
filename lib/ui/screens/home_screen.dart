import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/audio_provider.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/service/audio_service.dart';
import 'package:smean_mobile_app/ui/screens/create_audio_screen.dart';
import 'package:smean_mobile_app/ui/screens/search_screen.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/profile_card.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  final AudioService _audioService = AudioService();
  String searchText = '';
  List<AudioRecord> _audios = [];

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
    Provider.of<AudioProvider>(context, listen: false).setAudios(audios);
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

    setState(() {
      final idx = _audios.indexWhere((a) => a.audioId == audio.audioId);
      if (idx == -1) return;

      // no copyWith: create a new AudioRecord
      _audios[idx] = AudioRecord(
        audioId: _audios[idx].audioId,
        audioTitle: newTitle,
        createdAt: _audios[idx].createdAt,
        filePath: _audios[idx].filePath,
      );
    });

    Provider.of<AudioProvider>(context, listen: false).setAudios(_audios);

    await _audioService.saveAudios(_audios);
  }
  Future<void> _deleteCard(AudioRecord audio) async {
    final onConfirm = await showDialog<bool>(
      context: context, 
      builder: (_) => ShowConfirmDialog(
        cancelText: 'Cancel', 
        confirmText: 'Confirm', 
        titleText: 'Are you sure you want to delete?'
      )    
    );
    
    if (onConfirm != true) return; 
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final removedIndex = _audios.indexWhere((a) => a.audioId == audio.audioId);
    if (removedIndex == -1) return;
    final removedAudio = _audios[removedIndex];

    setState(() {
      _audios.removeAt(removedIndex);
    });
    audioProvider.setAudios(_audios);
    await _audioService.saveAudios(_audios);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removedAudio.audioTitle}'),
        action: SnackBarAction(
          label: 'undo', 
          onPressed: () async {
            setState(() {
              _audios.insert(removedIndex, removedAudio);
            });
            audioProvider.setAudios(_audios);
            await _audioService.saveAudios(_audios);
          }
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final audios = context.watch<AudioProvider>().audios;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/Smean-Logo.png', height: 50),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => CreateAudioScreen())
          );
          setState(() {
            _audios.add(result);
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Upload Audio',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: ListView(
          children: [
            // profile card
            ProfileCard(isKhmer: isKhmer),
            SizedBox(height: 15),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 10),
                    Text('Search audio...', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isKhmer ? 'សំឡេងទាំងអស់' : 'All Voice Recorded', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('Sort By', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(Icons.sort, color: Colors.black, size: 17),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            audios.isEmpty ? Center(
              child: Text(
                'No Recent Records',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ) : 
            ListView.separated(
              itemCount: audios.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_,_) => SizedBox(height: 15), 
              itemBuilder: (context, index) {
                final audio = audios[index];
                return RecentActivityCard(
                    isKhmer: isKhmer,
                    audio: audio,
                    onEdit: () => _editTitle(audios[index]),
                    onDelete: () => _deleteCard(audios[index]),
                  );
              },
            )
          ],
        ),
      ),
    );
  }
}
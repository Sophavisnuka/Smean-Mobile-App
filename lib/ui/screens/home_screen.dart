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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final audios = context.watch<AudioProvider>().audios;

    final filteredAudios = audios.where((audio) =>
      audio.audioTitle.toLowerCase().contains(searchText.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/Smean-Logo.png', height: 50),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => SearchScreen())
                );
              },
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search audio...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isKhmer ? 'សកម្មភាពថ្មីៗ' : 'Recent Activities', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
            if (_audios.isEmpty)
              Center(
                child: Text(
                  'No Recent Records',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              )
            else ...[
              for (int index = 0; index < filteredAudios.length; index++) ...[
                if (index > 0) SizedBox(height: 15),
                Dismissible(
                  key: Key(filteredAudios[index].audioId),
                  onDismissed: (direction) {
                    final removeAudio = filteredAudios[index];
                    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                    audioProvider.deleteAudio(removeAudio.audioId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${removeAudio.audioTitle} removed'),
                        action: SnackBarAction(
                          label: 'undo',
                          onPressed: () {
                            audioProvider.addAudio(removeAudio);
                          },
                        ),
                      ),
                    );
                  },
                  child: RecentActivityCard(
                    isKhmer: isKhmer,
                    title: filteredAudios[index].audioTitle,
                    createdAt: filteredAudios[index].createdAt,
                  ),
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }
}
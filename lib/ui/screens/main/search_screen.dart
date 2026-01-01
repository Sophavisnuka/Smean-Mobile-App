import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/service/audio_service.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  String searchText = '';
  List<AudioRecord> _audios = [];
  final AudioService _audioService = AudioService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reloadAudios(); // initial load
  }

  Future<void> reloadAudios() async {
    final audio = await _audioService.loadAudios();
    setState(() {
      _audios = audio;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    // final audios = _audios;

    final filteredAudios = _audios
        .where(
          (audio) =>
              audio.audioTitle.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isKhmer ? 'ស្វែងរក' : 'Search'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            SizedBox(height: 24),
            // Placeholder for results
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : filteredAudios.isEmpty
                  ? Center(
                      child: Text(
                        'No result found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredAudios.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final audio = filteredAudios[index];
                        return RecentActivityCard(
                          audio: audio,
                          isKhmer: isKhmer,
                          searchQuery: searchText,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

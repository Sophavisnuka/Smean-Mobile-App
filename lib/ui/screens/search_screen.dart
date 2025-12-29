import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/audio_provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchText = '';

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
        title: Text(isKhmer ? 'ស្វែងរក':'Search'),
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
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            SizedBox(height: 24),
            // Placeholder for results
            Expanded(
              child: filteredAudios.isEmpty ?
              Center(
                child: Text(
                  'No result found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ) :
              ListView.separated(
                itemCount: filteredAudios.length,
                separatorBuilder:(context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final audio = filteredAudios[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.mic, color: Colors.redAccent),
                      title: Text(audio.audioTitle),
                      subtitle: Text(audio.createdAt.toIso8601String()),
                    ),
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
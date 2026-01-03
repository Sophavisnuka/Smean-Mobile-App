import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  String searchText = '';
  List<CardModel> _cards = [];
  late AudioRepository _audioRepo;
  late AuthService _authService;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _audioRepo = AudioRepository(db);
    _authService = AuthService(db);
    reloadAudios(); // initial load
  }

  Future<void> reloadAudios() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final cards = searchText.isEmpty
        ? await _audioRepo.getCardsForUser(user.id)
        : await _audioRepo.searchCards(user.id, searchText);
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final filteredCards = _cards;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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
                reloadAudios();
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
                  : filteredCards.isEmpty
                  ? Center(
                      child: Text(
                        'No result found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredCards.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final card = filteredCards[index];
                        return RecentActivityCard(
                          isKhmer: isKhmer,
                          card: card,
                          searchQuery: searchText,
                          onRefresh: reloadAudios,
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

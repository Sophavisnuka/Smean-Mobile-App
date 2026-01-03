import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/data/repository/audio_repository.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
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
  late AudioRepository _audioRepo;
  late AuthService _authService;
  List<CardModel> _cards = [];
  bool _isFanMenuOpen = false;
  bool _showOnlyFavorites = false;
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
    displayAudio();
  }

  void displayAudio() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final cards = await _audioRepo.getCardsForUser(user.id);
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _editTitle(CardModel card) async {

    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => ShowInputDialog(
        titleText: 'Edit Record title', 
        hintText: 'Enter a new title',
        initialValue: card.cardName,
      ),
    );

    if (newTitle == null) return;

    await _audioRepo.updateCardName(card.cardId, newTitle);
    displayAudio(); // Reload
  }

  Future<void> _deleteCard(CardModel card) async {
    final onConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => ShowConfirmDialog(
        cancelText: 'Cancel',
        confirmText: 'Confirm',
        titleText: 'Are you sure you want to delete?',
      ),
    );

    if (onConfirm != true) return;

    await _audioRepo.deleteCard(card.cardId);

    if (!mounted) return;
    CustomSnackBar.success(context, 'You have deleted card ${card.cardName}');
    displayAudio(); // Reload
  }

  Future<void> _toggleFavorite(CardModel card) async {
    await _audioRepo.toggleFavorite(card.cardId, !card.isFavorite);
    displayAudio(); // Reload
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
            _loading
                ? Center(child: CircularProgressIndicator())
                : _cards.isEmpty
                ? Center(
                    child: Text(
                      'No Recent Records',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  )
                : () {
                    final displayCards = _showOnlyFavorites
                        ? _cards.where((card) => card.isFavorite).toList()
                        : _cards;

                    if (displayCards.isEmpty) {
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
                      itemCount: displayCards.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) => SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final card = displayCards[index];
                        return RecentActivityCard(
                          isKhmer: isKhmer,
                          card: card,
                          onEdit: () => _editTitle(card),
                          onDelete: () => _deleteCard(card),
                          onFavoriteToggle: () => _toggleFavorite(card),
                          onRefresh: displayAudio,
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

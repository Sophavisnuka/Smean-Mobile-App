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
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/fan_menu.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/text_input_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/home/search_bar_widget.dart';
import 'package:smean_mobile_app/ui/widgets/home/section_header_widget.dart';
import 'package:smean_mobile_app/ui/widgets/home/empty_state_widget.dart';
import 'package:smean_mobile_app/ui/widgets/home/audio_list_widget.dart';

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
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final newTitle = await TextInputDialog.show(
      context,
      title: isKhmer ? 'កែប្រែចំណងជើង' : 'Edit Record title',
      hintText: isKhmer ? 'បញ្ចូលចំណងជើងថ្មី' : 'Enter a new title',
      initialValue: card.cardName,
    );

    if (newTitle == null || newTitle.isEmpty) return;

    await _audioRepo.updateCardName(card.cardId, newTitle);
    displayAudio(); // Reload
  }

  Future<void> _deleteCard(CardModel card) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final onConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => ShowConfirmDialog(
        cancelText: isKhmer ? 'បោះបង់' : 'Cancel',
        confirmText: isKhmer ? 'បញ្ជាក់' : 'Confirm',
        titleText: isKhmer
            ? 'តើអ្នកប្រាកដថាចង់លុបទេ?'
            : 'Are you sure you want to delete?',
      ),
    );

    if (onConfirm != true) return;

    // Store card data for potential undo
    final deletedCard = card;

    await _audioRepo.deleteCard(card.cardId);
    displayAudio(); // Reload to show updated list

    if (!mounted) return;

    CustomSnackBar.showWithAction(
      context,
      message: isKhmer
          ? 'លុបកាតបានជោគជ័យ ${card.cardName}'
          : 'You have deleted card ${card.cardName}',
      actionLabel: isKhmer ? 'មិនធ្វើវិញ' : 'UNDO',
      onAction: () async {
        // Restore the deleted card
        await _audioRepo.createCardWithAudio(
          userId: deletedCard.userId,
          cardName: deletedCard.cardName,
          audioFilePath: deletedCard.audioFilePath!,
          sourceType:
              'recorded', // Default to recorded since we don't store this in CardModel
          audioDuration: deletedCard.audioDuration ?? 0,
          cardId: deletedCard.cardId,
          audioId: deletedCard.audioId!,
          isFavorite: deletedCard.isFavorite,
          createdAt: deletedCard.createdAt,
        );
        displayAudio(); // Reload to show restored card
      },
      type: SnackBarType.success,
    );
  }

  Future<void> _toggleFavorite(CardModel card) async {
    await _audioRepo.toggleFavorite(card.cardId, !card.isFavorite);
    displayAudio(); // Reload
  }

  Widget _buildAudioContent(bool isKhmer) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cards.isEmpty) {
      return EmptyStateWidget(
        message: isKhmer ? 'គ្មានកំណត់ត្រា' : 'No Recent Records',
        color: Colors.black,
      );
    }

    final displayCards = _showOnlyFavorites
        ? _cards.where((card) => card.isFavorite).toList()
        : _cards;

    if (displayCards.isEmpty) {
      return EmptyStateWidget(
        message: isKhmer ? 'គ្មានសំឡេងដែលចូលចិត្ត' : 'No Favorite Records',
      );
    }

    return AudioListWidget(
      cards: displayCards,
      isKhmer: isKhmer,
      onEdit: _editTitle,
      onDelete: _deleteCard,
      onFavoriteToggle: _toggleFavorite,
      onRefresh: displayAudio,
    );
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
            onTap: () => widget.onSwitchTab(2),
          ),
          FanMenuItem(
            icon: Icons.upload_file,
            label: isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
            color: Colors.blue,
            onTap: () => widget.onSwitchTab(3),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: ListView(
          children: [
            // Profile card
            ProfileCard(isKhmer: isKhmer, onTap: () => widget.onSwitchTab(4)),
            const SizedBox(height: 15),

            // Search bar
            SearchBarWidget(
              onTap: () => widget.onSwitchTab(1),
              hintText: isKhmer ? 'ស្វែងរកសំឡេង...' : 'Search audio...',
            ),
            const SizedBox(height: 15),

            // Section header with favorite toggle
            SectionHeaderWidget(
              title: _showOnlyFavorites
                  ? (isKhmer ? 'សំឡេងដែលចូលចិត្ត' : 'Favorite Recorded')
                  : (isKhmer ? 'សំឡេងទាំងអស់' : 'All Voice Recorded'),
              icon: Icons.bookmark,
              iconColor: _showOnlyFavorites ? Colors.amber : Colors.grey,
              onIconPressed: () {
                setState(() {
                  _showOnlyFavorites = !_showOnlyFavorites;
                });
              },
            ),
            const SizedBox(height: 15),

            // Audio content
            _buildAudioContent(isKhmer),
          ],
        ),
      ),
    );
  }
}

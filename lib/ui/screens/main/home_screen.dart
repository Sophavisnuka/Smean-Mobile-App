import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/data/repository/card_repository.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/profile_card.dart';
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/fan_menu.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/text_input_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_bookmark_icon.dart';
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
  late AuthService _authService;
  late CardRepository _cardRepo;
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
    _cardRepo = CardRepository(db);
    _authService = AuthService(db);
    displayAudio();
  }

  void displayAudio() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final cards = searchText.isEmpty
        ? await _cardRepo.getCardsForUser(user.id)
        : await _cardRepo.searchCards(user.id, searchText);
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

    await _cardRepo.updateCardName(card.cardId, newTitle);
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

    await _cardRepo.deleteCard(card.cardId);
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
        await _cardRepo.createCard(
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
    await _cardRepo.toggleFavorite(card.cardId, !card.isFavorite);
    displayAudio(); // Reload
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    return Scaffold(
      // backgroundColor: AppColors.contrast,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/Smean-Logo.png', height: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKhmer ? 'សួស្តី!' : 'Welcome!',
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          displayAudio();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Hero Section with consistent padding
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.contrast,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  ProfileCard(
                    isKhmer: isKhmer,
                    onTap: () => widget.onSwitchTab(4),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.library_music,
                          title: isKhmer ? 'សរុប' : 'Total',
                          value: '${_cards.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          iconWidget: ItshoverBookmarkIcon(
                            color: Colors.amber,
                            size: 22,
                            animate: true,
                          ),
                          title: isKhmer ? 'ចូលចិត្ត' : 'Saved',
                          value: '${_cards.where((c) => c.isFavorite).length}',
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content Section with consistent padding
            Padding(
              padding: const EdgeInsets.all(20),
              child: SearchBarWidget(
                hintText: isKhmer ? 'ស្វែងរកសំឡេង...' : 'Search audio...',
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                  displayAudio();
                },
              ),
            ),
            SizedBox(height: 7),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.contrast,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Section header with favorite toggle
                      SectionHeaderWidget(
                        title: _showOnlyFavorites
                            ? (isKhmer
                                  ? 'សំឡេងដែលចូលចិត្ត'
                                  : 'Favorite Recordings')
                            : (isKhmer
                                  ? 'កំណត់ត្រាថ្មីៗ'
                                  : 'Recent Recordings'),
                        trailingIcon: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: IconTheme(
                            data: IconThemeData(
                              color: _showOnlyFavorites
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                            child: ItshoverBookmarkIcon(
                              animate: _showOnlyFavorites,
                            ),
                          ),
                        ),
                        onIconPressed: () {
                          setState(() {
                            _showOnlyFavorites = !_showOnlyFavorites;
                          });
                        },
                      ),
                      _buildAudioContent(isKhmer),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: iconWidget ?? Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent(bool isKhmer) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayCards = _showOnlyFavorites
        ? _cards.where((card) => card.isFavorite).toList()
        : _cards;

    if (displayCards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: EmptyStateWidget(
            message: _showOnlyFavorites
                ? (isKhmer ? 'គ្មានសំឡេងដែលចូលចិត្ត' : 'No Favorite Records')
                : (isKhmer ? 'គ្មានកំណត់ត្រា' : 'No Recent Records'),
            color: Colors.black,
          ),
        ),
      );
    }

    return Column(
      children: displayCards.map((card) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioListWidget(
            cards: [card],
            isKhmer: isKhmer,
            onEdit: _editTitle,
            onDelete: _deleteCard,
            onFavoriteToggle: _toggleFavorite,
            onRefresh: displayAudio,
            searchQuery: searchText,
          ),
        );
      }).toList(),
    );
  }
}

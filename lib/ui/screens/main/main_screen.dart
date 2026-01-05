import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/screens/main/home_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/search_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/record_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/upload_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/account_screen.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_account_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_home_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_magnifier_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_mic_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_upload_icon.dart';
import 'package:smean_mobile_app/ui/widgets/navigation/custom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum ScreenTab {
  homeScreen,
  searchScreen,
  recordScreen,
  uploadScreen,
  accountScreen,
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<SearchScreenState> _searchKey =
      GlobalKey<SearchScreenState>();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  int currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      currentIndex = index;
      if (index == 1) {
        _searchKey.currentState?.reloadAudios();
      }
    });
  }

  void _handleRecordingSaved() {
    // Reload home screen data
    _homeKey.currentState?.displayAudio();
    // Switch back to home
    _switchTab(0);
  }

  void _handleUploadComplete() {
    // Reload home screen data
    _homeKey.currentState?.displayAudio();
    // Switch back to home
    _switchTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(key: _homeKey, onSwitchTab: _switchTab),
          SearchScreen(key: _searchKey),
          RecordScreen(onRecordingSaved: _handleRecordingSaved),
          UploadScreen(onUploadComplete: _handleUploadComplete),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: currentIndex,
        onTap: _switchTab,
        activeColor: AppColors.primary,
        inactiveColor: Colors.grey,
        items: [
          NavItem(
            icon: const ItshoverHomeIcon(),
            activeIcon: const ItshoverHomeIcon(animate: true),
            label: isKhmer ? 'ទំព័រដើម' : 'Home',
          ),
          NavItem(
            icon: const ItshoverMagnifierIcon(),
            activeIcon: const ItshoverMagnifierIcon(animate: true),
            label: isKhmer ? 'ស្វែងរក' : 'Search',
          ),
          NavItem(
            icon: const ItshoverMicIcon(),
            activeIcon: const ItshoverMicIcon(animate: true),
            label: isKhmer ? 'ថត' : 'Record',
          ),
          NavItem(
            icon: const ItshoverUploadIcon(),
            activeIcon: const ItshoverUploadIcon(animate: true),
            label: isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
          ),
          NavItem(
            icon: const ItshoverAccountIcon(),
            activeIcon: const ItshoverAccountIcon(animate: true),
            label: isKhmer ? 'គណនី' : 'Account',
          ),
        ],
      ),
    );
  }
}

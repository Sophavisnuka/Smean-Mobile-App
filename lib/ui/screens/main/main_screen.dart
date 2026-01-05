import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            if (index == 1) {
              _searchKey.currentState?.reloadAudios();
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const ItshoverHomeIcon(),
            activeIcon: const ItshoverHomeIcon(animate: true),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const ItshoverMagnifierIcon(),
            activeIcon: const ItshoverMagnifierIcon(animate: true),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: const ItshoverMicIcon(),
            activeIcon: const ItshoverMicIcon(animate: true),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: const ItshoverUploadIcon(),
            activeIcon: const ItshoverUploadIcon(animate: true),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: const ItshoverAccountIcon(),
            activeIcon: const ItshoverAccountIcon(animate: true),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

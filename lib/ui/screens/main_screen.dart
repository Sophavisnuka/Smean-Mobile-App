import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/screens/home_screen.dart';
import 'package:smean_mobile_app/ui/screens/search_screen.dart';
import 'package:smean_mobile_app/ui/screens/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum ScreenTab{homeScreen, searchScreen, recordScreen, accountScreen}

class _MainScreenState extends State<MainScreen> {

  final GlobalKey<SearchScreenState> _searchKey = GlobalKey<SearchScreenState>();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(),
          SearchScreen(key: _searchKey),
          // RecordScreen(),
          AccountScreen()
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
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search'
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.mic),
          //   label: 'Record'
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Account'
          ),
        ]
      ),
    );
  }
}
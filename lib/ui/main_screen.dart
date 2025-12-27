import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/home_screen.dart';
import 'package:smean_mobile_app/ui/recording_screen.dart';
import 'package:smean_mobile_app/ui/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum ScreenTab{homeScreen, searchScreen, recordScreen,}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // final List<Widget> screens = [
  //   HomeScreen(),
  //   RecordScreen(),
  //   SearchScreen()
  // ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(),
          RecordScreen(),
          SearchScreen(),
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Record'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search'
          ),
        ]
      ),
    );
  }
}
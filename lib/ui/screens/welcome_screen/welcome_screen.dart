import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_screen.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/login_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/main_screen.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Background loading during splash animation
  Future<void> _initializeApp() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final authService = AuthService(db);

    // Run all initialization tasks in parallel
    final results = await Future.wait([
      // Task 1: Check if first time user (returns bool instead of navigating)
      _checkIfFirstTimeUser(),

      // Task 2: Check if user is already logged in
      authService.getCurrentUser(),

      // Task 3: Preload any necessary data or assets
      _preloadData(),

      // Task 4: Wait for animation (minimum 3 seconds to show animation)
      Future.delayed(Duration(seconds: 3)),
    ]);

    // After all tasks complete (including 3s animation), navigate appropriately
    final bool isFirstTime = results[0] as bool;
    final currentUser = results[1]; // AppUser? or null

    if (mounted) {
      // Priority 1: If user is already logged in, go straight to main
      if (currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
      // Priority 2: First time user, show intro screens
      else if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      }
      // Priority 3: Returning user but not logged in, show login
      else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  Future<bool> _checkIfFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    return !hasSeenIntro; // Return true if first time (hasn't seen intro)
  }

  Future<void> _preloadData() async {
    // TODO: Add your background tasks here
    // Examples:
    // - Check authentication status
    // - Fetch initial data from API
    // - Load cached data
    // - Initialize services
    // - Preload images or assets

    // Example placeholder:
    await Future.delayed(Duration(milliseconds: 500));

    // You can add more initialization here later:
    // await FirebaseService.initialize();
    // await AudioService.initialize();
    // etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/SMEAN_logo.json'),
            SizedBox(height: 20),
            Lottie.asset('assets/images/SMEAN_text.json'),
            SizedBox(height: 20),
            Lottie.asset('assets/images/SMEAN_description.json'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

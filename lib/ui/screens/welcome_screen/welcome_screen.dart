import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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
    try {
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
    } catch (e, stackTrace) {
      print('Error initializing app: $e');
      print('Stack trace: $stackTrace');
      
      // On error, just go to intro screen after delay
      await Future.delayed(Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      }
    }
  }

  Future<bool> _checkIfFirstTimeUser() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final session = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();
    // If no session exists, it's first time user
    return session == null;
  }

  Future<void> _preloadData() async {
    // Preload data and initialize services
    await Future.delayed(Duration(milliseconds: 500));
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

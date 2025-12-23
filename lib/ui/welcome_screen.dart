import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smean_mobile_app/ui/intro_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('../assets/SMEAN_logo.json'),
            SizedBox(height: 20),
            Lottie.asset('../assets/SMEAN_text.json'),
            SizedBox(height: 20),
            Lottie.asset('../assets/SMEAN_description.json'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
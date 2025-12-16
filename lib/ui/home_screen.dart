import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          '../assets/Smean-Logo.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
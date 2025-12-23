import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/widgets/language_switcher_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'ស្មៀន Mobile App' : 'SMEAN Mobile App',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          isKhmer ? 'ខ្មែរធ្វើបាន!' : 'Khmer Can Do It!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier{
  // set english as default language
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale; 

  LanguageProvider() {
    _loadLanguage();
  }

  // Toggle between English (en) and Khmer (km)
  void toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('km');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners(); //rebuild the app

    _saveLanguage(_currentLocale);
  }

  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langauge_code', locale.languageCode);
  }
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('langauge_code');
    if(languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
}
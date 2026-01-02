import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';

class LanguageProvider extends ChangeNotifier {
  final AppDatabase db;

  // set english as default language
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LanguageProvider(this.db) {
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
    final existing = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();

    if (existing == null) {
      // Insert new session with language
      await db
          .into(db.appSession)
          .insert(
            AppSessionCompanion(
              languageCode: drift.Value(locale.languageCode),
              lastUpdated: drift.Value(DateTime.now()),
            ),
          );
    } else {
      // Update existing session
      await (db.update(
        db.appSession,
      )..where((t) => t.id.equals(existing.id))).write(
        AppSessionCompanion(
          languageCode: drift.Value(locale.languageCode),
          lastUpdated: drift.Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _loadLanguage() async {
    final session = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();
    if (session != null) {
      _currentLocale = Locale(session.languageCode);
      notifyListeners();
    }
  }
}

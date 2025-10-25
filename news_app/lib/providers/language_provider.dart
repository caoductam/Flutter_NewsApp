import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  final PreferencesService _prefsService = PreferencesService();

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('vi'), // Vietnamese
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'vi': 'Tiếng Việt',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  // Load language from SharedPreferences
  Future<void> _loadLanguage() async {
    final languageCode = await _prefsService.getLanguage();
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLocales.any((l) => l.languageCode == languageCode)) {
      return;
    }

    _locale = Locale(languageCode);
    await _prefsService.saveLanguage(languageCode);
    notifyListeners();
  }

  // Get display name for language
  String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }
}

import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final PreferencesService _prefsService = PreferencesService();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // Load theme từ SharedPreferences
  Future<void> _loadTheme() async {
    _themeMode = await _prefsService.getThemeMode();
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await _prefsService.saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Set theme cụ thể
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _prefsService.saveThemeMode(_themeMode);
    notifyListeners();
  }
}

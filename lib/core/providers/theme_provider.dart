import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void _loadTheme() {
    // Verifica se existe uma preferência salva
    final savedTheme = _prefs.getBool(_themeKey);

    if (savedTheme != null) {
      _isDarkMode = savedTheme;
    } else {
      _isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      _prefs.setBool(_themeKey, _isDarkMode);
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}

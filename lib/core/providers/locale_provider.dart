import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  final SharedPreferences _prefs;

  static const String _selectedLanguageCodeKey = 'selectedLanguageCode';

  LocaleProvider(this._prefs) {
    _loadSavedLocale();
  }

  Locale? get locale => _locale;

  void _loadSavedLocale() {
    String? languageCode = _prefs.getString(_selectedLanguageCodeKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(languageCode);
    } else {
      // Optional: Set a default locale if none is saved, e.g., English
      // _locale = const Locale('en');
    }
    // Notify listeners only if a locale was actually loaded and set,
    // or if you want to ensure initial state is propagated.
    // For simplicity, we'll notify if it's not null.
    if (_locale != null) {
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _prefs.setString(_selectedLanguageCodeKey, newLocale.languageCode);
    notifyListeners();
  }

  // Helper to clear locale, if needed for testing or features
  Future<void> clearLocale() async {
    _locale = null;
    await _prefs.remove(_selectedLanguageCodeKey);
    notifyListeners();
  }
}

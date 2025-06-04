import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

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
      // Usa o idioma do dispositivo se nenhum idioma foi salvo
      final deviceLocale = ui.window.locale;
      // Verifica se o idioma do dispositivo é suportado
      if (['en', 'pt'].contains(deviceLocale.languageCode)) {
        _locale = deviceLocale;
        // Salva o idioma do dispositivo como preferência
        _prefs.setString(_selectedLanguageCodeKey, deviceLocale.languageCode);
      } else {
        // Fallback para inglês se o idioma do dispositivo não for suportado
        _locale = const Locale('en');
        _prefs.setString(_selectedLanguageCodeKey, 'en');
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale?.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      await _prefs.setString(_selectedLanguageCodeKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  Future<void> clearLocale() async {
    _locale = null;
    await _prefs.remove(_selectedLanguageCodeKey);
    // Após limpar, recarrega o idioma do dispositivo
    _loadSavedLocale();
  }
}

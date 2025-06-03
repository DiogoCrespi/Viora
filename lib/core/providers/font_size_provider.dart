import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  double _fontSize = 1.0;
  final SharedPreferences _prefs;

  FontSizeProvider(this._prefs) {
    _loadFontSize();
  }

  double get fontSize => _fontSize;

  void _loadFontSize() {
    _fontSize = _prefs.getDouble(_fontSizeKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs.setDouble(_fontSizeKey, size);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _kLanguage = 'settings_language';

  Locale _locale = const Locale('zh');
  SharedPreferences? _prefs;

  /// Restores the saved language. Call once before the app is shown.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final code = _prefs!.getString(_kLanguage);
      if (code == 'zh' || code == 'en') {
        _locale = Locale(code!);
        notifyListeners();
      }
    } catch (_) {
      // Storage unavailable – keep the default language.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setString(_kLanguage, _locale.languageCode);
    } catch (_) {
      // Ignore storage errors – the language won't survive a restart.
    }
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  void setLocale(String code) {
    final newLocale = Locale(code);
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    _save();
  }
}

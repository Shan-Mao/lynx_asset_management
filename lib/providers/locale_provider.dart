import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  void setLocale(String code) {
    final newLocale = Locale(code);
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }
}

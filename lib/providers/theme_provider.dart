import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/background_storage.dart';

/// Central theme state for the entire app.
class ThemeProvider extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kAmoled = 'theme_amoled';
  static const _kSeedColor = 'theme_seed_color';

  /// 0 = system, 1 = light, 2 = dark
  int _themeModeIndex = 0;
  bool _useAmoled = false;
  Color _seedColor = Colors.teal;

  /// Custom background shown on the Assets and Profile tabs.
  Uint8List? _backgroundImageBytes;

  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Restores the saved theme settings. Call once before the app is shown.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _themeModeIndex = _prefs!.getInt(_kThemeMode) ?? _themeModeIndex;
      _useAmoled = _prefs!.getBool(_kAmoled) ?? _useAmoled;
      final seed = _prefs!.getInt(_kSeedColor);
      if (seed != null) _seedColor = Color(seed);
      _backgroundImageBytes = await loadBackgroundBytes();
      notifyListeners();
    } catch (_) {
      // Storage unavailable – fall back to the built-in defaults.
    }
  }

  /// Persists the current settings. Failures are ignored so the UI stays
  /// responsive even if storage is unavailable.
  Future<void> _save() async {
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setInt(_kThemeMode, _themeModeIndex);
      await prefs.setBool(_kAmoled, _useAmoled);
      await prefs.setInt(_kSeedColor, _seedColor.toARGB32());
    } catch (_) {
      // Ignore storage errors – settings simply won't survive a restart.
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  int get themeModeIndex => _themeModeIndex;
  bool get useAmoled => _useAmoled;
  Color get seedColor => _seedColor;
  Uint8List? get backgroundImageBytes => _backgroundImageBytes;
  bool get hasCustomBackground => _backgroundImageBytes != null;

  ThemeMode get themeMode {
    switch (_themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  set themeModeIndex(int v) {
    if (v == _themeModeIndex) return;
    _themeModeIndex = v;
    notifyListeners();
    _save();
  }

  set useAmoled(bool v) {
    if (v == _useAmoled) return;
    _useAmoled = v;
    notifyListeners();
    _save();
  }

  set seedColor(Color v) {
    if (v.toARGB32() == _seedColor.toARGB32()) return;
    _seedColor = v;
    notifyListeners();
    _save();
  }

  /// Sets (or clears, when null) the custom background for the Assets and
  /// Profile tabs and persists it.
  set backgroundImageBytes(Uint8List? v) {
    if (identical(v, _backgroundImageBytes)) return;
    _backgroundImageBytes = v;
    notifyListeners();
    saveBackgroundBytes(v);
  }

  // ---------------------------------------------------------------------------
  // Build ThemeData
  // ---------------------------------------------------------------------------

  /// Returns the light [ThemeData] built from the custom seed color.
  ThemeData buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  /// Returns the dark [ThemeData] built from the custom seed color.
  ThemeData buildDarkTheme() {
    var scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    if (_useAmoled) {
      scheme = scheme.copyWith(surface: Colors.black);
    }
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _useAmoled ? Colors.black : null,
    );
  }
}

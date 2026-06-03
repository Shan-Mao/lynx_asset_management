import 'package:flutter/material.dart';

/// Central theme state for the entire app.
class ThemeProvider extends ChangeNotifier {
  /// 0 = system, 1 = light, 2 = dark
  int _themeModeIndex = 0;
  bool _useAmoled = false;
  bool _useDynamicColor = true;
  Color _seedColor = Colors.teal;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  int get themeModeIndex => _themeModeIndex;
  bool get useAmoled => _useAmoled;
  bool get useDynamicColor => _useDynamicColor;
  Color get seedColor => _seedColor;

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
  }

  set useAmoled(bool v) {
    if (v == _useAmoled) return;
    _useAmoled = v;
    notifyListeners();
  }

  set useDynamicColor(bool v) {
    if (v == _useDynamicColor) return;
    _useDynamicColor = v;
    notifyListeners();
  }

  set seedColor(Color v) {
    if (v.toARGB32() == _seedColor.toARGB32()) return;
    _seedColor = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Build ThemeData
  // ---------------------------------------------------------------------------

  /// Returns the light [ThemeData] for the current settings.
  ThemeData buildLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }

  /// Returns the dark [ThemeData] for the current settings.
  ThemeData buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: _useAmoled ? Colors.black : null,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _useAmoled ? Colors.black : null,
    );
  }
}

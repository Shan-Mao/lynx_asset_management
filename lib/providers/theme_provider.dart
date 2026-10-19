import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/background_storage.dart';
import '../services/dynamic_color_service.dart';
import '../services/wallpaper_colors.dart';

/// Central theme state for the entire app.
class ThemeProvider extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kAmoled = 'theme_amoled';
  static const _kDynamicColor = 'theme_dynamic_color';
  static const _kSeedColor = 'theme_seed_color';

  /// 0 = system, 1 = light, 2 = dark
  int _themeModeIndex = 0;
  bool _useAmoled = false;
  bool _useDynamicColor = true;
  Color _seedColor = Colors.teal;

  /// Schemes read from the system theme (Monet / desktop accent color).
  /// Not persisted – they are re-read from the platform on every launch.
  DynamicSchemes? _dynamicSchemes;

  /// Wallpaper colors, used as the fallback on Xiaomi HyperOS/MIUI where the
  /// system accent resources stay at the AOSP default blue.
  Color? _wallpaperPrimary;
  String _manufacturer = '';
  int _sdkInt = 0;

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
      _useDynamicColor = _prefs!.getBool(_kDynamicColor) ?? _useDynamicColor;
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
      await prefs.setBool(_kDynamicColor, _useDynamicColor);
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
  bool get useDynamicColor => _useDynamicColor;
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

  set useDynamicColor(bool v) {
    if (v == _useDynamicColor) return;
    _useDynamicColor = v;
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

  /// Applies the schemes read from the platform's dynamic color source.
  void applyDynamicSchemes(DynamicSchemes? schemes) {
    if (identical(schemes, _dynamicSchemes)) return;
    _dynamicSchemes = schemes;
    notifyListeners();
  }

  /// Applies wallpaper colors read by [WallpaperColorsService].
  void applyWallpaperColors(WallpaperColors? info) {
    final primary = info?.primary;
    final manufacturer = info?.manufacturer ?? '';
    final sdkInt = info?.sdkInt ?? 0;
    if (primary?.toARGB32() == _wallpaperPrimary?.toARGB32() &&
        manufacturer == _manufacturer &&
        sdkInt == _sdkInt) {
      return;
    }
    _wallpaperPrimary = primary;
    _manufacturer = manufacturer;
    _sdkInt = sdkInt;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Build ThemeData
  // ---------------------------------------------------------------------------

  /// Returns the light [ThemeData] for the current settings.
  ThemeData buildLightTheme() {
    return ThemeData(
      colorScheme: _schemeFor(Brightness.light),
      useMaterial3: true,
    );
  }

  /// Returns the dark [ThemeData] for the current settings.
  ThemeData buildDarkTheme() {
    var scheme = _schemeFor(Brightness.dark);
    if (_useAmoled) {
      scheme = scheme.copyWith(surface: Colors.black);
    }
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _useAmoled ? Colors.black : null,
    );
  }

  /// Picks the color scheme for [brightness].
  ///
  /// Priority when dynamic color is enabled:
  /// 1. Wallpaper colors on Xiaomi (their Monet resources are often stale)
  /// 2. The platform's dynamic scheme
  /// 3. Wallpaper colors on devices without a usable system palette
  /// 4. The custom seed color
  ColorScheme _schemeFor(Brightness brightness) {
    if (_useDynamicColor) {
      final wallpaper = _wallpaperPrimary;
      // Wallpaper-based theming is a Material You (Android 12+) feature.
      final wallpaperAvailable = wallpaper != null && _sdkInt >= 31;

      if (wallpaperAvailable && _manufacturer.toLowerCase() == 'xiaomi') {
        return DynamicColorService.fromSeedColor(wallpaper)
            .forBrightness(brightness);
      }

      final system = _dynamicSchemes;
      if (system != null) return system.forBrightness(brightness);

      if (wallpaperAvailable) {
        return DynamicColorService.fromSeedColor(wallpaper)
            .forBrightness(brightness);
      }
    }

    return ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
  }
}

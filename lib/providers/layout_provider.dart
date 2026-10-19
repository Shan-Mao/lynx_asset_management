import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset_item.dart';

/// Layout mode for the asset list.
enum LayoutMode { list, grid }

/// Grid item aspect-ratio preset.
enum GridAspect {
  /// V:V — square tile
  vv(1.0, 'V:V'),

  /// V:H — portrait tile (taller than wide)
  vh(3.0 / 4.0, 'V:H'),

  /// H:H — landscape tile (wider than tall)
  hh(4.0 / 3.0, 'H:H');

  const GridAspect(this.ratio, this.label);
  final double ratio;
  final String label;
}

/// Manages the home-screen layout and display preferences.
class LayoutProvider extends ChangeNotifier {
  static const _kMode = 'settings_layout_mode';
  static const _kAspect = 'settings_grid_aspect';
  static const _kColumnsPortrait = 'settings_columns_portrait';
  static const _kColumnsLandscape = 'settings_columns_landscape';
  static const _kHideRetired = 'settings_hide_retired';
  static const _kHideSold = 'settings_hide_sold';

  LayoutMode _mode = LayoutMode.list;
  GridAspect _gridAspect = GridAspect.vv;
  int _columnsPortrait = 2;
  int _columnsLandscape = 3;
  bool _hideRetired = false;
  bool _hideSold = false;

  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Restores the saved layout preferences. Call once before the app is shown.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final modeName = _prefs!.getString(_kMode);
      if (modeName != null) {
        _mode = LayoutMode.values.firstWhere(
          (e) => e.name == modeName,
          orElse: () => _mode,
        );
      }
      final aspectName = _prefs!.getString(_kAspect);
      if (aspectName != null) {
        _gridAspect = GridAspect.values.firstWhere(
          (e) => e.name == aspectName,
          orElse: () => _gridAspect,
        );
      }
      _columnsPortrait =
          (_prefs!.getInt(_kColumnsPortrait) ?? _columnsPortrait).clamp(1, 6);
      _columnsLandscape =
          (_prefs!.getInt(_kColumnsLandscape) ?? _columnsLandscape).clamp(1, 6);
      _hideRetired = _prefs!.getBool(_kHideRetired) ?? _hideRetired;
      _hideSold = _prefs!.getBool(_kHideSold) ?? _hideSold;
      notifyListeners();
    } catch (_) {
      // Storage unavailable – keep the defaults.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setString(_kMode, _mode.name);
      await prefs.setString(_kAspect, _gridAspect.name);
      await prefs.setInt(_kColumnsPortrait, _columnsPortrait);
      await prefs.setInt(_kColumnsLandscape, _columnsLandscape);
      await prefs.setBool(_kHideRetired, _hideRetired);
      await prefs.setBool(_kHideSold, _hideSold);
    } catch (_) {
      // Ignore storage errors – settings won't survive a restart.
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  LayoutMode get mode => _mode;
  GridAspect get gridAspect => _gridAspect;
  int get columnsPortrait => _columnsPortrait;
  int get columnsLandscape => _columnsLandscape;
  bool get isGrid => _mode == LayoutMode.grid;
  bool get hideRetired => _hideRetired;
  bool get hideSold => _hideSold;

  /// Whether [asset] should be shown according to the display filters.
  bool isVisible(AssetItem asset) {
    if (_hideRetired && asset.isRetired) return false;
    if (_hideSold && asset.isSold) return false;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  set mode(LayoutMode v) {
    if (v == _mode) return;
    _mode = v;
    notifyListeners();
    _save();
  }

  set gridAspect(GridAspect v) {
    if (v == _gridAspect) return;
    _gridAspect = v;
    notifyListeners();
    _save();
  }

  set columnsPortrait(int v) {
    final c = v.clamp(1, 6);
    if (c == _columnsPortrait) return;
    _columnsPortrait = c;
    notifyListeners();
    _save();
  }

  set columnsLandscape(int v) {
    final c = v.clamp(1, 6);
    if (c == _columnsLandscape) return;
    _columnsLandscape = c;
    notifyListeners();
    _save();
  }

  set hideRetired(bool v) {
    if (v == _hideRetired) return;
    _hideRetired = v;
    notifyListeners();
    _save();
  }

  set hideSold(bool v) {
    if (v == _hideSold) return;
    _hideSold = v;
    notifyListeners();
    _save();
  }
}

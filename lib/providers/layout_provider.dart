import 'package:flutter/material.dart';

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

/// Manages the home-screen layout preferences (list / grid).
class LayoutProvider extends ChangeNotifier {
  LayoutMode _mode = LayoutMode.list;
  GridAspect _gridAspect = GridAspect.vv;
  int _columnsPortrait = 2;
  int _columnsLandscape = 3;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  LayoutMode get mode => _mode;
  GridAspect get gridAspect => _gridAspect;
  int get columnsPortrait => _columnsPortrait;
  int get columnsLandscape => _columnsLandscape;
  bool get isGrid => _mode == LayoutMode.grid;

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  set mode(LayoutMode v) {
    if (v == _mode) return;
    _mode = v;
    notifyListeners();
  }

  set gridAspect(GridAspect v) {
    if (v == _gridAspect) return;
    _gridAspect = v;
    notifyListeners();
  }

  set columnsPortrait(int v) {
    final c = v.clamp(1, 6);
    if (c == _columnsPortrait) return;
    _columnsPortrait = c;
    notifyListeners();
  }

  set columnsLandscape(int v) {
    final c = v.clamp(1, 6);
    if (c == _columnsLandscape) return;
    _columnsLandscape = c;
    notifyListeners();
  }
}

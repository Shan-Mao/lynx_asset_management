import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Light and dark schemes derived from the system theme color.
class DynamicSchemes {
  const DynamicSchemes({required this.light, required this.dark});

  final ColorScheme light;
  final ColorScheme dark;

  ColorScheme forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Reads Android's Monet palette (and desktop accent colors) and turns it
/// into complete Material 3 color schemes.
///
/// Deliberately does not use `DynamicColorBuilder`: version 1.x of the plugin
/// builds its schemes through the deprecated `Scheme`, which leaves the
/// `surfaceContainer*` tokens unset. Flutter then falls back to `surface` for
/// all of them, so every M3 surface level looks identical.
class DynamicColorService {
  /// Contrast used for dynamic schemes. 0.5 gives adjacent surface levels a
  /// visible tonal difference without turning the UI into high-contrast mode.
  static const contrastLevel = 0.5;

  /// Returns null when the platform has no dynamic color support
  /// (Web, Android 11 and below, desktops without an accent color).
  Future<DynamicSchemes?> read() async {
    try {
      final palette = await DynamicColorPlugin.getCorePalette();
      if (palette != null) {
        // Tonal value 40 of the primary palette is the system seed color.
        return fromSeedColor(Color(palette.primary.get(40)));
      }
    } on PlatformException {
      // Fall through to the desktop accent color path.
    }

    try {
      final accentColor = await DynamicColorPlugin.getAccentColor();
      if (accentColor != null) return fromSeedColor(accentColor);
    } on PlatformException {
      // Not supported on this platform.
    }
    return null;
  }

  /// Builds a complete light/dark pair from [seed].
  ///
  /// `ColorScheme.fromSeed` resolves every current M3 token (including the
  /// surface container hierarchy), unlike the plugin's own scheme builder.
  static DynamicSchemes fromSeedColor(Color seed) => DynamicSchemes(
        light: ColorScheme.fromSeed(
          seedColor: seed,
          contrastLevel: contrastLevel,
        ),
        dark: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          contrastLevel: contrastLevel,
        ),
      );
}

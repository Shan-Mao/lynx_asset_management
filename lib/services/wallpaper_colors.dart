import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Wallpaper colors reported by the Android system.
class WallpaperColors {
  const WallpaperColors({
    required this.manufacturer,
    required this.sdkInt,
    required this.colors,
  });

  /// `Build.MANUFACTURER`, e.g. `Xiaomi`.
  final String manufacturer;

  /// `Build.VERSION.SDK_INT` (31 = Android 12).
  final int sdkInt;

  /// Primary, secondary and tertiary wallpaper colors (ARGB).
  final List<Color> colors;

  Color? get primary => colors.isEmpty ? null : colors.first;

  bool get isXiaomi => manufacturer.toLowerCase() == 'xiaomi';
}

/// Reads the system wallpaper's colors on Android.
///
/// `dynamic_color` reads `android.R.color.system_accent*`. On some Xiaomi
/// HyperOS/MIUI builds those resources are never refreshed for third-party
/// apps and stay at the AOSP default blue, even though the system itself
/// knows the real wallpaper colors. `WallpaperManager.getWallpaperColors()`
/// still reports them, so we can build the ColorScheme from the wallpaper
/// directly and bypass the stale overlay.
class WallpaperColorsService {
  static const channelName =
      'com.example.lynx_asset_management/wallpaper_colors';

  final MethodChannel _channel = const MethodChannel(channelName);
  final StreamController<WallpaperColors> _updates =
      StreamController<WallpaperColors>.broadcast();

  /// Emits new colors when the user changes the wallpaper.
  Stream<WallpaperColors> get updates => _updates.stream;

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Reads the current wallpaper colors, or returns null when unavailable.
  Future<WallpaperColors?> read() async {
    if (!isSupported) return null;
    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getWallpaperColors');
      return _parse(result);
    } catch (_) {
      // Platform missing, method not implemented, or the system refused.
      return null;
    }
  }

  /// Starts listening for wallpaper changes. Call once at startup.
  Future<void> startListening() async {
    if (!isSupported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'wallpaperColorsChanged') return;
      final info = _parse(call.arguments as Map<dynamic, dynamic>?);
      if (info != null) _updates.add(info);
    });
  }

  WallpaperColors? _parse(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    final rawColors = map['colors'];
    if (rawColors is! List) return null;
    final colors = rawColors
        .whereType<num>()
        .map((value) => Color(value.toInt()))
        .toList(growable: false);
    if (colors.isEmpty) return null;
    return WallpaperColors(
      manufacturer: (map['manufacturer'] as String?) ?? '',
      sdkInt: (map['sdkInt'] as num?)?.toInt() ?? 0,
      colors: colors,
    );
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    _updates.close();
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/asset_provider.dart';
import 'providers/layout_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/save_format_provider.dart';
import 'providers/theme_provider.dart';
import 'services/dynamic_color_service.dart';
import 'services/mobile_storage.dart';
import 'services/wallpaper_colors.dart';
import 'services/web_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = kIsWeb ? WebStorageService() : MobileStorageService();

  // Load persisted theme settings before the first frame so the app doesn't
  // flash the default colors on startup.
  final themeProvider = ThemeProvider();
  final profileProvider = ProfileProvider();
  final localeProvider = LocaleProvider();
  final layoutProvider = LayoutProvider();
  final saveFormatProvider = SaveFormatProvider();

  // Read the platform's dynamic color palette and the wallpaper colors in
  // parallel with the saved settings.
  final dynamicColorService = DynamicColorService();
  final dynamicSchemesFuture = dynamicColorService.read();
  final wallpaperColors = WallpaperColorsService();
  final wallpaperColorsFuture = wallpaperColors.read();

  await Future.wait([
    themeProvider.load(),
    profileProvider.load(),
    localeProvider.load(),
    layoutProvider.load(),
    saveFormatProvider.load(),
  ]);

  themeProvider.applyDynamicSchemes(await dynamicSchemesFuture);
  themeProvider.applyWallpaperColors(await wallpaperColorsFuture);
  await wallpaperColors.startListening();
  wallpaperColors.updates.listen((info) {
    themeProvider.applyWallpaperColors(info);
    // Re-read the system palette so non-Xiaomi devices also pick up the new
    // Monet colors without restarting the app.
    dynamicColorService.read().then(themeProvider.applyDynamicSchemes);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssetProvider(storageService: storageService)),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: layoutProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: saveFormatProvider),
      ],
      child: const LynxAssetApp(),
    ),
  );
}


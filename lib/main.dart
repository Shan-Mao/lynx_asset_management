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
import 'services/mobile_storage.dart';
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

  await Future.wait([
    themeProvider.load(),
    profileProvider.load(),
    localeProvider.load(),
    layoutProvider.load(),
    saveFormatProvider.load(),
  ]);

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


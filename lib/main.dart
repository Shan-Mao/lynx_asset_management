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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = kIsWeb ? WebStorageService() : MobileStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssetProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SaveFormatProvider()),
      ],
      child: const LynxAssetApp(),
    ),
  );
}


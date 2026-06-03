import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/shell_screen.dart';
import 'utils/strings.dart';

class LynxAssetApp extends StatelessWidget {
  const LynxAssetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    S.setLanguage(localeProvider.languageCode);

    return MaterialApp(
      title: 'Lynx Asset Management',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeProvider.buildLightTheme(),
      darkTheme: themeProvider.buildDarkTheme(),
      themeMode: themeProvider.themeMode,
      home: ShellScreen(),
    );
  }
}

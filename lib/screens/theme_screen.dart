import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/strings.dart';
import 'seed_color_screen.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();

    if (_tabCtrl.index != tp.themeModeIndex && !_tabCtrl.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabCtrl.animateTo(tp.themeModeIndex);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: S.themeFollowSystem),
            Tab(text: S.themeLight),
            Tab(text: S.themeDark),
          ],
          onTap: (i) => context.read<ThemeProvider>().themeModeIndex = i,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 160,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildModePage(S.themeFollowSystem, Icons.brightness_auto, tp.themeModeIndex == 0),
                _buildModePage(S.themeLight, Icons.light_mode, tp.themeModeIndex == 1),
                _buildModePage(S.themeDark, Icons.dark_mode, tp.themeModeIndex == 2),
              ],
            ),
          ),

          const Divider(),

          SwitchListTile(
            title: Text(S.themeAmoled),
            subtitle: Text(S.themeAmoledSub),
            value: tp.useAmoled,
            onChanged: (v) => tp.useAmoled = v,
          ),

          const Divider(),

          SwitchListTile(
            title: Text(S.themeDynamicColor),
            subtitle: Text(S.themeDynamicColorSub),
            value: tp.useDynamicColor,
            onChanged: (v) => tp.useDynamicColor = v,
          ),

          if (!tp.useDynamicColor) ...[
            const Divider(),

            ListTile(
              title: Text(S.themeSeedColor),
              trailing: Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: tp.seedColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeedColorScreen()),
                );
              },
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildModePage(String label, IconData icon, bool active) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        final tp = context.read<ThemeProvider>();
        if (label == S.themeFollowSystem) {
          tp.themeModeIndex = 0;
        } else if (label == S.themeLight) {
          tp.themeModeIndex = 1;
        } else {
          tp.themeModeIndex = 2;
        }
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48,
                color: active ? theme.colorScheme.primary : theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            if (active)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.inventory_2,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  S.profileTitle,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              S.aboutDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const Divider(),

          _FeatureTile(icon: Icons.add_circle_outline, title: S.aboutFeatureAsset, theme: theme),
          _FeatureTile(icon: Icons.trending_down, title: S.aboutFeatureDaily, theme: theme),
          _FeatureTile(icon: Icons.swap_horiz, title: S.aboutFeatureImportExport, theme: theme),
          _FeatureTile(icon: Icons.phone_android, title: S.aboutFeatureCrossPlatform, theme: theme),
          _FeatureTile(icon: Icons.dark_mode_outlined, title: S.aboutFeatureDarkMode, theme: theme),

          const Divider(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.theme});
  final IconData icon;
  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 20),
      ),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

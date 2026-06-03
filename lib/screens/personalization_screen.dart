import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../utils/strings.dart';
import 'save_format_screen.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceLabel = kIsWeb ? S.personalizationWeb : S.personalizationAndroid;
    final deviceIcon = kIsWeb ? Icons.language : Icons.phone_android;

    return Scaffold(
      appBar: AppBar(title: const Text(''), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ---- Device Type ----
        ListTile(
          leading: Icon(deviceIcon),
          title: Text(S.personalizationDevice),
          subtitle: Text(deviceLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // ---- Save Format ----
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(S.personalizationSaveFormat),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaveFormatScreen())),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // ---- Preview ----
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.personalizationPreview, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                '{export_date}_{user_name}_assets_export.txt',
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/strings.dart';

/// Lets the user choose or remove the background shown on the Assets and
/// Profile tabs.
class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(S.backgroundPickFailed)));
      }
      return;
    }
    if (!context.mounted) return;
    context.read<ThemeProvider>().backgroundImageBytes = bytes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = context.watch<ThemeProvider>().backgroundImageBytes;

    return Scaffold(
      appBar: AppBar(title: Text(S.backgroundTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bytes == null
                  ? ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              S.backgroundEmpty,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(S.backgroundPick),
          ),
          if (bytes != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                context.read<ThemeProvider>().backgroundImageBytes = null;
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(S.backgroundRemove),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            S.backgroundNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Paints the user's custom background behind [child].
///
/// Used only by the two top-level pages (Assets and Profile). When no custom
/// background is configured this is a no-op, so [child] looks exactly as
/// before. A translucent surface scrim keeps text readable on busy images.
class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bytes = context.watch<ThemeProvider>().backgroundImageBytes;
    if (bytes == null) return child;

    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    // Decode at roughly screen resolution instead of the original photo size.
    final cacheWidth = (width * dpr).round().clamp(1, 2048);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          bytes,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
        ColoredBox(
          color: theme.colorScheme.surface.withValues(alpha: 0.75),
        ),
        child,
      ],
    );
  }
}

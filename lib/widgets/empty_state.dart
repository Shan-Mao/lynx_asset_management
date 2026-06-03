import 'package:flutter/material.dart';
import '../utils/strings.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      const SizedBox(height: 16),
      Text(S.homeNoAssetsTitle, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 8),
      Text(S.homeNoAssetsHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
    ])));
  }
}

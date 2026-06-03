import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/strings.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key, required this.assetCount, required this.totalValue, required this.totalDailyCost});
  final int assetCount;
  final double totalValue;
  final double totalDailyCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _StatColumn(label: S.homeSummaryAssets, value: '$assetCount', theme: theme),
        _StatColumn(label: S.homeSummaryValue, value: formatCurrency(totalValue), theme: theme),
        _StatColumn(label: S.homeSummaryDaily, value: formatCurrency(totalDailyCost), theme: theme),
      ]),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value, required this.theme});
  final String label; final String value; final ThemeData theme;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
  ]);
}

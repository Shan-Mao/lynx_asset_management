import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import '../utils/formatters.dart';
import '../utils/strings.dart';
import 'daily_cost_chip.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.asset, this.onTap});
  final AssetItem asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.onPrimaryContainer, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(asset.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (asset.isSold) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)), child: Text(S.cardSold, style: TextStyle(fontSize: 10, color: Colors.red.shade800))),
            if (asset.isRetired) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)), child: Text(S.cardRetired, style: TextStyle(fontSize: 10, color: Colors.grey.shade700))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(formatCurrency(asset.totalCost), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('· ${formatDays(asset.daysSincePurchase)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ]),
        ])),
        DailyCostChip(dailyCost: asset.dailyCost),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: 20),
      ]))),
    );
  }
}

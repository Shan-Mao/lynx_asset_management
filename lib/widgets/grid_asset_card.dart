import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import '../utils/formatters.dart';
import '../utils/strings.dart';

/// Compact card used in grid layout mode.
class GridAssetCard extends StatelessWidget {
  const GridAssetCard({super.key, required this.asset, required this.aspectRatio, this.onTap});
  final AssetItem asset;
  final double aspectRatio; // width / height
  final VoidCallback? onTap;

  Color get _costColor {
    if (asset.dailyCost < 10) return Colors.green.shade100;
    if (asset.dailyCost < 50) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Color get _costTextColor {
    if (asset.dailyCost < 10) return Colors.green.shade800;
    if (asset.dailyCost < 50) return Colors.orange.shade800;
    return Colors.red.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + name + status badges
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.onPrimaryContainer, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        asset.name,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (asset.isSold || asset.isRetired) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    if (asset.isSold)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(3)),
                        child: Text(S.cardSold, style: TextStyle(fontSize: 9, color: Colors.red.shade800)),
                      ),
                    if (asset.isSold && asset.isRetired) const SizedBox(width: 4),
                    if (asset.isRetired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3)),
                        child: Text(S.cardRetired, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
                      ),
                  ]),
                ],
                const Spacer(),
                // Bottom: cost info + daily chip
                Text(formatCurrency(asset.totalCost), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(formatDays(asset.daysSincePurchase), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 11)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _costColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '${formatCurrency(asset.dailyCost)}${S.detailPerDay}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _costTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

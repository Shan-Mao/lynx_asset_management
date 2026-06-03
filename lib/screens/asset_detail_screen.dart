import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_provider.dart';
import '../utils/formatters.dart';
import '../utils/strings.dart';
import 'add_edit_asset_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AssetProvider>();
    final asset = provider.assets.where((a) => a.id == assetId).firstOrNull;

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(S.detailNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: S.detailEdit,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditAssetScreen(asset: asset)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: S.detailDelete,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(S.detailDeleteTitle),
                  content: Text(S.detailDeleteConfirm(asset.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(S.detailCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(S.detailDelete),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                context.read<AssetProvider>().deleteAsset(assetId);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        S.detailDailyCost,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency(asset.dailyCost),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.detailPerDay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: S.detailBasicInfo, theme: theme),
            const SizedBox(height: 8),
            _DetailRow(label: S.detailName, value: asset.name, theme: theme),
            _DetailRow(label: S.detailPrice, value: formatCurrency(asset.price), theme: theme),
            _DetailRow(label: S.detailAdditionalCost, value: formatCurrency(asset.additionalCost), theme: theme),
            _DetailRow(label: S.detailTotalCost, value: formatCurrency(asset.totalCost), theme: theme, valueBold: true),
            _DetailRow(label: S.detailPurchaseDate, value: formatDate(asset.purchaseDate), theme: theme),
            _DetailRow(label: S.detailDaysOwned, value: S.detailDays(asset.daysSincePurchase), theme: theme),
            if (asset.expiryDate != null)
              _DetailRow(label: S.formExpiryDate, value: formatDate(asset.expiryDate!), theme: theme),

            const SizedBox(height: 20),

            _SectionTitle(title: S.detailStatus, theme: theme),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 6,
              children: [
                if (asset.isRetired) _StatusChip(label: S.detailStatusRetired, color: Colors.grey),
                if (asset.isSold) _StatusChip(label: S.detailStatusSold, color: Colors.red),
                if (asset.excludeFromTotal) _StatusChip(label: S.detailExcludedTotal, color: Colors.orange),
                if (asset.excludeFromDaily) _StatusChip(label: S.detailExcludedDaily, color: Colors.orange),
                if (!asset.isRetired && !asset.isSold && !asset.excludeFromTotal && !asset.excludeFromDaily)
                  _StatusChip(label: S.detailStatusNormal, color: Colors.green),
              ],
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: S.detailClassification, theme: theme),
            const SizedBox(height: 8),
            _DetailRow(label: S.detailCategory, value: asset.category.isNotEmpty ? asset.category : '—', theme: theme),
            _DetailRow(label: S.detailTags, value: asset.tags.isNotEmpty ? asset.tags.join(', ') : '—', theme: theme),
            _DetailRow(label: S.detailAdditionalItems, value: asset.additionalItems.isNotEmpty ? asset.additionalItems.join(', ') : '—', theme: theme),

            if (asset.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(title: S.detailNotes, theme: theme),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(asset.notes, style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
    backgroundColor: color, visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.theme});
  final String title;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) => Text(
    title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.theme, this.valueBold = false});
  final String label;
  final String value;
  final ThemeData theme;
  final bool valueBold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: valueBold ? FontWeight.w600 : null))),
      ],
    ),
  );
}

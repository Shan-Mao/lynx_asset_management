import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/asset_item.dart';
import '../providers/asset_provider.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';

class AddEditAssetScreen extends StatefulWidget {
  const AddEditAssetScreen({super.key, this.asset});

  final AssetItem? asset;

  bool get isEditing => asset != null;

  @override
  State<AddEditAssetScreen> createState() => _AddEditAssetScreenState();
}

class _AddEditAssetScreenState extends State<AddEditAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _additionalCostCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _purchaseDate;
  late List<String> _tags;
  late List<String> _additionalItems;
  late bool _excludeFromTotal;
  late bool _excludeFromDaily;
  late bool _isRetired;
  late bool _isSold;
  DateTime? _expiryDate;

  final List<String> _categories = List.from(defaultCategories);

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _priceCtrl = TextEditingController(text: a != null ? a.price.toStringAsFixed(2) : '');
    _additionalCostCtrl = TextEditingController(
        text: (a != null && a.additionalCost > 0) ? a.additionalCost.toStringAsFixed(2) : '');
    _categoryCtrl = TextEditingController(text: a?.category ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _purchaseDate = a?.purchaseDate ?? DateTime.now();
    _tags = a != null ? List.from(a.tags) : [];
    _additionalItems = a != null ? List.from(a.additionalItems) : [];
    _excludeFromTotal = a?.excludeFromTotal ?? false;
    _excludeFromDaily = a?.excludeFromDaily ?? false;
    _isRetired = a?.isRetired ?? false;
    _isSold = a?.isSold ?? false;
    _expiryDate = a?.expiryDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _additionalCostCtrl.dispose();
    _categoryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final additionalCost = double.tryParse(_additionalCostCtrl.text) ?? 0.0;

    final asset = AssetItem(
      id: widget.asset?.id,
      name: _nameCtrl.text.trim(),
      price: price,
      additionalCost: additionalCost,
      purchaseDate: _purchaseDate,
      category: _categoryCtrl.text.trim(),
      tags: _tags,
      additionalItems: _additionalItems,
      notes: _notesCtrl.text.trim(),
      excludeFromTotal: _excludeFromTotal,
      excludeFromDaily: _excludeFromDaily,
      isRetired: _isRetired,
      isSold: _isSold,
      expiryDate: _expiryDate,
    );

    final provider = context.read<AssetProvider>();
    if (widget.isEditing) {
      provider.updateAsset(widget.asset!.id, asset);
    } else {
      provider.addAsset(asset);
    }

    Navigator.pop(context);
  }

  void _addChip(List<String> target, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !target.contains(trimmed)) {
      setState(() => target.add(trimmed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: S.formNameLabel,
                  hintText: S.formNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? S.formNameRequired : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(
                  labelText: S.formPriceLabel,
                  hintText: '0.00',
                  prefixText: '¥ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return S.formPriceRequired;
                  if (double.tryParse(v) == null) return S.formPriceInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _additionalCostCtrl,
                decoration: InputDecoration(
                  labelText: S.formAdditionalCost,
                  hintText: '0.00',
                  prefixText: '¥ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _purchaseDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: S.formPurchaseDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(AssetItem.formatDateStr(_purchaseDate), style: theme.textTheme.bodyLarge),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: _purchaseDate,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _expiryDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: S.formExpiryDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: _expiryDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _expiryDate = null),
                          )
                        : const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expiryDate != null ? AssetItem.formatDateStr(_expiryDate) : S.formExpiryNotSet,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _expiryDate != null ? null : theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Autocomplete<String>(
                optionsBuilder: (v) {
                  final q = v.text.toLowerCase();
                  return _categories.where((c) => c.toLowerCase().contains(q));
                },
                initialValue: _categoryCtrl.text.isNotEmpty ? TextEditingValue(text: _categoryCtrl.text) : null,
                onSelected: (value) => _categoryCtrl.text = value,
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  return TextFormField(
                    controller: _categoryCtrl,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: S.formCategoryLabel,
                      hintText: S.formCategoryHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  );
                },
              ),
              const SizedBox(height: 16),

              _ChipInput(
                label: S.formTagsLabel,
                chips: _tags,
                onAdded: (v) => _addChip(_tags, v),
                onDeleted: (v) => setState(() => _tags.remove(v)),
              ),
              const SizedBox(height: 16),

              _ChipInput(
                label: S.formAdditionalItemsLabel,
                chips: _additionalItems,
                onAdded: (v) => _addChip(_additionalItems, v),
                onDeleted: (v) => setState(() => _additionalItems.remove(v)),
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(S.formExcludeTotal),
                subtitle: Text(S.formExcludeTotalSub),
                value: _excludeFromTotal,
                onChanged: (v) => setState(() => _excludeFromTotal = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(S.formExcludeDaily),
                subtitle: Text(S.formExcludeDailySub),
                value: _excludeFromDaily,
                onChanged: (v) => setState(() => _excludeFromDaily = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(S.formRetired),
                subtitle: Text(S.formRetiredSub),
                value: _isRetired,
                onChanged: (v) => setState(() => _isRetired = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(S.formSold),
                subtitle: Text(S.formSoldSub),
                value: _isSold,
                onChanged: (v) => setState(() => _isSold = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: S.formNotesLabel,
                  hintText: S.formNotesHint,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _save,
                icon: Icon(widget.isEditing ? Icons.check : Icons.add),
                label: Text(widget.isEditing ? S.formSave : S.formAdd),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipInput extends StatefulWidget {
  const _ChipInput({required this.label, required this.chips, required this.onAdded, required this.onDeleted});
  final String label;
  final List<String> chips;
  final ValueChanged<String> onAdded;
  final ValueChanged<String> onDeleted;

  @override
  State<_ChipInput> createState() => _ChipInputState();
}

class _ChipInputState extends State<_ChipInput> {
  final _ctrl = TextEditingController();

  void _submit() {
    final value = _ctrl.text.trim();
    if (value.isNotEmpty) {
      widget.onAdded(value);
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: S.formChipHint,
                border: const OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _submit, icon: const Icon(Icons.add, size: 20)),
        ]),
        if (widget.chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: widget.chips.map((chip) {
              return Chip(
                label: Text(chip, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => widget.onDeleted(chip),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

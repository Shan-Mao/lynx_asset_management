import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Represents a single asset item with all its metadata.
class AssetItem {
  final String id;
  final String name;
  final double price;
  final double additionalCost;
  final DateTime purchaseDate;
  final String category;
  final List<String> tags;
  final List<String> additionalItems;
  final String notes;

  // ---- New flags ----
  final bool excludeFromTotal;   // 不计入总资产
  final bool excludeFromDaily;   // 不计入日均
  final bool isRetired;          // 退役
  final bool isSold;             // 已卖出
  final DateTime? expiryDate;    // 到期日期 (null = 无)

  AssetItem({
    String? id,
    required this.name,
    required this.price,
    this.additionalCost = 0.0,
    required this.purchaseDate,
    required this.category,
    List<String>? tags,
    List<String>? additionalItems,
    this.notes = '',
    this.excludeFromTotal = false,
    this.excludeFromDaily = false,
    this.isRetired = false,
    this.isSold = false,
    this.expiryDate,
  })  : id = id ?? _uuid.v4(),
        tags = tags ?? [],
        additionalItems = additionalItems ?? [];

  /// Total cost = price + additional cost.
  double get totalCost => price + additionalCost;

  /// Number of days since purchase (minimum 1 to avoid division by zero).
  int get daysSincePurchase {
    final days = DateTime.now().difference(purchaseDate).inDays;
    return days < 1 ? 1 : days;
  }

  /// Daily average cost = total cost / days since purchase.
  double get dailyCost => totalCost / daysSincePurchase;

  // ---------------------------------------------------------------------------
  // JSON serialization (for internal storage)
  // ---------------------------------------------------------------------------

  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      additionalCost: (json['additionalCost'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      additionalItems:
          (json['additionalItems'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String? ?? '',
      excludeFromTotal: json['excludeFromTotal'] as bool? ?? false,
      excludeFromDaily: json['excludeFromDaily'] as bool? ?? false,
      isRetired: json['isRetired'] as bool? ?? false,
      isSold: json['isSold'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'additionalCost': additionalCost,
      'purchaseDate': formatDateStr(purchaseDate),
      'category': category,
      'tags': tags,
      'additionalItems': additionalItems,
      'notes': notes,
      'excludeFromTotal': excludeFromTotal,
      'excludeFromDaily': excludeFromDaily,
      'isRetired': isRetired,
      'isSold': isSold,
      if (expiryDate != null) 'expiryDate': formatDateStr(expiryDate!),
    };
  }

  // ---------------------------------------------------------------------------
  // TXT serialization (for export / import)
  // ---------------------------------------------------------------------------

  /// Serializes this asset to a TXT block.
  static const _keyToTxt = <String, String>{
    'id': 'id',
    'name': 'name',
    'price': 'price',
    'additional_cost': 'additionalCost',
    'purchase_date': 'purchaseDate',
    'category': 'category',
    'tags': 'tags',
    'additional_items': 'additionalItems',
    'notes': 'notes',
    'exclude_total': 'excludeFromTotal',
    'exclude_daily': 'excludeFromDaily',
    'retired': 'isRetired',
    'sold': 'isSold',
    'expiry_date': 'expiryDate',
  };

  String toTxt({String separator = ': ', Set<String>? selectedFields}) {
    final fields = selectedFields ?? _keyToTxt.keys.toSet();
    final buf = StringBuffer();
    buf.writeln('===ASSET===');
    for (final key in _keyTxtOrder) {
      if (!fields.contains(key)) continue;
      final txtKey = _keyToTxt[key] ?? key;
      final value = _fieldValue(txtKey);
      if (value != null) {
        buf.writeln('$txtKey$separator$value');
      }
    }
    buf.writeln('===END===');
    return buf.toString();
  }

  static const _keyTxtOrder = [
    'id', 'name', 'price', 'additional_cost', 'purchase_date',
    'category', 'tags', 'additional_items', 'notes',
    'exclude_total', 'exclude_daily', 'retired', 'sold', 'expiry_date',
  ];

  String? _fieldValue(String txtKey) {
    switch (txtKey) {
      case 'id': return id;
      case 'name': return name;
      case 'price': return price.toStringAsFixed(2);
      case 'additionalCost': return additionalCost.toStringAsFixed(2);
      case 'purchaseDate': return formatDateStr(purchaseDate);
      case 'category': return category;
      case 'tags': return tags.join(', ');
      case 'additionalItems': return additionalItems.join(', ');
      case 'notes': return notes.replaceAll('\n', r'\n');
      case 'excludeFromTotal': return excludeFromTotal.toString();
      case 'excludeFromDaily': return excludeFromDaily.toString();
      case 'isRetired': return isRetired.toString();
      case 'isSold': return isSold.toString();
      case 'expiryDate': return expiryDate != null ? formatDateStr(expiryDate!) : null;
      default: return null;
    }
  }

  /// Parses an [AssetItem] from a TXT block string.
  factory AssetItem.fromTxt(String block) {
    final lines = block.split('\n');
    String id = '';
    String name = '';
    double price = 0.0;
    double additionalCost = 0.0;
    DateTime purchaseDate = DateTime.now();
    String category = '';
    List<String> tags = [];
    List<String> additionalItems = [];
    String notes = '';
    bool excludeFromTotal = false;
    bool excludeFromDaily = false;
    bool isRetired = false;
    bool isSold = false;
    DateTime? expiryDate;

    String? currentNotes;
    bool inNotes = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line == '===ASSET===' || line == '===END===') {
        continue;
      }

      if (inNotes && line.contains(': ')) {
        // Next field detected – flush accumulated notes
        notes = (currentNotes ?? '').trim();
        inNotes = false;
        currentNotes = null;
      }

      final colonIdx = line.indexOf(': ');
      if (colonIdx == -1) {
        if (inNotes && currentNotes != null) {
          currentNotes += '\n$line';
        }
        continue;
      }

      final key = line.substring(0, colonIdx).trim();
      final value = line.substring(colonIdx + 2).trim();

      switch (key) {
        case 'id':
          id = value;
        case 'name':
          name = value;
        case 'price':
          price = double.tryParse(value) ?? 0.0;
        case 'additionalCost':
          additionalCost = double.tryParse(value) ?? 0.0;
        case 'purchaseDate':
          purchaseDate = DateTime.tryParse(value) ?? DateTime.now();
        case 'category':
          category = value;
        case 'tags':
          tags = _splitCsv(value);
        case 'additionalItems':
          additionalItems = _splitCsv(value);
        case 'notes':
          if (value.isEmpty) {
            notes = '';
          } else {
            currentNotes = value.replaceAll(r'\n', '\n');
            inNotes = true;
          }
        case 'excludeFromTotal':
          excludeFromTotal = value.toLowerCase() == 'true';
        case 'excludeFromDaily':
          excludeFromDaily = value.toLowerCase() == 'true';
        case 'isRetired':
          isRetired = value.toLowerCase() == 'true';
        case 'isSold':
          isSold = value.toLowerCase() == 'true';
        case 'expiryDate':
          expiryDate = DateTime.tryParse(value);
      }
    }

    // Capture any trailing notes
    if (inNotes && currentNotes != null) {
      notes = currentNotes.trim();
    }

    return AssetItem(
      id: id.isNotEmpty ? id : null,
      name: name,
      price: price,
      additionalCost: additionalCost,
      purchaseDate: purchaseDate,
      category: category,
      tags: tags,
      additionalItems: additionalItems,
      notes: notes,
      excludeFromTotal: excludeFromTotal,
      excludeFromDaily: excludeFromDaily,
      isRetired: isRetired,
      isSold: isSold,
      expiryDate: expiryDate,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AssetItem copyWith({
    String? name,
    double? price,
    double? additionalCost,
    DateTime? purchaseDate,
    String? category,
    List<String>? tags,
    List<String>? additionalItems,
    String? notes,
    bool? excludeFromTotal,
    bool? excludeFromDaily,
    bool? isRetired,
    bool? isSold,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
  }) {
    return AssetItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      additionalCost: additionalCost ?? this.additionalCost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      category: category ?? this.category,
      tags: tags ?? List<String>.from(this.tags),
      additionalItems: additionalItems ?? List<String>.from(this.additionalItems),
      notes: notes ?? this.notes,
      excludeFromTotal: excludeFromTotal ?? this.excludeFromTotal,
      excludeFromDaily: excludeFromDaily ?? this.excludeFromDaily,
      isRetired: isRetired ?? this.isRetired,
      isSold: isSold ?? this.isSold,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
    );
  }

  static String formatDateStr(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${_p(date.month)}-${_p(date.day)}';
  }

  static String _p(int n) => n.toString().padLeft(2, '0');

  static List<String> _splitCsv(String value) {
    if (value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

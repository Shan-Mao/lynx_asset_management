import 'package:flutter/foundation.dart';

/// Shared export format settings used by SaveFormatScreen and export functions.
class SaveFormatProvider extends ChangeNotifier {
  String _fileNameTemplate = '{export_date}_{user_name}_assets_export';
  String _encoding = 'UTF-8';
  String _separator = ': ';

  static const _allFieldKeys = [
    'id', 'name', 'price', 'additional_cost', 'purchase_date',
    'category', 'tags', 'additional_items', 'notes',
    'exclude_total', 'exclude_daily', 'retired', 'sold', 'expiry_date',
  ];

  final Set<String> _selectedFields = {
    'id', 'name', 'price', 'additional_cost', 'purchase_date',
    'category', 'tags', 'additional_items', 'notes',
    'exclude_total', 'exclude_daily', 'retired', 'sold',
  };

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get fileNameTemplate => _fileNameTemplate;
  String get encoding => _encoding;
  String get separator => _separator;
  Set<String> get selectedFields => Set.unmodifiable(_selectedFields);
  static List<String> get allFieldKeys => List.unmodifiable(_allFieldKeys);

  /// Whether the given field key is included in the export.
  bool isFieldSelected(String key) => _selectedFields.contains(key);

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  set fileNameTemplate(String v) {
    if (v == _fileNameTemplate) return;
    _fileNameTemplate = v;
    notifyListeners();
  }

  set encoding(String v) {
    if (v == _encoding) return;
    _encoding = v;
    notifyListeners();
  }

  set separator(String v) {
    if (v == _separator) return;
    _separator = v;
    notifyListeners();
  }

  void toggleField(String key) {
    if (_selectedFields.contains(key)) {
      _selectedFields.remove(key);
    } else {
      _selectedFields.add(key);
    }
    notifyListeners();
  }
}

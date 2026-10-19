import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared export format settings used by SaveFormatScreen and export functions.
class SaveFormatProvider extends ChangeNotifier {
  static const _kFileNameTemplate = 'settings_export_filename_template';
  static const _kEncoding = 'settings_export_encoding';
  static const _kSeparator = 'settings_export_separator';
  static const _kFields = 'settings_export_fields';

  String _fileNameTemplate = '{export_date}_{user_name}_assets_export';
  String _encoding = 'UTF-8';
  String _separator = ': ';

  static const _allFieldKeys = [
    'id', 'name', 'price', 'additional_cost', 'purchase_date',
    'category', 'tags', 'additional_items', 'notes',
    'exclude_total', 'exclude_daily', 'retired', 'sold', 'expiry_date',
  ];

  static const _defaultFieldKeys = {
    'id', 'name', 'price', 'additional_cost', 'purchase_date',
    'category', 'tags', 'additional_items', 'notes',
    'exclude_total', 'exclude_daily', 'retired', 'sold',
  };

  final Set<String> _selectedFields = {..._defaultFieldKeys};

  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Restores the saved export format. Call once before the app is shown.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _fileNameTemplate =
          _prefs!.getString(_kFileNameTemplate) ?? _fileNameTemplate;
      _encoding = _prefs!.getString(_kEncoding) ?? _encoding;
      _separator = _prefs!.getString(_kSeparator) ?? _separator;
      final fields = _prefs!.getStringList(_kFields);
      if (fields != null) {
        _selectedFields
          ..clear()
          ..addAll(fields.where(_allFieldKeys.contains));
      }
      notifyListeners();
    } catch (_) {
      // Storage unavailable – keep the defaults.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setString(_kFileNameTemplate, _fileNameTemplate);
      await prefs.setString(_kEncoding, _encoding);
      await prefs.setString(_kSeparator, _separator);
      await prefs.setStringList(_kFields, _selectedFields.toList());
    } catch (_) {
      // Ignore storage errors – settings won't survive a restart.
    }
  }

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
    _save();
  }

  set encoding(String v) {
    if (v == _encoding) return;
    _encoding = v;
    notifyListeners();
    _save();
  }

  set separator(String v) {
    if (v == _separator) return;
    _separator = v;
    notifyListeners();
    _save();
  }

  void toggleField(String key) {
    if (_selectedFields.contains(key)) {
      _selectedFields.remove(key);
    } else {
      _selectedFields.add(key);
    }
    notifyListeners();
    _save();
  }
}

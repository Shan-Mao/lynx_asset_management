import 'package:flutter/foundation.dart';

import '../models/asset_item.dart';
import '../services/export_import.dart';
import '../services/storage_service.dart';

/// Central state manager for the asset list.
///
/// Exposes CRUD operations and export/import functionality.
class AssetProvider extends ChangeNotifier {
  AssetProvider({required this.storageService});

  final StorageService storageService;

  List<AssetItem> _assets = [];
  bool _loaded = false;

  /// Unmodifiable view of the current asset list.
  List<AssetItem> get assets => List.unmodifiable(_assets);

  /// Whether the initial load has completed.
  bool get isLoaded => _loaded;

  /// Total combined value (excludes assets marked excludeFromTotal).
  double get totalValue => _assets
      .where((a) => !a.excludeFromTotal)
      .fold(0, (sum, a) => sum + a.totalCost);

  /// Number of assets.
  int get assetCount => _assets.length;

  /// Sum of daily costs (excludes assets marked excludeFromDaily).
  double get totalDailyCost => _assets
      .where((a) => !a.excludeFromDaily)
      .fold(0, (sum, a) => sum + a.dailyCost);

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Loads assets from storage. Call once on app start.
  Future<void> loadAssets() async {
    _assets = await storageService.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() => storageService.save(_assets);

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Adds a new asset and persists.
  void addAsset(AssetItem asset) {
    _assets.add(asset);
    _persist();
    notifyListeners();
  }

  /// Updates an existing asset (matched by [id]) and persists.
  void updateAsset(String id, AssetItem updated) {
    final idx = _assets.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    _assets[idx] = updated;
    _persist();
    notifyListeners();
  }

  /// Deletes the asset with the given [id] and persists.
  void deleteAsset(String id) {
    _assets.removeWhere((a) => a.id == id);
    _persist();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Export / Import
  // ---------------------------------------------------------------------------

  /// Serializes all assets to a TXT string.
  String exportToTxt({String separator = ': ', Set<String>? selectedFields}) =>
      ExportImportService.exportToTxt(_assets, separator: separator, selectedFields: selectedFields);

  /// Replaces the current asset list with assets parsed from [txtContent].
  /// Returns the number of successfully imported assets.
  int importFromTxt(String txtContent) {
    final imported = ExportImportService.importFromTxt(txtContent);
    _assets = imported;
    _persist();
    notifyListeners();
    return imported.length;
  }
}

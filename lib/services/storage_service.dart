import '../models/asset_item.dart';

/// Abstract interface for asset persistence.
///
/// * [MobileStorageService] persists to a local JSON file.
/// * [WebStorageService] keeps data in memory only.
abstract class StorageService {
  /// Loads all assets from storage.
  Future<List<AssetItem>> load();

  /// Saves all assets to storage (no-op on web).
  Future<void> save(List<AssetItem> assets);
}

import '../models/asset_item.dart';
import 'storage_service.dart';

/// Ephemeral in-memory storage for the web platform.
///
/// Data is lost when the page is refreshed or closed.
/// Users should export before leaving.
class WebStorageService extends StorageService {
  final List<AssetItem> _assets = [];

  @override
  Future<List<AssetItem>> load() async => List.from(_assets);

  @override
  Future<void> save(List<AssetItem> assets) async {
    _assets
      ..clear()
      ..addAll(assets);
  }
}

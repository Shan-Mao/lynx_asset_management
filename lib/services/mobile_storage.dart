import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/asset_item.dart';
import 'storage_service.dart';

/// Persists assets as a JSON file in the app's documents directory.
class MobileStorageService extends StorageService {
  static const _filename = 'lynx_assets.json';

  @override
  Future<List<AssetItem>> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_filename');
      if (!await file.exists()) return [];
      final content = await file.readAsString(encoding: utf8);
      final list = json.decode(content) as List<dynamic>;
      return list
          .map((e) => AssetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<AssetItem> assets) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_filename');
      final jsonList = assets.map((a) => a.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (_) {
      // Silently fail – data may be lost but app continues.
    }
  }
}

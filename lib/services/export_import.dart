import '../models/asset_item.dart';

/// Handles TXT serialization / deserialization for asset export and import.
class ExportImportService {
  ExportImportService._();

  /// Serializes the given [assets] into a TXT string.
  static String exportToTxt(List<AssetItem> assets, {String separator = ': ', Set<String>? selectedFields}) {
    final buf = StringBuffer();
    buf.writeln('# Lynx Asset Management - Export');
    buf.writeln('# Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln('# Total assets: ${assets.length}');
    buf.writeln('');
    for (final asset in assets) {
      buf.writeln(asset.toTxt(separator: separator, selectedFields: selectedFields));
    }
    return buf.toString();
  }

  /// Parses a TXT [content] string into a list of [AssetItem].
  ///
  /// Returns an empty list if the content is malformed.
  static List<AssetItem> importFromTxt(String content) {
    final assets = <AssetItem>[];
    final blocks = _splitBlocks(content);
    for (final block in blocks) {
      try {
        assets.add(AssetItem.fromTxt(block));
      } catch (_) {
        // Skip malformed blocks.
      }
    }
    return assets;
  }

  /// Splits raw TXT content into per-asset blocks.
  static List<String> _splitBlocks(String content) {
    final blocks = <String>[];
    final lines = content.split('\n');
    final current = <String>[];
    bool inBlock = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed == '===ASSET===') {
        inBlock = true;
        current.clear();
        current.add(line);
      } else if (trimmed == '===END===') {
        if (inBlock) {
          current.add(line);
          blocks.add(current.join('\n'));
          inBlock = false;
        }
      } else if (inBlock) {
        current.add(line);
      }
    }
    return blocks;
  }
}

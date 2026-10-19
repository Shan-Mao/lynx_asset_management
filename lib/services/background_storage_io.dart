import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

const _fileName = 'lynx_page_background.png';

Future<File> _backgroundFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$_fileName');
}

Future<Uint8List?> loadBackgroundBytesImpl() async {
  try {
    final file = await _backgroundFile();
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

Future<void> saveBackgroundBytesImpl(Uint8List? bytes) async {
  try {
    final file = await _backgroundFile();
    if (bytes == null) {
      if (await file.exists()) await file.delete();
    } else {
      await file.writeAsBytes(bytes, flush: true);
    }
  } catch (_) {
    // Storage unavailable – the background won't survive a restart.
  }
}

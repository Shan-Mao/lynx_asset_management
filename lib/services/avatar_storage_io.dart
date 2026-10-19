import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

const _fileName = 'lynx_profile_avatar.png';

Future<File> _avatarFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$_fileName');
}

Future<Uint8List?> loadAvatarBytesImpl() async {
  try {
    final file = await _avatarFile();
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

Future<void> saveAvatarBytesImpl(Uint8List? bytes) async {
  try {
    final file = await _avatarFile();
    if (bytes == null) {
      if (await file.exists()) await file.delete();
    } else {
      await file.writeAsBytes(bytes, flush: true);
    }
  } catch (_) {
    // Storage unavailable – the avatar simply won't survive a restart.
  }
}

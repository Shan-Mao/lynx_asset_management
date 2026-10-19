import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

const _key = 'profile_avatar_base64';

Future<Uint8List?> loadAvatarBytesImpl() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return null;
    return base64Decode(encoded);
  } catch (_) {
    return null;
  }
}

Future<void> saveAvatarBytesImpl(Uint8List? bytes) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (bytes == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, base64Encode(bytes));
    }
  } catch (_) {
    // Storage unavailable – the avatar simply won't survive a restart.
  }
}

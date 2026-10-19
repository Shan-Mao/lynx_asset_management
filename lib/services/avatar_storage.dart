import 'dart:typed_data';

import 'avatar_storage_io.dart'
    if (dart.library.js_interop) 'avatar_storage_web.dart';

/// Loads the custom profile avatar previously saved by [saveAvatarBytes].
///
/// Returns null when no custom avatar exists.
Future<Uint8List?> loadAvatarBytes() => loadAvatarBytesImpl();

/// Persists (or clears, when [bytes] is null) the custom profile avatar.
Future<void> saveAvatarBytes(Uint8List? bytes) => saveAvatarBytesImpl(bytes);

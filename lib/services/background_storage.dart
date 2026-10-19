import 'dart:typed_data';

import 'background_storage_io.dart'
    if (dart.library.js_interop) 'background_storage_web.dart';

/// Loads the custom page background previously saved by [saveBackgroundBytes].
///
/// Returns null when no custom background exists.
Future<Uint8List?> loadBackgroundBytes() => loadBackgroundBytesImpl();

/// Persists (or clears, when [bytes] is null) the custom page background.
Future<void> saveBackgroundBytes(Uint8List? bytes) =>
    saveBackgroundBytesImpl(bytes);

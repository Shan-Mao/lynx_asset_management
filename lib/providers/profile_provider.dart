import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/avatar_storage.dart';

/// Available avatar icons to choose from.
const List<IconData> avatarIcons = [
  Icons.inventory_2,
  Icons.account_balance_wallet,
  Icons.savings,
  Icons.diamond,
  Icons.star,
  Icons.favorite,
  Icons.thumb_up,
  Icons.auto_awesome,
  Icons.rocket_launch,
  Icons.shield,
  Icons.verified,
  Icons.emoji_events,
  Icons.palette,
  Icons.music_note,
  Icons.camera,
  Icons.sports_esports,
];

/// Stores user-customizable profile info.
class ProfileProvider extends ChangeNotifier {
  static const _kDisplayName = 'profile_display_name';
  static const _kAvatarIcon = 'profile_avatar_icon';
  static const _kAvatarColor = 'profile_avatar_color';

  String _displayName = '';
  int _avatarIconIndex = 0;
  Color _avatarColor = Colors.teal;
  Uint8List? _avatarImageBytes;

  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Restores the saved profile. Call once before the app is shown.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _displayName = _prefs!.getString(_kDisplayName) ?? _displayName;
      _avatarIconIndex =
          (_prefs!.getInt(_kAvatarIcon) ?? _avatarIconIndex)
              .clamp(0, avatarIcons.length - 1);
      final color = _prefs!.getInt(_kAvatarColor);
      if (color != null) _avatarColor = Color(color);
      _avatarImageBytes = await loadAvatarBytes();
      notifyListeners();
    } catch (_) {
      // Storage unavailable – fall back to the built-in defaults.
    }
  }

  Future<void> _saveScalars() async {
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setString(_kDisplayName, _displayName);
      await prefs.setInt(_kAvatarIcon, _avatarIconIndex);
      await prefs.setInt(_kAvatarColor, _avatarColor.toARGB32());
    } catch (_) {
      // Ignore storage errors – settings simply won't survive a restart.
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get displayName => _displayName;
  int get avatarIconIndex => _avatarIconIndex;
  IconData get avatarIcon => avatarIcons[_avatarIconIndex];
  Color get avatarColor => _avatarColor;
  Uint8List? get avatarImageBytes => _avatarImageBytes;
  bool get hasCustomImage => _avatarImageBytes != null;

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  set displayName(String v) {
    if (v == _displayName) return;
    _displayName = v;
    notifyListeners();
    _saveScalars();
  }

  set avatarIconIndex(int v) {
    final index = v.clamp(0, avatarIcons.length - 1);
    if (index == _avatarIconIndex && _avatarImageBytes == null) return;
    _avatarIconIndex = index;
    _avatarImageBytes = null; // clear custom image
    notifyListeners();
    _saveScalars();
    saveAvatarBytes(null);
  }

  set avatarColor(Color v) {
    if (v.toARGB32() == _avatarColor.toARGB32()) return;
    _avatarColor = v;
    notifyListeners();
    _saveScalars();
  }

  set avatarImageBytes(Uint8List? v) {
    _avatarImageBytes = v;
    notifyListeners();
    saveAvatarBytes(v);
  }
}

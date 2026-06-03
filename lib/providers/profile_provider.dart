import 'dart:typed_data';
import 'package:flutter/material.dart';

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
  String _displayName = '';
  int _avatarIconIndex = 0;
  Color _avatarColor = Colors.teal;
  Uint8List? _avatarImageBytes;

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
  }

  set avatarIconIndex(int v) {
    if (v == _avatarIconIndex) return;
    _avatarIconIndex = v.clamp(0, avatarIcons.length - 1);
    _avatarImageBytes = null; // clear custom image
    notifyListeners();
  }

  set avatarColor(Color v) {
    if (v.toARGB32() == _avatarColor.toARGB32()) return;
    _avatarColor = v;
    notifyListeners();
  }

  set avatarImageBytes(Uint8List? v) {
    _avatarImageBytes = v;
    notifyListeners();
  }
}

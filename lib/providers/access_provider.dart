import 'package:flutter/material.dart';

/// Access control has been removed: the full book is now freely readable
/// by everyone, with no unlock code required. This provider is kept as a
/// thin no-op shim (always "unlocked") so existing screens that still
/// reference it keep compiling without needing a larger refactor.
class AccessProvider extends ChangeNotifier {
  /// Kept for backward compatibility with screens that still reference it;
  /// no longer used to gate any content.
  static const int freeChapterCount = 0;

  final bool _isUnlocked = true;
  final bool _isLoading = false;

  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;

  /// All chapters are now freely readable.
  bool canReadChapter(int chapterIndex) => true;
}

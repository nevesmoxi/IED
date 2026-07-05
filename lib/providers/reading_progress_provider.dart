import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_models.dart';

/// Tracks the reader's last position ("continue reading") and bookmarks.
class ReadingProgressProvider extends ChangeNotifier {
  static const _kLastPositionKey = 'last_reading_position';
  static const _kBookmarksKey = 'bookmarks';

  ReadingPosition? _lastPosition;
  final List<ReadingPosition> _bookmarks = [];

  ReadingPosition? get lastPosition => _lastPosition;
  List<ReadingPosition> get bookmarks => List.unmodifiable(_bookmarks);

  ReadingProgressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRaw = prefs.getString(_kLastPositionKey);
    if (lastRaw != null) {
      _lastPosition = ReadingPosition.fromJson(
        json.decode(lastRaw) as Map<String, dynamic>,
      );
    }
    final bookmarksRaw = prefs.getStringList(_kBookmarksKey) ?? [];
    _bookmarks
      ..clear()
      ..addAll(
        bookmarksRaw.map(
          (s) =>
              ReadingPosition.fromJson(json.decode(s) as Map<String, dynamic>),
        ),
      );
    notifyListeners();
  }

  Future<void> saveLastPosition(int chapterIndex, int sectionIndex) async {
    _lastPosition = ReadingPosition(
      chapterIndex: chapterIndex,
      sectionIndex: sectionIndex,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLastPositionKey,
      json.encode(_lastPosition!.toJson()),
    );
  }

  bool isBookmarked(int chapterIndex, int sectionIndex) {
    return _bookmarks.any(
      (b) => b.chapterIndex == chapterIndex && b.sectionIndex == sectionIndex,
    );
  }

  Future<void> toggleBookmark(int chapterIndex, int sectionIndex) async {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.chapterIndex == chapterIndex && b.sectionIndex == sectionIndex,
    );
    if (existingIndex != -1) {
      _bookmarks.removeAt(existingIndex);
    } else {
      _bookmarks.add(
        ReadingPosition(chapterIndex: chapterIndex, sectionIndex: sectionIndex),
      );
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kBookmarksKey,
      _bookmarks.map((b) => json.encode(b.toJson())).toList(),
    );
  }
}

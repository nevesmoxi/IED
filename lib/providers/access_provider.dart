import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/access_code_service.dart';

/// Tracks whether the reader has unlocked the book content via a valid
/// access code, and persists that state locally so it survives app
/// restarts (the user only needs to enter the code once per device).
class AccessProvider extends ChangeNotifier {
  static const _kUnlockedKey = 'access_unlocked';
  static const _kRedeemedCodeKey = 'access_redeemed_code';

  /// Number of chapters (counting from the first one) that are freely
  /// readable without an access code. This lets the app be published on
  /// Google Play as a genuinely useful free download (a real sample of the
  /// book, not an empty shell) while the remaining chapters stay reserved
  /// for readers who purchased the book from the author.
  static const int freeChapterCount = 3;

  bool _isUnlocked = false;
  bool _isLoading = true;
  String? _redeemedCode;
  String? _lastError;

  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;
  String? get redeemedCode => _redeemedCode;
  String? get lastError => _lastError;

  /// Whether [chapterIndex] (0-based) can be read right now: either it is
  /// one of the free sample chapters, or the reader has unlocked full
  /// access via a valid code.
  bool canReadChapter(int chapterIndex) {
    return _isUnlocked || chapterIndex < freeChapterCount;
  }

  AccessProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isUnlocked = prefs.getBool(_kUnlockedKey) ?? false;
    _redeemedCode = prefs.getString(_kRedeemedCodeKey);
    _isLoading = false;
    notifyListeners();
  }

  /// Validates [rawCode] and, if valid, persists the unlocked state.
  /// Returns true on success.
  Future<bool> redeemCode(String rawCode) async {
    final code = AccessCodeService.normalize(rawCode);
    if (code.isEmpty) {
      _lastError = 'Introduza um código de acesso.';
      notifyListeners();
      return false;
    }

    if (!AccessCodeService.isValid(code)) {
      _lastError = 'Código inválido. Verifique e tente novamente.';
      notifyListeners();
      return false;
    }

    _isUnlocked = true;
    _redeemedCode = code;
    _lastError = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUnlockedKey, true);
    await prefs.setString(_kRedeemedCodeKey, code);
    return true;
  }

  void clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  /// Development/support utility: locks the app again (e.g. if a code was
  /// entered by mistake, or for support/testing purposes).
  Future<void> lock() async {
    _isUnlocked = false;
    _redeemedCode = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUnlockedKey);
    await prefs.remove(_kRedeemedCodeKey);
  }
}

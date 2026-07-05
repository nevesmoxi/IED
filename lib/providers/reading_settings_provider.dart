import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingThemeMode { light, dark, sepia }

/// Persists and exposes user reading preferences: font size and reading theme.
class ReadingSettingsProvider extends ChangeNotifier {
  static const _kFontSizeKey = 'reading_font_size';
  static const _kThemeModeKey = 'reading_theme_mode';
  static const _kAppThemeKey = 'app_theme_mode'; // overall app light/dark

  double _fontSize = 18.0;
  ReadingThemeMode _readingTheme = ReadingThemeMode.light;
  ThemeMode _appThemeMode = ThemeMode.light;

  double get fontSize => _fontSize;
  ReadingThemeMode get readingTheme => _readingTheme;
  ThemeMode get appThemeMode => _appThemeMode;

  static const double minFontSize = 14.0;
  static const double maxFontSize = 28.0;

  ReadingSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_kFontSizeKey) ?? 18.0;
    final themeIndex = prefs.getInt(_kThemeModeKey) ?? 0;
    _readingTheme = ReadingThemeMode
        .values[themeIndex.clamp(0, ReadingThemeMode.values.length - 1)];
    final appThemeIndex = prefs.getInt(_kAppThemeKey) ?? 0;
    _appThemeMode = appThemeIndex == 1 ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> increaseFontSize() async {
    _fontSize = (_fontSize + 2).clamp(minFontSize, maxFontSize);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSizeKey, _fontSize);
  }

  Future<void> decreaseFontSize() async {
    _fontSize = (_fontSize - 2).clamp(minFontSize, maxFontSize);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSizeKey, _fontSize);
  }

  Future<void> setReadingTheme(ReadingThemeMode mode) async {
    _readingTheme = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }

  Future<void> toggleAppTheme() async {
    _appThemeMode = _appThemeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAppThemeKey, _appThemeMode == ThemeMode.dark ? 1 : 0);
  }
}

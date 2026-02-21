import 'package:flutter/material.dart' hide ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Tema modu enum
enum ThemeMode { light, dark, system }

/// Görünüm modu enum (Liste veya Grid)
enum ViewMode { list, grid }

/// Tema ve Kişiselleştirme Provider
class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _viewModeKey = 'view_mode';
  static const String _sortPreferenceKey = 'sort_preference';

  ThemeMode _themeMode = ThemeMode.system;
  ViewMode _viewMode = ViewMode.list;
  String? _savedSortPreference;

  ThemeMode get themeMode => _themeMode;
  ViewMode get viewMode => _viewMode;
  String? get savedSortPreference => _savedSortPreference;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - varsayılan olarak light
    return false;
  }

  /// SharedPreferences'tan ayarları yükle
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tema modunu yükle
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    // Görünüm modunu yükle
    final viewModeIndex = prefs.getInt(_viewModeKey);
    if (viewModeIndex != null) {
      _viewMode = ViewMode.values[viewModeIndex];
    }

    // Sıralama tercihini yükle
    _savedSortPreference = prefs.getString(_sortPreferenceKey);

    notifyListeners();
  }

  /// Tema modunu değiştir ve kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Görünüm modunu değiştir ve kaydet
  Future<void> setViewMode(ViewMode mode) async {
    _viewMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewModeKey, mode.index);
  }

  /// Sıralama tercihini kaydet
  Future<void> saveSortPreference(String sortOption) async {
    _savedSortPreference = sortOption;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortPreferenceKey, sortOption);
  }

  /// Dark mode'u toggle et
  Future<void> toggleDarkMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Görünüm modunu toggle et
  Future<void> toggleViewMode() async {
    if (_viewMode == ViewMode.list) {
      await setViewMode(ViewMode.grid);
    } else {
      await setViewMode(ViewMode.list);
    }
  }
}

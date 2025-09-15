import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// Theme mode provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeFromStorage();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await _saveThemeToStorage(themeMode);
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    final newThemeMode = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  // Set to light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set to dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set to system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Load theme from storage
  Future<void> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(AppConstants.settingsCacheKey);

      if (themeString != null) {
        switch (themeString) {
          case AppThemes.lightTheme:
            state = ThemeMode.light;
            break;
          case AppThemes.darkTheme:
            state = ThemeMode.dark;
            break;
          case AppThemes.systemTheme:
            state = ThemeMode.system;
            break;
          default:
            state = ThemeMode.system;
        }
      }
    } catch (e) {
      // Handle error silently, use system default
      print('Error loading theme from storage: $e');
    }
  }

  // Save theme to storage
  Future<void> _saveThemeToStorage(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (themeMode) {
        case ThemeMode.light:
          themeString = AppThemes.lightTheme;
          break;
        case ThemeMode.dark:
          themeString = AppThemes.darkTheme;
          break;
        case ThemeMode.system:
          themeString = AppThemes.systemTheme;
          break;
      }

      await prefs.setString(AppConstants.settingsCacheKey, themeString);
    } catch (e) {
      print('Error saving theme to storage: $e');
    }
  }
}

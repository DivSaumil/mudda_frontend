import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the ThemeController
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
      return ThemeController();
    });

/// Controller to manage the app's theme mode (light/dark/system).
class ThemeController extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey);

    if (savedThemeIndex != null) {
      state = ThemeMode.values[savedThemeIndex];
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    if (state == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.light;
    }

    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newMode.index);
  }

  /// Set a specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}

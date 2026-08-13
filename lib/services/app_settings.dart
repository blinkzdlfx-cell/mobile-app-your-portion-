import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AppSettings {
  static const _kThemeMode = 'theme_mode';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeMode) ?? 'light';
    themeMode.value = switch (stored) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    themeMode.addListener(_syncAppTheme);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeMode,
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light',
    );
  }

  static void _syncAppTheme() {
    AppTheme.setDarkMode(themeMode.value == ThemeMode.dark);
  }
}
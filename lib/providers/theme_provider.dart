import 'package:flutter/material.dart';

import '../services/theme_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._preferences) {
    _restorePreference();
  }

  final ThemePreferences _preferences;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDisposed = false;

  ThemeMode get themeMode => _themeMode;

  Future<void> _restorePreference() async {
    try {
      final savedValue = await _preferences.readDarkMode();
      if (savedValue == null || _isDisposed) return;
      _themeMode = savedValue ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (_) {
      // Theme persistence is optional; keep following the system theme.
    }
  }

  Future<void> toggle(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (!_isDisposed) notifyListeners();
    try {
      await _preferences.saveDarkMode(isDark);
    } catch (_) {
      // The selected theme still applies for the current session.
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

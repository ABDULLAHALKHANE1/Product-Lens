import '../storage/key_value_store.dart';

abstract interface class ThemePreferences {
  Future<bool?> readDarkMode();
  Future<void> saveDarkMode(bool isDark);
}

class LocalThemePreferences implements ThemePreferences {
  const LocalThemePreferences(this._store);

  static const _darkModeKey = 'dark_mode';
  final KeyValueStore _store;

  @override
  Future<bool?> readDarkMode() => _store.getBool(_darkModeKey);

  @override
  Future<void> saveDarkMode(bool isDark) =>
      _store.setBool(_darkModeKey, isDark);
}

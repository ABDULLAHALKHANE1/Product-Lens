import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_lens/providers/theme_provider.dart';
import 'package:product_lens/services/theme_preferences.dart';

void main() {
  test('reads and writes theme state through the injected abstraction', () async {
    final preferences = _FakeThemePreferences(initialValue: true);
    final provider = ThemeProvider(preferences);

    await Future<void>.delayed(Duration.zero);
    expect(provider.themeMode, ThemeMode.dark);

    await provider.toggle(false);
    expect(provider.themeMode, ThemeMode.light);
    expect(preferences.savedValue, isFalse);

    provider.dispose();
  });
}

class _FakeThemePreferences implements ThemePreferences {
  _FakeThemePreferences({required this.initialValue});

  final bool? initialValue;
  bool? savedValue;

  @override
  Future<bool?> readDarkMode() async => initialValue;

  @override
  Future<void> saveDarkMode(bool isDark) async => savedValue = isDark;
}

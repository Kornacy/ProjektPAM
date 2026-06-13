import 'package:city_issues/services/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferences', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.system.index,
        'accent_color': AppPreferences.defaultAccent.toARGB32(),
        'onboarding_completed': false,
      });
      await AppPreferences.instance.load();
    });

    test('load uses defaults when prefs are empty', () {
      final prefs = AppPreferences.instance;
      expect(prefs.isLoaded, isTrue);
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.accentColor, AppPreferences.defaultAccent);
      expect(prefs.hasCompletedOnboarding, isFalse);
    });

    test('load restores saved values', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.index,
        'accent_color': const Color(0xFF2E7D32).toARGB32(),
        'onboarding_completed': true,
      });
      await AppPreferences.instance.load();

      expect(AppPreferences.instance.themeMode, ThemeMode.dark);
      expect(AppPreferences.instance.accentColor, const Color(0xFF2E7D32));
      expect(AppPreferences.instance.hasCompletedOnboarding, isTrue);
    });

    test('setThemeMode persists value and notifies listeners', () async {
      var notified = false;
      void listener() => notified = true;
      AppPreferences.instance.addListener(listener);
      addTearDown(() => AppPreferences.instance.removeListener(listener));

      await AppPreferences.instance.setThemeMode(ThemeMode.dark);

      expect(AppPreferences.instance.themeMode, ThemeMode.dark);
      expect(notified, isTrue);

      final stored = await SharedPreferences.getInstance();
      expect(stored.getInt('theme_mode'), ThemeMode.dark.index);
    });

    test('setThemeMode is no-op when mode unchanged', () async {
      var notifyCount = 0;
      void listener() => notifyCount++;
      AppPreferences.instance.addListener(listener);
      addTearDown(() => AppPreferences.instance.removeListener(listener));

      await AppPreferences.instance.setThemeMode(ThemeMode.system);

      expect(notifyCount, 0);
    });

    test('setAccentColor persists value and notifies listeners', () async {
      const color = Color(0xFF6A1B9A);
      var notified = false;
      void listener() => notified = true;
      AppPreferences.instance.addListener(listener);
      addTearDown(() => AppPreferences.instance.removeListener(listener));

      await AppPreferences.instance.setAccentColor(color);

      expect(AppPreferences.instance.accentColor, color);
      expect(notified, isTrue);

      final stored = await SharedPreferences.getInstance();
      expect(stored.getInt('accent_color'), color.toARGB32());
    });

    test('setOnboardingCompleted marks onboarding as done', () async {
      await AppPreferences.instance.setOnboardingCompleted();

      expect(AppPreferences.instance.hasCompletedOnboarding, isTrue);

      final stored = await SharedPreferences.getInstance();
      expect(stored.getBool('onboarding_completed'), isTrue);
    });

    test('resetOnboardingFlags clears onboarding state', () async {
      await AppPreferences.instance.setOnboardingCompleted();
      await AppPreferences.instance.resetOnboardingFlags();

      expect(AppPreferences.instance.hasCompletedOnboarding, isFalse);

      final stored = await SharedPreferences.getInstance();
      expect(stored.getBool('onboarding_completed'), isFalse);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();
  static final AppPreferences instance = AppPreferences._();

  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _onboardingKey = 'onboarding_completed';

  static const Color defaultAccent = Color(0xFF1565C0);

  static const List<Color> accentPresets = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF00838F),
    Color(0xFFC62828),
  ];

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = defaultAccent;
  bool _loaded = false;
  bool _onboardingCompleted = false;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get isLoaded => _loaded;
  bool get hasCompletedOnboarding => _onboardingCompleted;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }
    final accentValue = prefs.getInt(_accentColorKey);
    if (accentValue != null) {
      _accentColor = Color(accentValue);
    }
    _onboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setOnboardingCompleted() async {
    _onboardingCompleted = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboardingFlags() async {
    _onboardingCompleted = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());
  }
}

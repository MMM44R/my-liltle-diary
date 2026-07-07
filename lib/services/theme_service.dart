import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeName { pinkDream, strawberryMilk, sakuraBlossom, cottonCandy }

extension AppThemeNameLabel on AppThemeName {
  String get labelTh {
    switch (this) {
      case AppThemeName.pinkDream:
        return 'Pink Dream 💗';
      case AppThemeName.strawberryMilk:
        return 'Strawberry Milk 🍓';
      case AppThemeName.sakuraBlossom:
        return 'Sakura Blossom 🌸';
      case AppThemeName.cottonCandy:
        return 'Cotton Candy 🍬';
    }
  }

  Color get seedColor {
    switch (this) {
      case AppThemeName.pinkDream:
        return const Color(0xFFFF8FB1);
      case AppThemeName.strawberryMilk:
        return const Color(0xFFFFB3C6);
      case AppThemeName.sakuraBlossom:
        return const Color(0xFFF7A8C4);
      case AppThemeName.cottonCandy:
        return const Color(0xFFF6C6EA);
    }
  }
}

/// จัดการธีมสี (4 แบบ) และโหมด Light/Dark ของแอป พร้อมบันทึกค่าที่ผู้ใช้เลือกไว้
class ThemeService extends ChangeNotifier {
  static const _kThemeKey = 'app_theme_name';
  static const _kDarkModeKey = 'app_dark_mode';
  static const _kFirstLaunchKey = 'has_seen_welcome';

  AppThemeName _themeName = AppThemeName.pinkDream;
  bool _isDarkMode = false;

  AppThemeName get themeName => _themeName;
  bool get isDarkMode => _isDarkMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      _themeName = AppThemeName.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => AppThemeName.pinkDream,
      );
    }
    _isDarkMode = prefs.getBool(_kDarkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setTheme(AppThemeName name) async {
    _themeName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, name.name);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, value);
  }

  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kFirstLaunchKey) ?? false;
  }

  static Future<void> setSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFirstLaunchKey, true);
  }

  ThemeData buildTheme({required bool dark}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _themeName.seedColor,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF2B2030) : const Color(0xFFFFF5F8),
      textTheme: GoogleFonts.sarabunTextTheme(
        dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF3A2C3F) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF3A2C3F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF3A2C3F) : Colors.white,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

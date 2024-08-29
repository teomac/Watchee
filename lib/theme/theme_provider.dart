import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Import the logger package

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final logger = Logger(); // Define the logger variable

  ThemeProvider() {
    loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    logger.d('Theme mode updated to: $_themeMode');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
    logger.d('Theme mode saved to SharedPreferences');
  }

  void loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[savedThemeMode];
    logger.d('Loaded theme mode: $_themeMode');
    notifyListeners();
  }
}

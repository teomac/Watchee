import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
  }

  void loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[savedThemeMode];
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData) {
    _loadTheme();
  }

  getTheme() => _themeData;

  setTheme(ThemeData themeData, String themeKey) async {
    _themeData = themeData;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeKey);
  }

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeKey = prefs.getString('theme') ?? 'light'; // Default to light theme
    if (themeKey == 'light') {
      _themeData = ThemeData.light();
    } else {
      _themeData = ThemeData.dark();
    }
    notifyListeners();
  }

}


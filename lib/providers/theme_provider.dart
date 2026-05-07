import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';

class ThemeProvider with ChangeNotifier {
  final HiveService _hiveService;

  late bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider(this._hiveService) {
    _isDarkMode = _hiveService.getThemeMode();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _hiveService.setThemeMode(_isDarkMode);
    notifyListeners();
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../models/show_model.dart';
import '../models/episode_model.dart';

class HiveService {
  static const String _favoritesBox = 'favoritesBox';
  static const String _settingsBox = 'settingsBox';
  static const String _searchHistoryBox = 'searchHistoryBox';
  static const String _recentShowsBox = 'recentShowsBox';
  static const String _themeKey = 'isDarkMode';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(ShowModelAdapter());
    Hive.registerAdapter(ScheduleModelAdapter());
    Hive.registerAdapter(NetworkModelAdapter());
    Hive.registerAdapter(EpisodeModelAdapter());
    
    // Open Boxes
    await Hive.openBox<ShowModel>(_favoritesBox);
    await Hive.openBox<String>(_searchHistoryBox);
    await Hive.openBox<ShowModel>(_recentShowsBox);
    await Hive.openBox(_settingsBox);
  }

  // Favorites
  Box<ShowModel> getFavoritesBox() {
    return Hive.box<ShowModel>(_favoritesBox);
  }

  List<ShowModel> getFavorites() {
    final box = getFavoritesBox();
    return box.values.toList();
  }

  Future<void> addFavorite(ShowModel show) async {
    final box = getFavoritesBox();
    await box.put(show.id, show);
  }

  Future<void> removeFavorite(int id) async {
    final box = getFavoritesBox();
    await box.delete(id);
  }

  bool isFavorite(int id) {
    final box = getFavoritesBox();
    return box.containsKey(id);
  }

  // Recent Shows
  Box<ShowModel> getRecentShowsBox() {
    return Hive.box<ShowModel>(_recentShowsBox);
  }

  List<ShowModel> getRecentShows() {
    final box = getRecentShowsBox();
    // Return last 20 recent shows reversed
    return box.values.toList().reversed.take(20).toList();
  }

  Future<void> addRecentShow(ShowModel show) async {
    final box = getRecentShowsBox();
    // To keep it clean, if it exists, delete and re-add at the end
    if (box.containsKey(show.id)) {
      await box.delete(show.id);
    }
    await box.put(show.id, show);
  }

  Future<void> removeRecentShow(int id) async {
    final box = getRecentShowsBox();
    await box.delete(id);
  }

  // Search History
  Box<String> getSearchHistoryBox() {
    return Hive.box<String>(_searchHistoryBox);
  }

  List<String> getSearchHistory() {
    final box = getSearchHistoryBox();
    return box.values.toList().reversed.take(15).toList();
  }

  Future<void> addSearchQuery(String query) async {
    final box = getSearchHistoryBox();
    // Avoid duplicates, if exists remove first
    final existingKey = box.keys.firstWhere((k) => box.get(k) == query, orElse: () => null);
    if (existingKey != null) {
      await box.delete(existingKey);
    }
    await box.add(query);
  }

  Future<void> clearSearchHistory() async {
    final box = getSearchHistoryBox();
    await box.clear();
  }

  // Theme
  bool getThemeMode() {
    final box = Hive.box(_settingsBox);
    return box.get(_themeKey, defaultValue: true); // Default to dark mode
  }

  Future<void> setThemeMode(bool isDark) async {
    final box = Hive.box(_settingsBox);
    await box.put(_themeKey, isDark);
  }
}

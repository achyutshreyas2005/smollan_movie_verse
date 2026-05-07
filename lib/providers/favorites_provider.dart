import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/show_model.dart';

class FavoritesProvider with ChangeNotifier {
  final HiveService _hiveService;

  FavoritesProvider(this._hiveService) {
    _loadFavorites();
  }

  List<ShowModel> _favorites = [];
  List<ShowModel> get favorites => _favorites;

  void _loadFavorites() {
    _favorites = _hiveService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _hiveService.isFavorite(id);
  }

  Future<void> toggleFavorite(ShowModel show) async {
    if (isFavorite(show.id)) {
      await _hiveService.removeFavorite(show.id);
    } else {
      await _hiveService.addFavorite(show);
    }
    _loadFavorites();
  }

  Future<void> removeFavorite(int id) async {
    await _hiveService.removeFavorite(id);
    _loadFavorites();
  }
}

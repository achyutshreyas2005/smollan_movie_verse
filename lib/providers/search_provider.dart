import 'package:flutter/material.dart';
import '../../core/enums/ui_state.dart';
import '../../data/models/show_model.dart';
import '../../data/services/api_service.dart';
import '../../data/local/hive_service.dart';

class SearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final HiveService _hiveService;

  SearchProvider(this._hiveService);

  UIState _state = UIState.initial;
  UIState get state => _state;

  List<ShowModel> _searchResults = [];
  List<ShowModel> get searchResults => _searchResults;

  List<String> get searchHistory => _hiveService.getSearchHistory();

  String _currentQuery = '';

  Future<void> searchShows(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _state = UIState.initial;
      notifyListeners();
      return;
    }

    if (query == _currentQuery && _state == UIState.success) return;

    _currentQuery = query;
    _state = UIState.loading;
    notifyListeners();

    try {
      final results = await _apiService.searchShows(query);
      _searchResults = results;
      
      if (_searchResults.isEmpty) {
        _state = UIState.empty;
      } else {
        _state = UIState.success;
        // Add to search history if successful
        await _hiveService.addSearchQuery(query);
      }
    } catch (e) {
      _state = UIState.error;
    }
    notifyListeners();
  }

  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _state = UIState.initial;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _hiveService.clearSearchHistory();
    notifyListeners();
  }
}

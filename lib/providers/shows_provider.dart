import 'package:flutter/material.dart';
import '../../core/enums/ui_state.dart';
import '../../data/models/show_model.dart';
import '../../data/services/api_service.dart';
import '../../data/local/hive_service.dart';

class ShowsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final HiveService _hiveService;

  ShowsProvider(this._hiveService);

  UIState _state = UIState.initial;
  UIState get state => _state;

  List<ShowModel> _trendingShows = [];
  List<ShowModel> get trendingShows => _trendingShows;

  List<ShowModel> _popularShows = [];
  List<ShowModel> get popularShows => _popularShows;

  List<ShowModel> _upcomingShows = [];
  List<ShowModel> get upcomingShows => _upcomingShows;

  List<ShowModel> get recentShows => _hiveService.getRecentShows();

  int _currentPage = 0;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  Future<List<ShowModel>> _fetchFromQueries(List<String> queries) async {
    try {
      final results = await Future.wait(queries.map((q) => _apiService.searchShows(q)));
      final allShows = results.expand((x) => x).toList();
      final unique = <int, ShowModel>{};
      for (var s in allShows) {
        if (s.imageUrl != null && s.rating != null && s.rating! > 6.5) {
          unique[s.id] = s;
        }
      }
      final finalShows = unique.values.toList();
      finalShows.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      return finalShows;
    } catch (e) {
      return [];
    }
  }

  Future<List<ShowModel>> _fetchUpcomingFromQueries(List<String> queries) async {
    try {
      final results = await Future.wait(queries.map((q) => _apiService.searchShows(q)));
      final allShows = results.expand((x) => x).toList();
      final unique = <int, ShowModel>{};
      
      final now = DateTime.now();
      // Include shows premiering in the future, or recently premiered (last 90 days)
      final recentThreshold = now.subtract(const Duration(days: 90)); 
      
      for (var s in allShows) {
        if (s.imageUrl != null) {
          bool isUpcoming = false;
          if (s.status == 'In Development' || s.status == 'To Be Determined') {
            isUpcoming = true;
          } else if (s.premiered != null) {
            try {
              final premieredDate = DateTime.parse(s.premiered!);
              if (premieredDate.isAfter(recentThreshold)) {
                isUpcoming = true;
              }
            } catch (_) {}
          }
          if (isUpcoming) unique[s.id] = s;
        }
      }
      final finalShows = unique.values.toList();
      // Sort by newest if possible
      finalShows.sort((a, b) {
         if (a.premiered == null && b.premiered == null) return 0;
         if (a.premiered == null) return 1;
         if (b.premiered == null) return -1;
         return b.premiered!.compareTo(a.premiered!);
      });
      return finalShows;
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchHomeData() async {
    _state = UIState.loading;
    notifyListeners();

    try {
      // Fetching banger shows using specific highly-popular search queries to simulate a premium library
      final trending = await _fetchFromQueries(['dragon', 'last of us', 'mandalorian', 'boys', 'fallout']);
      final popular = await _fetchFromQueries(['game of thrones', 'breaking bad', 'office', 'friends', 'cyberpunk']);
      final upcoming = await _fetchUpcomingFromQueries([
        'marvel', 'star wars', 'witcher', 'stranger things', 'lord of the rings', 
        'disney', 'netflix', 'amazon', 'hulu', 'apple', 'hbo', 'paramount'
      ]);
      
      _trendingShows = trending.take(15).toList();
      _popularShows = popular.take(20).toList();
      _upcomingShows = upcoming.take(15).toList();

      // If for any reason they are empty, fetch page 0 as absolute fallback
      if (_trendingShows.isEmpty || _popularShows.isEmpty || _upcomingShows.isEmpty) {
        final fallbackShows = await _apiService.getShows(page: 0);
        fallbackShows.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        final validFallback = fallbackShows.where((s) => s.imageUrl != null).toList();
        
        if (_trendingShows.isEmpty) _trendingShows = validFallback.take(15).toList();
        if (_popularShows.isEmpty) _popularShows = validFallback.skip(15).take(20).toList();
        if (_upcomingShows.isEmpty) _upcomingShows = validFallback.skip(35).take(15).toList();
      }
      
      _state = UIState.success;
      _currentPage = 0;
    } catch (e) {
      _state = UIState.error;
    }
    notifyListeners();
  }

  Future<void> fetchMorePopularShows() async {
    if (_isFetchingMore) return;
    
    _isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreShows = await _apiService.getShows(page: _currentPage);
      final validShows = moreShows.where((s) => s.imageUrl != null && s.rating != null && s.rating! > 7.5).toList();
      validShows.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      _popularShows.addAll(validShows);
    } catch (e) {
      _currentPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> addToRecent(ShowModel show) async {
    await _hiveService.addRecentShow(show);
    notifyListeners(); // to update the UI if the user navigates back
  }

  Future<void> removeFromRecent(int id) async {
    await _hiveService.removeRecentShow(id);
    notifyListeners();
  }
}

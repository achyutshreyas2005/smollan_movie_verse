import 'package:flutter/material.dart';
import '../../core/enums/ui_state.dart';
import '../../data/models/episode_model.dart';
import '../../data/services/api_service.dart';

enum UpcomingFilter { today, tomorrow, thisWeek, all }

class UpcomingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UIState _state = UIState.initial;
  UIState get state => _state;
  
  List<EpisodeModel> _allEpisodes = [];
  List<EpisodeModel> get filteredEpisodes => _applyFilter();
  
  UpcomingFilter _currentFilter = UpcomingFilter.today;
  UpcomingFilter get currentFilter => _currentFilter;
  
  String _searchQuery = '';

  Future<void> fetchUpcoming() async {
    _state = UIState.loading;
    notifyListeners();
    
    try {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final nextDay = today.add(const Duration(days: 2));
      final nextNextDay = today.add(const Duration(days: 3));
      
      String formatDate(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      
      final results = await Future.wait([
        _apiService.getScheduleEpisodes(date: formatDate(today)),
        _apiService.getScheduleEpisodes(date: formatDate(tomorrow)),
        _apiService.getScheduleEpisodes(date: formatDate(nextDay)),
        _apiService.getScheduleEpisodes(date: formatDate(nextNextDay)),
      ]);
      
      _allEpisodes = results.expand((e) => e).toList();
      
      // Filter out past episodes for today based on airstamp
      _allEpisodes = _allEpisodes.where((ep) {
         if (ep.airstamp != null) {
            final airTime = DateTime.tryParse(ep.airstamp!);
            if (airTime != null && airTime.isBefore(DateTime.now())) {
               return false; // already aired
            }
         }
         return true;
      }).toList();
      
      // Sort by airstamp / airtime
      _allEpisodes.sort((a, b) {
         if (a.airstamp == null && b.airstamp == null) return 0;
         if (a.airstamp == null) return 1;
         if (b.airstamp == null) return -1;
         return a.airstamp!.compareTo(b.airstamp!);
      });
      
      _state = _allEpisodes.isEmpty ? UIState.empty : UIState.success;
    } catch (e) {
      _state = UIState.error;
    }
    notifyListeners();
  }

  void setFilter(UpcomingFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
  
  void search(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }
  
  List<EpisodeModel> _applyFilter() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
    
    List<EpisodeModel> result = _allEpisodes;
    
    switch (_currentFilter) {
      case UpcomingFilter.today:
        result = result.where((e) => e.airdate == todayStr).toList();
        break;
      case UpcomingFilter.tomorrow:
        result = result.where((e) => e.airdate == tomorrowStr).toList();
        break;
      case UpcomingFilter.thisWeek:
      case UpcomingFilter.all:
        // Already fetching approx this week/all, just return all
        break;
    }
    
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) {
         return e.show.name.toLowerCase().contains(_searchQuery) ||
                e.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    return result;
  }
}

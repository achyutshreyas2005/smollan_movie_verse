import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/show_model.dart';
import '../models/episode_model.dart';

class ApiService {
  Future<List<ShowModel>> getShows({int page = 0}) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.shows}?page=$page'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShowModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ShowModel>> searchShows(String query) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.searchShows(query)));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ShowModel.fromJson(item['show'])).toList();
      } else {
        throw Exception('Failed to search shows');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ShowModel> getShowDetails(int id) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.showDetails(id)));
      if (response.statusCode == 200) {
        return ShowModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load show details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ShowModel>> getSchedule({String? date, bool isWeb = false}) async {
    try {
      String url = '${ApiConstants.baseUrl}/schedule${isWeb ? '/web' : ''}?';
      if (!isWeb) {
        url += 'country=US&';
      }
      if (date != null) {
        url += 'date=$date';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<ShowModel> shows = [];
        final Set<int> seenIds = {};
        for (var item in data) {
          if (item['show'] != null) {
            final show = ShowModel.fromJson(item['show']);
            if (!seenIds.contains(show.id)) {
              seenIds.add(show.id);
              shows.add(show);
            }
          }
        }
        return shows;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<EpisodeModel>> getScheduleEpisodes({String? date}) async {
    try {
      String tvUrl = '${ApiConstants.baseUrl}/schedule?country=US';
      String webUrl = '${ApiConstants.baseUrl}/schedule/web';
      if (date != null) {
        tvUrl += '&date=$date';
        webUrl += '?date=$date';
      }
      
      final responses = await Future.wait([
        http.get(Uri.parse(tvUrl)),
        http.get(Uri.parse(webUrl)),
      ]);
      
      final List<EpisodeModel> episodes = [];
      if (responses[0].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[0].body);
        episodes.addAll(data.map((item) => EpisodeModel.fromJson(item)));
      }
      if (responses[1].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[1].body);
        episodes.addAll(data.map((item) => EpisodeModel.fromJson(item)));
      }
      return episodes;
    } catch (e) {
      return [];
    }
  }
}

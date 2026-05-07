class ApiConstants {
  static const String baseUrl = 'https://api.tvmaze.com';
  
  static const String shows = '$baseUrl/shows';
  static String searchShows(String query) => '$baseUrl/search/shows?q=$query';
  static String showDetails(int id) => '$baseUrl/shows/$id';
}

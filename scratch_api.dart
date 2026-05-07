import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final queries = ['marvel', 'star wars', 'witcher', 'stranger things', 'lord of the rings', 'dragon', 'last of us', 'fallout'];
  final List upcoming = [];
  
  for (var q in queries) {
    final res = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$q'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      for (var item in data) {
        final show = item['show'];
        bool isUpcoming = false;
        if (show['status'] == 'In Development' || show['status'] == 'To Be Determined') {
          isUpcoming = true;
        } else if (show['premiered'] != null) {
          try {
            final premieredDate = DateTime.parse(show['premiered']);
            if (premieredDate.isAfter(DateTime.now())) isUpcoming = true;
          } catch (_) {}
        }
        
        if (isUpcoming) {
          upcoming.add(show['name']);
        }
      }
    }
  }
  print('Found upcoming: ${upcoming.length}');
  print(upcoming);
}

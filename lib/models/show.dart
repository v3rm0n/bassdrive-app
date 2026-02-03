import 'episode.dart';

class Show {
  final String name;
  final List<Episode> episodes;

  Show({required this.name, required this.episodes});

  factory Show.fromJson(Map<String, dynamic> json) {
    final episodesList = (json['episodes'] as List)
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();

    episodesList.sort((a, b) {
      final dateA = a.date;
      final dateB = b.date;
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA);
      }
      return b.name.compareTo(a.name);
    });

    return Show(name: json['name'] as String, episodes: episodesList);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'episodes': episodes.map((e) => e.toJson()).toList()};
  }

  String get id => name;
}

import 'show.dart';

class ArchiveDay {
  final String day;
  final List<Show> shows;

  ArchiveDay({required this.day, required this.shows});

  factory ArchiveDay.fromJson(String day, Map<String, dynamic> json) {
    final showsList = (json['shows'] as List)
        .map((s) => Show.fromJson(s as Map<String, dynamic>))
        .toList();

    showsList.sort((a, b) => a.name.compareTo(b.name));

    return ArchiveDay(day: day, shows: showsList);
  }

  Map<String, dynamic> toJson() {
    return {'shows': shows.map((s) => s.toJson()).toList()};
  }

  String get id => day;
}

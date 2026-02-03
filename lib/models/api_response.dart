import 'archive_day.dart';

class ApiResponse {
  final String live;
  final Map<String, ArchiveDay> archive;
  final DateTime? updated;

  ApiResponse({required this.live, required this.archive, this.updated});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final archiveData = json['archive'] as Map<String, dynamic>;
    final archiveMap = <String, ArchiveDay>{};

    final dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final day in dayOrder) {
      if (archiveData.containsKey(day)) {
        archiveMap[day] = ArchiveDay.fromJson(
          day,
          archiveData[day] as Map<String, dynamic>,
        );
      }
    }

    DateTime? updated;
    if (json['updated'] != null) {
      updated = DateTime.tryParse(json['updated'] as String);
    }

    return ApiResponse(
      live: json['live'] as String,
      archive: archiveMap,
      updated: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'live': live,
      'archive': archive.map((key, value) => MapEntry(key, value.toJson())),
      if (updated != null) 'updated': updated!.toIso8601String(),
    };
  }

  List<String> get days => archive.keys.toList();
}

class Episode {
  final String name;
  final String show;
  final String url;
  final String encodedUrl;

  Episode({
    required this.name,
    required this.show,
    required this.url,
    required this.encodedUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      name: json['name'] as String,
      show: json['show'] as String,
      url: json['url'] as String,
      encodedUrl: json['encodedUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'show': show, 'url': url, 'encodedUrl': encodedUrl};
  }

  String get displayName {
    final dateMatch = RegExp(r'\[(\d{4}\.\d{2}\.\d{2})\]').firstMatch(name);
    if (dateMatch != null) {
      final date = dateMatch.group(1);
      final title = name.replaceFirst(dateMatch.group(0)!, '').trim();
      return title.isEmpty ? name : '$date - $title';
    }
    return name;
  }

  DateTime? get date {
    final dateMatch = RegExp(r'\[(\d{4})\.(\d{2})\.(\d{2})\]').firstMatch(name);
    if (dateMatch != null) {
      final year = int.parse(dateMatch.group(1)!);
      final month = int.parse(dateMatch.group(2)!);
      final day = int.parse(dateMatch.group(3)!);
      return DateTime(year, month, day);
    }
    return null;
  }

  /// The episode name without its leading `[yyyy.mm.dd]` date stamp.
  String get title {
    final stripped =
        name.replaceFirst(RegExp(r'\[\d{4}\.\d{2}\.\d{2}\]'), '').trim();
    return stripped.isEmpty ? name : stripped;
  }

  /// Broadcast date written out, such as "10 February 2026".
  String? get dateLabel {
    final d = date;
    if (d == null) return null;
    return '${d.day} ${monthNames[d.month - 1]} ${d.year}';
  }

  static const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get id => encodedUrl;
}

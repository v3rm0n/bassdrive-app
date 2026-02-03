class ListeningProgress {
  final String episodeId;
  final String episodeName;
  final String showName;
  final Duration position;
  final Duration? duration;
  final DateTime lastPlayed;
  final bool isCompleted;

  ListeningProgress({
    required this.episodeId,
    required this.episodeName,
    required this.showName,
    required this.position,
    this.duration,
    required this.lastPlayed,
    this.isCompleted = false,
  });

  factory ListeningProgress.fromJson(Map<String, dynamic> json) {
    return ListeningProgress(
      episodeId: json['episodeId'] as String,
      episodeName: json['episodeName'] as String,
      showName: json['showName'] as String,
      position: Duration(milliseconds: json['position'] as int),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episodeId': episodeId,
      'episodeName': episodeName,
      'showName': showName,
      'position': position.inMilliseconds,
      if (duration != null) 'duration': duration!.inMilliseconds,
      'lastPlayed': lastPlayed.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  ListeningProgress copyWith({
    String? episodeId,
    String? episodeName,
    String? showName,
    Duration? position,
    Duration? duration,
    DateTime? lastPlayed,
    bool? isCompleted,
  }) {
    return ListeningProgress(
      episodeId: episodeId ?? this.episodeId,
      episodeName: episodeName ?? this.episodeName,
      showName: showName ?? this.showName,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progressPercentage {
    if (duration == null || duration!.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration!.inMilliseconds).clamp(0.0, 1.0);
  }

  String get formattedPosition {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

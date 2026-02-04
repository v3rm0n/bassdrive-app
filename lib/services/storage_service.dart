import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listening_progress.dart';

class StorageService {
  static const String _progressKey = 'listening_progress';
  static const String _completedKey = 'completed_episodes';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveProgress(ListeningProgress progress) async {
    if (_prefs == null) await initialize();

    final key = '$_progressKey.${progress.episodeId}';
    await _prefs!.setString(key, jsonEncode(progress.toJson()));
  }

  Future<ListeningProgress?> getProgress(String episodeId) async {
    if (_prefs == null) await initialize();

    final key = '$_progressKey.$episodeId';
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return ListeningProgress.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, ListeningProgress>> getAllProgress() async {
    if (_prefs == null) await initialize();

    final allProgress = <String, ListeningProgress>{};
    final allKeys = _prefs!.getKeys().where(
      (key) => key.startsWith('$_progressKey.'),
    );

    for (final key in allKeys) {
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        try {
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          final progress = ListeningProgress.fromJson(jsonMap);
          allProgress[progress.episodeId] = progress;
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    return allProgress;
  }

  Future<List<ListeningProgress>> getRecentProgress({int limit = 20}) async {
    final allProgress = await getAllProgress();
    final sorted =
        allProgress.values.toList()
          ..sort((a, b) => b.lastPlayed.compareTo(a.lastPlayed));
    return sorted.take(limit).toList();
  }

  Future<void> markEpisodeCompleted(String episodeId) async {
    if (_prefs == null) await initialize();

    final completed = await getCompletedEpisodes();
    if (!completed.contains(episodeId)) {
      completed.add(episodeId);
      await _prefs!.setStringList(_completedKey, completed);
    }
  }

  Future<List<String>> getCompletedEpisodes() async {
    if (_prefs == null) await initialize();
    return _prefs!.getStringList(_completedKey) ?? [];
  }

  Future<bool> isEpisodeCompleted(String episodeId) async {
    final completed = await getCompletedEpisodes();
    return completed.contains(episodeId);
  }

  Future<void> clearProgress(String episodeId) async {
    if (_prefs == null) await initialize();

    final key = '$_progressKey.$episodeId';
    await _prefs!.remove(key);
  }

  Future<void> clearAllProgress() async {
    if (_prefs == null) await initialize();

    // Remove all progress keys
    final allKeys = _prefs!.getKeys().where(
      (key) => key.startsWith('$_progressKey.'),
    );
    for (final key in allKeys) {
      await _prefs!.remove(key);
    }
    await _prefs!.remove(_completedKey);
  }
}

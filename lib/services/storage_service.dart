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

    final allProgress = await getAllProgress();
    allProgress[progress.episodeId] = progress;

    final jsonMap = allProgress.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await _prefs!.setString(_progressKey, jsonEncode(jsonMap));
  }

  Future<ListeningProgress?> getProgress(String episodeId) async {
    if (_prefs == null) await initialize();

    final allProgress = await getAllProgress();
    return allProgress[episodeId];
  }

  Future<Map<String, ListeningProgress>> getAllProgress() async {
    if (_prefs == null) await initialize();

    final jsonString = _prefs!.getString(_progressKey);
    if (jsonString == null) return {};

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonMap.map(
        (key, value) => MapEntry(
          key,
          ListeningProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  Future<List<ListeningProgress>> getRecentProgress({int limit = 20}) async {
    final allProgress = await getAllProgress();
    final sorted = allProgress.values.toList()
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

    final allProgress = await getAllProgress();
    allProgress.remove(episodeId);

    final jsonMap = allProgress.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await _prefs!.setString(_progressKey, jsonEncode(jsonMap));
  }

  Future<void> clearAllProgress() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_progressKey);
    await _prefs!.remove(_completedKey);
  }
}

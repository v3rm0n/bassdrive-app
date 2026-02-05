import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/episode.dart';

class DownloadedEpisode {
  final String episodeId;
  final String episodeName;
  final String showName;
  final String originalUrl;
  final String localPath;
  final DateTime downloadedAt;
  final int fileSize;

  DownloadedEpisode({
    required this.episodeId,
    required this.episodeName,
    required this.showName,
    required this.originalUrl,
    required this.localPath,
    required this.downloadedAt,
    required this.fileSize,
  });

  factory DownloadedEpisode.fromJson(Map<String, dynamic> json) {
    return DownloadedEpisode(
      episodeId: json['episodeId'] as String,
      episodeName: json['episodeName'] as String,
      showName: json['showName'] as String,
      originalUrl: json['originalUrl'] as String,
      localPath: json['localPath'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      fileSize: json['fileSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episodeId': episodeId,
      'episodeName': episodeName,
      'showName': showName,
      'originalUrl': originalUrl,
      'localPath': localPath,
      'downloadedAt': downloadedAt.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

enum DownloadStatus { notDownloaded, downloading, downloaded, error }

class DownloadProgress {
  final String episodeId;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final String? error;

  DownloadProgress({
    required this.episodeId,
    required this.status,
    this.progress = 0.0,
    this.error,
  });
}

class DownloadService extends ChangeNotifier {
  static const String _downloadsKey = 'downloaded_episodes';
  static const int _maxStorageBytes = 2 * 1024 * 1024 * 1024; // 2GB max

  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  SharedPreferences? _prefs;
  Directory? _downloadsDir;

  final Map<String, DownloadProgress> _downloadProgress = {};
  final Map<String, DownloadedEpisode> _downloadedEpisodes = {};

  Map<String, DownloadProgress> get downloadProgress =>
      Map.unmodifiable(_downloadProgress);
  Map<String, DownloadedEpisode> get downloadedEpisodes =>
      Map.unmodifiable(_downloadedEpisodes);

  int get totalDownloadedBytes =>
      _downloadedEpisodes.values.fold(0, (sum, e) => sum + e.fileSize);
  int get downloadedCount => _downloadedEpisodes.length;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDownloadsDirectory();
    await _loadDownloadedEpisodes();
  }

  Future<void> _initDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    _downloadsDir = Directory('${appDir.path}/downloads');
    if (!await _downloadsDir!.exists()) {
      await _downloadsDir!.create(recursive: true);
    }
  }

  Future<void> _loadDownloadedEpisodes() async {
    if (_prefs == null) await initialize();

    final jsonString = _prefs!.getString(_downloadsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        for (final item in jsonList) {
          final episode =
              DownloadedEpisode.fromJson(item as Map<String, dynamic>);
          // Verify file still exists
          final file = File(episode.localPath);
          if (await file.exists()) {
            _downloadedEpisodes[episode.episodeId] = episode;
          }
        }
      } catch (e) {
        debugPrint('Error loading downloaded episodes: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveDownloadedEpisodes() async {
    if (_prefs == null) await initialize();

    final jsonList = _downloadedEpisodes.values.map((e) => e.toJson()).toList();
    await _prefs!.setString(_downloadsKey, jsonEncode(jsonList));
  }

  bool isDownloaded(String episodeId) {
    return _downloadedEpisodes.containsKey(episodeId);
  }

  Future<String?> getLocalPath(String episodeId) async {
    final episode = _downloadedEpisodes[episodeId];
    if (episode != null) {
      final file = File(episode.localPath);
      if (await file.exists()) {
        return episode.localPath;
      }
      // File was deleted, remove from tracking
      _downloadedEpisodes.remove(episodeId);
      await _saveDownloadedEpisodes();
      notifyListeners();
    }
    return null;
  }

  Future<void> downloadEpisode(Episode episode) async {
    if (_downloadedEpisodes.containsKey(episode.id)) {
      return; // Already downloaded
    }

    if (_downloadProgress[episode.id]?.status == DownloadStatus.downloading) {
      return; // Already downloading
    }

    // Check storage limit
    if (totalDownloadedBytes >= _maxStorageBytes) {
      _downloadProgress[episode.id] = DownloadProgress(
        episodeId: episode.id,
        status: DownloadStatus.error,
        error: 'Storage limit reached. Please delete some episodes.',
      );
      notifyListeners();
      return;
    }

    _downloadProgress[episode.id] = DownloadProgress(
      episodeId: episode.id,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );
    notifyListeners();

    try {
      final fileName =
          '${episode.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp3';
      final localPath = '${_downloadsDir!.path}/$fileName';

      await _dio.download(
        episode.encodedUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress[episode.id] = DownloadProgress(
              episodeId: episode.id,
              status: DownloadStatus.downloading,
              progress: received / total,
            );
            notifyListeners();
          }
        },
      );

      final file = File(localPath);
      final fileSize = await file.length();

      final downloadedEpisode = DownloadedEpisode(
        episodeId: episode.id,
        episodeName: episode.displayName,
        showName: episode.show,
        originalUrl: episode.encodedUrl,
        localPath: localPath,
        downloadedAt: DateTime.now(),
        fileSize: fileSize,
      );

      _downloadedEpisodes[episode.id] = downloadedEpisode;
      _downloadProgress[episode.id] = DownloadProgress(
        episodeId: episode.id,
        status: DownloadStatus.downloaded,
        progress: 1.0,
      );

      await _saveDownloadedEpisodes();
      notifyListeners();
    } catch (e) {
      _downloadProgress[episode.id] = DownloadProgress(
        episodeId: episode.id,
        status: DownloadStatus.error,
        error: e.toString(),
      );
      notifyListeners();

      // Clean up partial download
      try {
        final fileName =
            '${episode.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp3';
        final localPath = '${_downloadsDir!.path}/$fileName';
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }

  Future<void> deleteDownload(String episodeId) async {
    final episode = _downloadedEpisodes[episodeId];
    if (episode != null) {
      try {
        final file = File(episode.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }

      _downloadedEpisodes.remove(episodeId);
      _downloadProgress.remove(episodeId);
      await _saveDownloadedEpisodes();
      notifyListeners();
    }
  }

  Future<void> deleteAllDownloads() async {
    for (final episode in _downloadedEpisodes.values) {
      try {
        final file = File(episode.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }

    _downloadedEpisodes.clear();
    _downloadProgress.clear();
    await _saveDownloadedEpisodes();
    notifyListeners();
  }

  DownloadStatus getDownloadStatus(String episodeId) {
    if (_downloadedEpisodes.containsKey(episodeId)) {
      return DownloadStatus.downloaded;
    }
    return _downloadProgress[episodeId]?.status ?? DownloadStatus.notDownloaded;
  }

  double getDownloadProgress(String episodeId) {
    return _downloadProgress[episodeId]?.progress ?? 0.0;
  }

  Future<void> cleanupOldDownloads({int maxAgeDays = 30}) async {
    final now = DateTime.now();
    final toDelete = <String>[];

    for (final entry in _downloadedEpisodes.entries) {
      final age = now.difference(entry.value.downloadedAt);
      if (age.inDays > maxAgeDays) {
        toDelete.add(entry.key);
      }
    }

    for (final episodeId in toDelete) {
      await deleteDownload(episodeId);
    }
  }
}

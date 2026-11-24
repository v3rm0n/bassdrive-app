// Renders the README screenshots in /screenshots. Skipped in normal runs.
//
//   flutter test test/readme_screenshots_test.dart --update-goldens \
//     --dart-define=SCREENSHOTS=true
import 'dart:io';

import 'package:bassdrive_radio/main.dart';
import 'package:bassdrive_radio/models/api_response.dart';
import 'package:bassdrive_radio/models/archive_day.dart';
import 'package:bassdrive_radio/models/episode.dart';
import 'package:bassdrive_radio/models/show.dart';
import 'package:bassdrive_radio/services/api_service.dart';
import 'package:bassdrive_radio/services/audio_player_service.dart';
import 'package:bassdrive_radio/services/storage_service.dart';
import 'package:bassdrive_radio/utils/platform_utils.dart';
import 'package:bassdrive_radio/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');

const _schedule = {
  'Monday': [
    'The Prague Connection - Blofeld',
    'Translation Sound - Rogue State',
    'Subfactory Show - DJ Spim',
    'The Infrasound Radio Show - Icon',
    'Rinse N Wash - Wadjit',
    'The Just On Track Show - Ashatack',
  ],
  'Tuesday': ['Sohl Patrol - Sohlman', 'Dusk - Melysma'],
  'Wednesday': ['Random Movement Radio - Random Movement'],
  'Thursday': ['Impressions - Indentation'],
  'Friday': ['Launch in Session - Handy'],
  'Saturday': ['Electronic Warfare - The Overfiend'],
  'Sunday': ['Fuzed Funk - Magin'],
};

Show _show(String name) {
  final parts = name.split(' - ');
  final title = parts.length > 1 ? '${parts.first} with ${parts.last}' : name;
  final episodes = [
    for (var week = 0; week < 8; week++)
      () {
        final d = DateTime(2026, 11, 16).subtract(Duration(days: 7 * week));
        final stamp = '${d.year}.${d.month.toString().padLeft(2, '0')}.'
            '${d.day.toString().padLeft(2, '0')}';
        final episodeName = '[$stamp] $title';
        return Episode(
          name: episodeName,
          show: name,
          url: 'https://example.com/$episodeName.mp3',
          encodedUrl: 'https://example.com/${Uri.encodeComponent(episodeName)}',
        );
      }(),
  ];
  return Show(name: name, episodes: episodes);
}

final _archive = {
  for (final entry in _schedule.entries)
    entry.key: ArchiveDay(
      day: entry.key,
      shows: entry.value.map(_show).toList(),
    ),
};

class _Api extends ApiService {
  @override
  Future<ApiResponse> fetchArchive() async =>
      ApiResponse(live: 'https://example.com/live', archive: _archive);
}

class _Player extends ChangeNotifier implements AudioPlayerService {
  _Player({this.isLive = false, this.isPlaying = false, this.currentEpisode});

  @override
  final bool isLive;
  @override
  final bool isPlaying;
  @override
  Episode? currentEpisode;
  @override
  bool get isLoading => false;
  @override
  bool get hasError => false;
  @override
  String? get error => null;
  @override
  PlayerState get state => isPlaying ? PlayerState.playing : PlayerState.paused;
  @override
  Duration get position => const Duration(minutes: 41, seconds: 12);
  @override
  Duration get duration => currentEpisode == null
      ? Duration.zero
      : const Duration(hours: 1, minutes: 58);
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

Future<void> _loadIcons() async {
  final root = Platform.environment['FLUTTER_ROOT']!;
  final bytes = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ).readAsBytesSync();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(bytes.buffer))))
      .load();
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadIcons();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  tearDown(() => PlatformUtils.debugIsDesktopOverride = null);

  Future<void> pumpApp(
    WidgetTester tester,
    _Player player, {
    required bool desktop,
  }) async {
    PlatformUtils.debugIsDesktopOverride = desktop;
    if (desktop) {
      tester.view.physicalSize = const Size(2880, 1800);
      tester.view.devicePixelRatio = 2;
    } else {
      // iPhone 16 Pro: 402x874 points at 3x, with notch and home indicator.
      tester.view.physicalSize = const Size(1206, 2622);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 186, bottom: 102);
    }
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(
        apiService: _Api(),
        playerService: player,
        storageService: StorageService(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> settle(WidgetTester tester) async {
    // The speaker animates forever, so step time instead of settling.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> capture(String file) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../screenshots/$file'),
      );

  final nowPlaying = _archive['Monday']!.shows.first.episodes[1];

  testWidgets('live', skip: !_enabled, (tester) async {
    await pumpApp(tester, _Player(isLive: true, isPlaying: true),
        desktop: false);
    await settle(tester);
    await capture('IMAGE1.PNG');
  });

  testWidgets('archive and show', skip: !_enabled, (tester) async {
    await pumpApp(tester, _Player(isPlaying: true, currentEpisode: nowPlaying),
        desktop: false);
    await tester.tap(find.text('Archive'));
    await settle(tester);
    await tester.tap(find.text('Mon'));
    await settle(tester);
    await capture('IMAGE2.PNG');

    await tester.tap(find.text('The Prague Connection - Blofeld'));
    await settle(tester);
    await capture('IMAGE3.PNG');
  });

  testWidgets('player', skip: !_enabled, (tester) async {
    await pumpApp(tester, _Player(isPlaying: true, currentEpisode: nowPlaying),
        desktop: false);
    await tester.tap(find.text('Player'));
    await settle(tester);
    await capture('IMAGE4.PNG');
  });

  testWidgets('desktop', skip: !_enabled, (tester) async {
    await pumpApp(tester, _Player(isPlaying: true, currentEpisode: nowPlaying),
        desktop: true);
    await tester.tap(find.text('Archive'));
    await settle(tester);
    await tester.tap(find.text('Mon'));
    await settle(tester);
    await capture('DESKTOP.PNG');
  });
}

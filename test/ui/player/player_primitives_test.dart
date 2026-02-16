import 'package:bassdrive_radio/ui/player/player_primitives.dart';
import 'package:bassdrive_radio/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PlayerLayoutScale increases hero size on wider viewports', () {
    final mobile = PlayerLayoutScale.fromWidth(390);
    final tablet = PlayerLayoutScale.fromWidth(900);
    final desktop = PlayerLayoutScale.fromWidth(1400);

    expect(mobile.heroSize, lessThan(tablet.heroSize));
    expect(tablet.heroSize, lessThan(desktop.heroSize));
  });

  testWidgets('LiveBadge renders READY state when idle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: LiveBadge(isPlaying: false, isReadyState: true),
          ),
        ),
      ),
    );

    expect(find.text('READY'), findsOneWidget);
  });

  testWidgets('TimelineProgressRow hides for live playback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TimelineProgressRow(
            viewState: const PlayerViewState(
              isPlaying: true,
              isLoading: false,
              isLive: true,
              hasContent: true,
              title: 'Bassdrive Live',
              subtitle: '24/7 Drum & Bass Radio',
              position: Duration(seconds: 10),
              duration: Duration(minutes: 1),
            ),
            scale: PlayerLayoutScale.fromWidth(390),
            onSeek: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('TransportCluster shows skip controls for archive state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TransportCluster(
            viewState: const PlayerViewState(
              isPlaying: false,
              isLoading: false,
              isLive: false,
              hasContent: true,
              title: 'Episode 01',
              subtitle: 'Show Name',
              position: Duration.zero,
              duration: Duration(minutes: 3),
            ),
            scale: PlayerLayoutScale.fromWidth(390),
            onPrimaryPressed: () {},
            onSkipBack: () {},
            onSkipForward: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.replay_10), findsOneWidget);
    expect(find.byIcon(Icons.forward_30), findsOneWidget);
  });
}

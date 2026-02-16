import 'package:flutter/material.dart';

import '../screens/listening_stats_screen.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/player/player_primitives.dart';
import '../ui/theme/app_theme_tokens.dart';
import '../ui/theme/component_theme_extensions.dart';

class FullPlayer extends StatefulWidget {
  final AudioPlayerService playerService;
  final StorageService storageService;
  final String liveStreamUrl;

  const FullPlayer({
    super.key,
    required this.playerService,
    required this.storageService,
    required this.liveStreamUrl,
  });

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryOpacity;
  late Animation<double> _entryLift;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  bool _pulseActive = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: AppMotion.emphasis,
      vsync: this,
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.9, curve: AppMotion.entranceCurve),
    );
    _entryLift = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 1.0, curve: AppMotion.entranceCurve),
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: AppMotion.pulseCurve),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showStats() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListeningStatsScreen(
          storageService: widget.storageService,
        ),
      ),
    );
  }

  Future<void> _handlePlayButton() async {
    final hasContent = widget.playerService.isLive ||
        widget.playerService.currentEpisode != null;

    if (!hasContent) {
      // Start live stream when nothing is playing
      await widget.playerService.playLiveStream(widget.liveStreamUrl);
    } else {
      // Toggle play/pause when something is already loaded
      await widget.playerService.togglePlayPause();
    }
  }

  void _syncPulse(bool isPlaying) {
    if (isPlaying && !_pulseActive) {
      _pulseController.repeat(reverse: true);
      _pulseActive = true;
      return;
    }

    if (!isPlaying && _pulseActive) {
      _pulseController.stop();
      _pulseController.value = 0;
      _pulseActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme =
        theme.extension<BroadcastCardTheme>() ?? BroadcastCardTheme.console();
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final scale = PlayerLayoutScale.fromWidth(viewportWidth);
    final viewState = PlayerViewState.fromService(widget.playerService);

    _syncPulse(viewState.isPlaying);

    final isReadyState = !viewState.hasContent;
    final showLiveBadge = viewState.isLive || isReadyState;
    final heroIcon = showLiveBadge ? Icons.radio : Icons.music_note;

    return Scaffold(
      body: Stack(
        children: [
          _AmbientBackdrop(isPlaying: viewState.isPlaying),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: _showStats,
                        tooltip: 'Listening Stats',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scale.horizontalPadding,
                              vertical: AppSpacing.sm,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: scale.maxContentWidth,
                                ),
                                child: FadeTransition(
                                  opacity: _entryOpacity,
                                  child: AnimatedBuilder(
                                    animation: _entryLift,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: cardTheme.background.withValues(
                                          alpha: 0.82,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            cardTheme.radius),
                                        border:
                                            Border.all(color: cardTheme.border),
                                      ),
                                      child: Padding(
                                        padding: cardTheme.padding,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ScaleTransition(
                                              scale: _pulseScale,
                                              child: PlayerHeroCover(
                                                scale: scale,
                                                icon: heroIcon,
                                                isPlaying: viewState.isPlaying,
                                                badge: showLiveBadge
                                                    ? LiveBadge(
                                                        isPlaying:
                                                            viewState.isPlaying,
                                                        isReadyState:
                                                            isReadyState,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(
                                                height: scale.sectionSpacing),
                                            TrackMetaBlock(
                                              title: viewState.title,
                                              subtitle: viewState.subtitle,
                                              scale: scale,
                                            ),
                                            SizedBox(
                                                height: scale.sectionSpacing),
                                            TimelineProgressRow(
                                              viewState: viewState,
                                              scale: scale,
                                              onSeek: widget.playerService.seek,
                                            ),
                                            if (!viewState.showTimeline)
                                              SizedBox(
                                                height:
                                                    scale.timelineBottomSpacing,
                                              ),
                                            TransportCluster(
                                              viewState: viewState,
                                              scale: scale,
                                              onPrimaryPressed:
                                                  _handlePlayButton,
                                              onSkipBack: viewState.showTimeline
                                                  ? () {
                                                      widget.playerService
                                                          .skipBackward(
                                                        const Duration(
                                                            seconds: 10),
                                                      );
                                                    }
                                                  : null,
                                              onSkipForward:
                                                  viewState.showTimeline
                                                      ? () {
                                                          widget.playerService
                                                              .skipForward(
                                                            const Duration(
                                                                seconds: 30),
                                                          );
                                                        }
                                                      : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _entryLift.value),
                                        child: child,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.isPlaying});

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface,
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedAlign(
            duration: AppMotion.emphasis,
            curve: AppMotion.entranceCurve,
            alignment: isPlaying
                ? const Alignment(-0.75, -0.7)
                : const Alignment(-0.5, -0.4),
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: AppMotion.emphasis,
                width: isPlaying ? 320 : 260,
                height: isPlaying ? 320 : 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyanGlow.withValues(
                    alpha: isPlaying ? 0.18 : 0.08,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedAlign(
            duration: AppMotion.emphasis,
            curve: AppMotion.entranceCurve,
            alignment: isPlaying
                ? const Alignment(0.82, 0.78)
                : const Alignment(0.7, 0.62),
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: AppMotion.emphasis,
                width: isPlaying ? 240 : 180,
                height: isPlaying ? 240 : 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.outlineStrong.withValues(
                    alpha: isPlaying ? 0.16 : 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import 'audio_controls.dart';
import '../screens/listening_stats_screen.dart';

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

class _FullPlayerState extends State<FullPlayer>
    with SingleTickerProviderStateMixin {
  double? _dragValue;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine what to show based on player state
    final bool isPlaying = widget.playerService.isPlaying;
    final bool hasContent = widget.playerService.isLive ||
        widget.playerService.currentEpisode != null;

    // When nothing is playing, show the "ready to play" state like live stream
    final String title = hasContent
        ? (widget.playerService.isLive
            ? 'Bassdrive Live'
            : (widget.playerService.currentEpisode?.displayName ?? 'Bassdrive'))
        : 'Bassdrive';

    final String subtitle = hasContent
        ? (widget.playerService.isLive
            ? '24/7 Drum & Bass Radio'
            : (widget.playerService.currentEpisode?.show ?? 'Ready to Play'))
        : 'Ready to Play';

    // Start/stop pulse animation based on playing state
    if (isPlaying) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with stats button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      onPressed: _showStats,
                      tooltip: 'Listening Stats',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              // Main content
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Album art with pulse animation
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        isPlaying ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      width: 260,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withValues(
                                              alpha: isPlaying ? 0.4 : 0.15,
                                            ),
                                            blurRadius: isPlaying ? 40 : 20,
                                            spreadRadius: isPlaying ? 8 : 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                theme.colorScheme.primary
                                                    .withValues(alpha: 0.4),
                                                theme.colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                              ],
                                            ),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Background pattern
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: RadialGradient(
                                                    center: Alignment.center,
                                                    radius: 0.8,
                                                    colors: [
                                                      theme.colorScheme.primary
                                                          .withValues(
                                                              alpha: 0.3),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Icon
                                              Icon(
                                                widget.playerService.isLive ||
                                                        !hasContent
                                                    ? Icons.radio
                                                    : Icons.music_note,
                                                size: 100,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              // Live/Ready indicator
                                              if (widget.playerService.isLive ||
                                                  !hasContent)
                                                Positioned(
                                                  top: 20,
                                                  right: 20,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isPlaying
                                                          ? Colors.red
                                                          : theme.colorScheme
                                                              .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          isPlaying
                                                              ? 'LIVE'
                                                              : 'READY',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                              // Title and subtitle
                              Text(
                                title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 40),
                              // Progress bar for archives (only when playing archive)
                              if (!widget.playerService.isLive &&
                                  hasContent) ...[
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 6,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                      pressedElevation: 8,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16,
                                    ),
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor: theme
                                        .colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                    thumbColor: theme.colorScheme.primary,
                                    overlayColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                  child: Slider(
                                    value: (_dragValue ??
                                            widget.playerService.position
                                                .inMilliseconds
                                                .toDouble())
                                        .clamp(
                                      0,
                                      widget
                                          .playerService.duration.inMilliseconds
                                          .toDouble()
                                          .clamp(1, double.infinity),
                                    ),
                                    max: widget
                                        .playerService.duration.inMilliseconds
                                        .toDouble()
                                        .clamp(1, double.infinity),
                                    onChangeStart: (value) {
                                      setState(() {
                                        _dragValue = value;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _dragValue = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      widget.playerService.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                      setState(() {
                                        _dragValue = null;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(
                                          _dragValue != null
                                              ? Duration(
                                                  milliseconds:
                                                      _dragValue!.toInt(),
                                                )
                                              : widget.playerService.position,
                                        ),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(
                                            widget.playerService.duration),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                // Spacer for live stream or idle state
                                const SizedBox(height: 24),
                              ],
                              // Playback controls
                              AudioControls(
                                playerService: widget.playerService,
                                iconSize: 40,
                                showSkipButtons:
                                    !widget.playerService.isLive && hasContent,
                                onPlayPressed: _handlePlayButton,
                              ),
                              const SizedBox(height: 24),
                            ],
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
      ),
    );
  }
}

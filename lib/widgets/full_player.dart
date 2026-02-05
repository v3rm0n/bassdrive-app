import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import 'audio_controls.dart';

class FullPlayer extends StatefulWidget {
  final AudioPlayerService playerService;
  final VoidCallback onClose;

  const FullPlayer({
    super.key,
    required this.playerService,
    required this.onClose,
  });

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  double? _dragValue;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.playerService.isLive
        ? 'Bassdrive Live'
        : (widget.playerService.currentEpisode?.displayName ?? 'Unknown');
    final subtitle = widget.playerService.isLive
        ? '24/7 Drum \u0026 Bass Radio'
        : (widget.playerService.currentEpisode?.show ?? '');

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 10) {
          widget.onClose();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.playerService.isLive ? Icons.radio : Icons.music_note,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (!widget.playerService.isLive) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Slider(
                      value: (_dragValue ??
                              widget.playerService.position.inMilliseconds
                                  .toDouble())
                          .clamp(
                        0,
                        widget.playerService.duration.inMilliseconds
                            .toDouble()
                            .clamp(1, double.infinity),
                      ),
                      max: widget.playerService.duration.inMilliseconds
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(
                            _dragValue != null
                                ? Duration(milliseconds: _dragValue!.toInt())
                                : widget.playerService.position,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(widget.playerService.duration),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            AudioControls(
              playerService: widget.playerService,
              iconSize: 40,
              showSkipButtons: !widget.playerService.isLive,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import 'player_layout_scale.dart';
import 'player_view_state.dart';

class TimelineProgressRow extends StatefulWidget {
  const TimelineProgressRow({
    super.key,
    required this.viewState,
    required this.scale,
    required this.onSeek,
  });

  final PlayerViewState viewState;
  final PlayerLayoutScale scale;
  final ValueChanged<Duration> onSeek;

  @override
  State<TimelineProgressRow> createState() => _TimelineProgressRowState();
}

class _TimelineProgressRowState extends State<TimelineProgressRow> {
  double? _dragValue;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!widget.viewState.showTimeline) {
      return const SizedBox.shrink();
    }

    final max = widget.viewState.duration.inMilliseconds
        .toDouble()
        .clamp(1, double.infinity)
        .toDouble();
    final current =
        (_dragValue ?? widget.viewState.position.inMilliseconds.toDouble())
            .clamp(0, max)
            .toDouble();

    return Column(
      children: [
        Slider(
          value: current,
          max: max,
          onChangeStart: widget.viewState.canSeek
              ? (value) {
                  setState(() {
                    _dragValue = value;
                  });
                }
              : null,
          onChanged: widget.viewState.canSeek
              ? (value) {
                  setState(() {
                    _dragValue = value;
                  });
                }
              : null,
          onChangeEnd: widget.viewState.canSeek
              ? (value) {
                  widget.onSeek(Duration(milliseconds: value.toInt()));
                  setState(() {
                    _dragValue = null;
                  });
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(milliseconds: current.toInt())),
                style: theme.textTheme.labelMedium,
              ),
              Text(
                _formatDuration(widget.viewState.duration),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: widget.scale.timelineBottomSpacing),
      ],
    );
  }
}

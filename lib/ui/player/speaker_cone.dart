import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';

/// A sound-system speaker drawn head-on. While audio plays, the cone thumps
/// once per beat at 174 BPM. With reduced motion enabled it stays still.
class SpeakerCone extends StatefulWidget {
  const SpeakerCone({
    super.key,
    required this.size,
    required this.isPlaying,
    this.accent = AppColors.signal,
  });

  final double size;
  final bool isPlaying;

  /// Colour of the dust cap and the glow on each beat.
  final Color accent;

  @override
  State<SpeakerCone> createState() => _SpeakerConeState();
}

class _SpeakerConeState extends State<SpeakerCone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: AppMotion.beat,
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _sync();
  }

  @override
  void didUpdateWidget(SpeakerCone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) _sync();
  }

  void _sync() {
    final shouldAnimate = widget.isPlaying && !_reduceMotion;
    if (shouldAnimate && !_beat.isAnimating) {
      _beat.repeat();
    } else if (!shouldAnimate && _beat.isAnimating) {
      _beat
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _beat,
          builder: (context, _) {
            // Sharp attack, exponential release: a kick, not a breathing glow.
            final t = _beat.value;
            final punch = _beat.isAnimating ? math.exp(-t * 7) : 0.0;
            return CustomPaint(
              size: Size.square(widget.size),
              painter: _SpeakerPainter(
                punch: punch,
                isPlaying: widget.isPlaying,
                accent: widget.accent,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SpeakerPainter extends CustomPainter {
  _SpeakerPainter({
    required this.punch,
    required this.isPlaying,
    required this.accent,
  });

  final double punch;
  final bool isPlaying;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    // Subtle acoustic halo when active.
    if (isPlaying) {
      canvas.drawCircle(
        center,
        r * (0.98 + punch * 0.03),
        Paint()
          ..color = accent.withValues(alpha: 0.07 + punch * 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
      );
    }

    // Outer chassis ring.
    final surroundRadius = r * 0.97;
    canvas.drawCircle(
      center,
      surroundRadius,
      Paint()..color = AppColors.surface,
    );
    canvas.drawCircle(
      center,
      surroundRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, r * 0.016)
        ..color = isPlaying
            ? Color.lerp(AppColors.outlineStrong, accent, 0.25)!
            : AppColors.outlineStrong,
    );

    // Inner bezel ring.
    canvas.drawCircle(
      center,
      r * 0.85,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, r * 0.008)
        ..color = AppColors.outline,
    );

    // Recessed hex bolts around the frame.
    final boltOuterPaint = Paint()..color = AppColors.surfaceOverlay;
    final boltInnerPaint = Paint()..color = AppColors.outlineStrong;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + math.pi / 8;
      final pos = center + Offset(math.cos(a), math.sin(a)) * r * 0.905;
      canvas.drawCircle(pos, r * 0.026, boltOuterPaint);
      canvas.drawCircle(pos, r * 0.015, boltInnerPaint);
    }

    // The cone moves; everything inside it scales with the kick.
    final excursion = 1 + punch * 0.038;
    final coneRadius = r * 0.78 * excursion;

    // Rubber surround roll.
    canvas.drawCircle(
      center,
      r * 0.8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.075
        ..color = AppColors.surfaceRaised,
    );

    // Cone body gradient.
    canvas.drawCircle(
      center,
      coneRadius,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            AppColors.backgroundDeep,
            AppColors.background,
            AppColors.surface,
            AppColors.surfaceRaised,
          ],
          stops: const [0.15, 0.45, 0.78, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: coneRadius)),
    );

    // Pressed concentric ridges in the cone paper.
    final ridge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * 0.007)
      ..color = AppColors.outline.withValues(alpha: 0.9);
    for (final f in const [0.38, 0.50, 0.62, 0.72]) {
      canvas.drawCircle(center, r * f * excursion, ridge);
    }

    // Dust cap & beat glow.
    final capRadius = r * 0.26 * excursion;
    if (isPlaying) {
      canvas.drawCircle(
        center,
        capRadius * (1.35 + punch * 0.55),
        Paint()
          ..color = accent.withValues(alpha: 0.16 + punch * 0.30)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.09),
      );
    }
    canvas.drawCircle(
      center,
      capRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: isPlaying
              ? [Color.lerp(accent, Colors.white, 0.42)!, accent]
              : const [AppColors.outlineStrong, AppColors.surfaceOverlay],
        ).createShader(Rect.fromCircle(center: center, radius: capRadius)),
    );
    canvas.drawCircle(
      center,
      capRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, r * 0.008)
        ..color = isPlaying
            ? Colors.white.withValues(alpha: 0.25)
            : AppColors.outlineStrong,
    );
  }

  @override
  bool shouldRepaint(_SpeakerPainter old) =>
      old.punch != punch || old.isPlaying != isPlaying || old.accent != accent;
}

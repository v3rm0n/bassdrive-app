import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette: a dark club room ("sub"), the DJ booth surfaces, an amp-yellow
/// signal used for every action, and an on-air red reserved for live state.
class AppColors {
  static const Color signal = Color(0xFFFFD447);
  static const Color signalPressed = Color(0xFFE6BC2E);
  static const Color signalGlow = Color(0x40FFD447);
  static const Color onSignal = Color(0xFF1A1405);

  static const Color onAir = Color(0xFFFF4F5E);

  static const Color background = Color(0xFF15111F);
  static const Color surface = Color(0xFF1D1829);
  static const Color surfaceRaised = Color(0xFF261F35);
  static const Color surfaceOverlay = Color(0xFF302841);

  static const Color textPrimary = Color(0xFFEEE8F5);
  static const Color textSecondary = Color(0xFFB5ABC8);
  static const Color textMuted = Color(0xFF887E9E);

  static const Color outline = Color(0xFF332B45);
  static const Color outlineStrong = Color(0xFF4A3F62);
  static const Color success = Color(0xFF8FD9A8);
  static const Color error = Color(0xFFFF7A7A);
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

/// Radii follow hierarchy: small tiles are nearly square, sheets are softer,
/// and only the transport buttons are fully round.
class AppRadii {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 14;
  static const double pill = 999;
}

class AppElevation {
  static const double card = 0;
  static const double floating = 0;
  static const double focused = 6;
}

class AppMotion {
  static const Duration quick = Duration(milliseconds: 140);
  static const Duration regular = Duration(milliseconds: 260);
  static const Duration emphasis = Duration(milliseconds: 420);

  /// One beat at 174 BPM, the drum & bass reference tempo.
  static const Duration beat = Duration(microseconds: 344828);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve pulseCurve = Curves.easeInOut;
}

class AppTypography {
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle display({
    required double size,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textPrimary,
    double height = 0.95,
  }) {
    return GoogleFonts.bigShoulders(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle _ui(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.instrumentSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme textTheme(ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;
    return TextTheme(
      displayLarge: display(size: 56, color: onSurface),
      displayMedium: display(size: 40, color: onSurface),
      displaySmall: display(size: 32, color: onSurface, height: 1.0),
      headlineMedium: display(size: 28, weight: FontWeight.w700),
      headlineSmall: display(size: 24, weight: FontWeight.w700),
      titleLarge: _ui(17, FontWeight.w600, onSurface, height: 1.3),
      titleMedium: _ui(15, FontWeight.w600, onSurface, height: 1.3),
      titleSmall: _ui(13, FontWeight.w600, onSurface, height: 1.3),
      bodyLarge: _ui(16, FontWeight.w400, onSurface, height: 1.45),
      bodyMedium: _ui(15, FontWeight.w400, AppColors.textSecondary),
      bodySmall: _ui(13, FontWeight.w400, AppColors.textMuted),
      labelLarge: _ui(15, FontWeight.w600, onSurface, height: 1.2),
      labelMedium:
          _ui(13, FontWeight.w500, AppColors.textSecondary, height: 1.2)
              .copyWith(fontFeatures: tabular),
      labelSmall: _ui(12, FontWeight.w500, AppColors.textMuted, height: 1.2)
          .copyWith(fontFeatures: tabular),
    );
  }
}

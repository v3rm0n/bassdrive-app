import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color cyan = Color(0xFF35E7FF);
  static const Color cyanStrong = Color(0xFF00BCD4);
  static const Color cyanGlow = Color(0x6635E7FF);

  static const Color background = Color(0xFF07090C);
  static const Color surface = Color(0xFF10141B);
  static const Color surfaceRaised = Color(0xFF171D26);
  static const Color surfaceOverlay = Color(0xFF1E2631);

  static const Color textPrimary = Color(0xFFF3FAFF);
  static const Color textSecondary = Color(0xFFA4B2BF);
  static const Color textMuted = Color(0xFF728293);

  static const Color outline = Color(0xFF2A3644);
  static const Color outlineStrong = Color(0xFF3B4B60);
  static const Color success = Color(0xFF42D48B);
  static const Color error = Color(0xFFFF6D78);
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

class AppRadii {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class AppElevation {
  static const double card = 0;
  static const double floating = 4;
  static const double focused = 10;
}

class AppMotion {
  static const Duration quick = Duration(milliseconds: 140);
  static const Duration regular = Duration(milliseconds: 260);
  static const Duration emphasis = Duration(milliseconds: 420);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve pulseCurve = Curves.easeInOut;
}

class AppTypography {
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.rajdhani(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.rajdhani(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.rajdhani(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.spaceMono(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.45,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.45,
        color: AppColors.textMuted,
      ),
    );
  }
}

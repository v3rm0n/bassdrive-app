import 'package:flutter/material.dart';

import '../ui/theme/app_theme_tokens.dart';
import '../ui/theme/component_theme_extensions.dart';

class AppTheme {
  static const Color primaryColor = AppColors.cyanStrong;
  static const Color secondaryColor = AppColors.cyan;
  static const Color accentColor = AppColors.cyan;
  static const Color backgroundColor = AppColors.background;
  static const Color surfaceColor = AppColors.surface;
  static const Color cardColor = AppColors.surfaceRaised;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color dividerColor = AppColors.outline;
  static const Color errorColor = AppColors.error;
  static const Color successColor = AppColors.success;

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.cyanStrong,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimary,
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.cyanStrong,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.textTheme(colorScheme).headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceRaised,
        elevation: AppElevation.card,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.surfaceOverlay,
        height: 74,
        elevation: AppElevation.floating,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return AppTypography.textTheme(colorScheme).labelLarge?.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                letterSpacing: isSelected ? 0.55 : 0.45,
              );
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.cyan),
        unselectedIconTheme: IconThemeData(color: AppColors.textMuted),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.outline, thickness: 1),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyan,
        inactiveTrackColor: AppColors.outline,
        thumbColor: AppColors.cyan,
        overlayColor: AppColors.cyanGlow,
        trackHeight: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.cyanStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      extensions: <ThemeExtension<dynamic>>[
        BroadcastCardTheme.console(),
        BroadcastPillTheme.console(),
        TransportControlTheme.console(),
        SectionHeaderTheme.console(),
        NavigationChromeTheme.console(),
      ],
    );
  }
}

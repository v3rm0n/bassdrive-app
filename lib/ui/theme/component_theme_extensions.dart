import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme_tokens.dart';

@immutable
class BroadcastCardTheme extends ThemeExtension<BroadcastCardTheme> {
  const BroadcastCardTheme({
    required this.background,
    required this.border,
    required this.glow,
    required this.radius,
    required this.padding,
    required this.elevation,
  });

  final Color background;
  final Color border;
  final Color glow;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double elevation;

  factory BroadcastCardTheme.console() {
    return const BroadcastCardTheme(
      background: AppColors.surfaceRaised,
      border: AppColors.outlineStrong,
      glow: AppColors.cyanGlow,
      radius: AppRadii.lg,
      padding: EdgeInsets.all(AppSpacing.lg),
      elevation: AppElevation.card,
    );
  }

  @override
  BroadcastCardTheme copyWith({
    Color? background,
    Color? border,
    Color? glow,
    double? radius,
    EdgeInsetsGeometry? padding,
    double? elevation,
  }) {
    return BroadcastCardTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      glow: glow ?? this.glow,
      radius: radius ?? this.radius,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  BroadcastCardTheme lerp(ThemeExtension<BroadcastCardTheme>? other, double t) {
    if (other is! BroadcastCardTheme) {
      return this;
    }

    return BroadcastCardTheme(
      background: Color.lerp(background, other.background, t) ?? background,
      border: Color.lerp(border, other.border, t) ?? border,
      glow: Color.lerp(glow, other.glow, t) ?? glow,
      radius: lerpDouble(radius, other.radius, t) ?? radius,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t) ?? padding,
      elevation: lerpDouble(elevation, other.elevation, t) ?? elevation,
    );
  }
}

@immutable
class BroadcastPillTheme extends ThemeExtension<BroadcastPillTheme> {
  const BroadcastPillTheme({
    required this.background,
    required this.activeBackground,
    required this.text,
    required this.activeText,
    required this.border,
    required this.padding,
  });

  final Color background;
  final Color activeBackground;
  final Color text;
  final Color activeText;
  final Color border;
  final EdgeInsetsGeometry padding;

  factory BroadcastPillTheme.console() {
    return const BroadcastPillTheme(
      background: AppColors.surfaceOverlay,
      activeBackground: AppColors.cyanStrong,
      text: AppColors.textSecondary,
      activeText: Colors.black,
      border: AppColors.outline,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
    );
  }

  @override
  BroadcastPillTheme copyWith({
    Color? background,
    Color? activeBackground,
    Color? text,
    Color? activeText,
    Color? border,
    EdgeInsetsGeometry? padding,
  }) {
    return BroadcastPillTheme(
      background: background ?? this.background,
      activeBackground: activeBackground ?? this.activeBackground,
      text: text ?? this.text,
      activeText: activeText ?? this.activeText,
      border: border ?? this.border,
      padding: padding ?? this.padding,
    );
  }

  @override
  BroadcastPillTheme lerp(ThemeExtension<BroadcastPillTheme>? other, double t) {
    if (other is! BroadcastPillTheme) {
      return this;
    }

    return BroadcastPillTheme(
      background: Color.lerp(background, other.background, t) ?? background,
      activeBackground:
          Color.lerp(activeBackground, other.activeBackground, t) ??
              activeBackground,
      text: Color.lerp(text, other.text, t) ?? text,
      activeText: Color.lerp(activeText, other.activeText, t) ?? activeText,
      border: Color.lerp(border, other.border, t) ?? border,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t) ?? padding,
    );
  }
}

@immutable
class TransportControlTheme extends ThemeExtension<TransportControlTheme> {
  const TransportControlTheme({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.primarySize,
    required this.secondarySize,
    required this.ringColor,
  });

  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primaryIcon;
  final Color secondaryIcon;
  final double primarySize;
  final double secondarySize;
  final Color ringColor;

  factory TransportControlTheme.console() {
    return const TransportControlTheme(
      primaryBackground: AppColors.cyanStrong,
      secondaryBackground: AppColors.surfaceOverlay,
      primaryIcon: Colors.black,
      secondaryIcon: AppColors.textPrimary,
      primarySize: 76,
      secondarySize: 56,
      ringColor: AppColors.cyanGlow,
    );
  }

  @override
  TransportControlTheme copyWith({
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? primaryIcon,
    Color? secondaryIcon,
    double? primarySize,
    double? secondarySize,
    Color? ringColor,
  }) {
    return TransportControlTheme(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryIcon: primaryIcon ?? this.primaryIcon,
      secondaryIcon: secondaryIcon ?? this.secondaryIcon,
      primarySize: primarySize ?? this.primarySize,
      secondarySize: secondarySize ?? this.secondarySize,
      ringColor: ringColor ?? this.ringColor,
    );
  }

  @override
  TransportControlTheme lerp(
    ThemeExtension<TransportControlTheme>? other,
    double t,
  ) {
    if (other is! TransportControlTheme) {
      return this;
    }

    return TransportControlTheme(
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
              primaryBackground,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t) ??
              secondaryBackground,
      primaryIcon: Color.lerp(primaryIcon, other.primaryIcon, t) ?? primaryIcon,
      secondaryIcon:
          Color.lerp(secondaryIcon, other.secondaryIcon, t) ?? secondaryIcon,
      primarySize: lerpDouble(primarySize, other.primarySize, t) ?? primarySize,
      secondarySize:
          lerpDouble(secondarySize, other.secondarySize, t) ?? secondarySize,
      ringColor: Color.lerp(ringColor, other.ringColor, t) ?? ringColor,
    );
  }
}

@immutable
class SectionHeaderTheme extends ThemeExtension<SectionHeaderTheme> {
  const SectionHeaderTheme({
    required this.titleColor,
    required this.subtitleColor,
    required this.ruleColor,
    required this.kickerSpacing,
    required this.contentSpacing,
  });

  final Color titleColor;
  final Color subtitleColor;
  final Color ruleColor;
  final double kickerSpacing;
  final double contentSpacing;

  factory SectionHeaderTheme.console() {
    return const SectionHeaderTheme(
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
      ruleColor: AppColors.outlineStrong,
      kickerSpacing: AppSpacing.xs,
      contentSpacing: AppSpacing.md,
    );
  }

  @override
  SectionHeaderTheme copyWith({
    Color? titleColor,
    Color? subtitleColor,
    Color? ruleColor,
    double? kickerSpacing,
    double? contentSpacing,
  }) {
    return SectionHeaderTheme(
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      ruleColor: ruleColor ?? this.ruleColor,
      kickerSpacing: kickerSpacing ?? this.kickerSpacing,
      contentSpacing: contentSpacing ?? this.contentSpacing,
    );
  }

  @override
  SectionHeaderTheme lerp(
    ThemeExtension<SectionHeaderTheme>? other,
    double t,
  ) {
    if (other is! SectionHeaderTheme) {
      return this;
    }

    return SectionHeaderTheme(
      titleColor: Color.lerp(titleColor, other.titleColor, t) ?? titleColor,
      subtitleColor:
          Color.lerp(subtitleColor, other.subtitleColor, t) ?? subtitleColor,
      ruleColor: Color.lerp(ruleColor, other.ruleColor, t) ?? ruleColor,
      kickerSpacing:
          lerpDouble(kickerSpacing, other.kickerSpacing, t) ?? kickerSpacing,
      contentSpacing:
          lerpDouble(contentSpacing, other.contentSpacing, t) ?? contentSpacing,
    );
  }
}

@immutable
class NavigationChromeTheme extends ThemeExtension<NavigationChromeTheme> {
  const NavigationChromeTheme({
    required this.sidebarBackground,
    required this.sidebarBorder,
    required this.itemBackground,
    required this.activeItemBackground,
    required this.activeItemBorder,
    required this.prominentItemBackground,
    required this.prominentItemBorder,
    required this.activeGlow,
    required this.itemRadius,
  });

  final Color sidebarBackground;
  final Color sidebarBorder;
  final Color itemBackground;
  final Color activeItemBackground;
  final Color activeItemBorder;
  final Color prominentItemBackground;
  final Color prominentItemBorder;
  final Color activeGlow;
  final double itemRadius;

  factory NavigationChromeTheme.console() {
    return const NavigationChromeTheme(
      sidebarBackground: AppColors.surface,
      sidebarBorder: AppColors.outline,
      itemBackground: AppColors.surface,
      activeItemBackground: AppColors.surfaceOverlay,
      activeItemBorder: AppColors.cyanStrong,
      prominentItemBackground: AppColors.surfaceOverlay,
      prominentItemBorder: AppColors.outlineStrong,
      activeGlow: AppColors.cyanGlow,
      itemRadius: AppRadii.md,
    );
  }

  @override
  NavigationChromeTheme copyWith({
    Color? sidebarBackground,
    Color? sidebarBorder,
    Color? itemBackground,
    Color? activeItemBackground,
    Color? activeItemBorder,
    Color? prominentItemBackground,
    Color? prominentItemBorder,
    Color? activeGlow,
    double? itemRadius,
  }) {
    return NavigationChromeTheme(
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      itemBackground: itemBackground ?? this.itemBackground,
      activeItemBackground: activeItemBackground ?? this.activeItemBackground,
      activeItemBorder: activeItemBorder ?? this.activeItemBorder,
      prominentItemBackground:
          prominentItemBackground ?? this.prominentItemBackground,
      prominentItemBorder: prominentItemBorder ?? this.prominentItemBorder,
      activeGlow: activeGlow ?? this.activeGlow,
      itemRadius: itemRadius ?? this.itemRadius,
    );
  }

  @override
  NavigationChromeTheme lerp(
    ThemeExtension<NavigationChromeTheme>? other,
    double t,
  ) {
    if (other is! NavigationChromeTheme) {
      return this;
    }

    return NavigationChromeTheme(
      sidebarBackground:
          Color.lerp(sidebarBackground, other.sidebarBackground, t) ??
              sidebarBackground,
      sidebarBorder:
          Color.lerp(sidebarBorder, other.sidebarBorder, t) ?? sidebarBorder,
      itemBackground:
          Color.lerp(itemBackground, other.itemBackground, t) ?? itemBackground,
      activeItemBackground:
          Color.lerp(activeItemBackground, other.activeItemBackground, t) ??
              activeItemBackground,
      activeItemBorder:
          Color.lerp(activeItemBorder, other.activeItemBorder, t) ??
              activeItemBorder,
      prominentItemBackground: Color.lerp(
              prominentItemBackground, other.prominentItemBackground, t) ??
          prominentItemBackground,
      prominentItemBorder:
          Color.lerp(prominentItemBorder, other.prominentItemBorder, t) ??
              prominentItemBorder,
      activeGlow: Color.lerp(activeGlow, other.activeGlow, t) ?? activeGlow,
      itemRadius: lerpDouble(itemRadius, other.itemRadius, t) ?? itemRadius,
    );
  }
}

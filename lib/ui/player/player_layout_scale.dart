class PlayerLayoutScale {
  const PlayerLayoutScale({
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.heroSize,
    required this.metaSpacing,
    required this.sectionSpacing,
    required this.timelineBottomSpacing,
    required this.transportGap,
    required this.titleSize,
  });

  final double maxContentWidth;
  final double horizontalPadding;
  final double heroSize;
  final double metaSpacing;
  final double sectionSpacing;
  final double timelineBottomSpacing;
  final double transportGap;
  final double titleSize;

  static PlayerLayoutScale forViewport(double width, double height) {
    if (height < 620) {
      return const PlayerLayoutScale(
        maxContentWidth: 520,
        horizontalPadding: 16,
        heroSize: 132,
        metaSpacing: 6,
        sectionSpacing: 12,
        timelineBottomSpacing: 8,
        transportGap: 18,
        titleSize: 28,
      );
    }
    return fromWidth(width);
  }

  static PlayerLayoutScale fromWidth(double width) {
    if (width >= 1200) {
      return const PlayerLayoutScale(
        maxContentWidth: 760,
        horizontalPadding: 40,
        heroSize: 360,
        metaSpacing: 14,
        sectionSpacing: 44,
        timelineBottomSpacing: 28,
        transportGap: 28,
        titleSize: 52,
      );
    }

    if (width >= 760) {
      return const PlayerLayoutScale(
        maxContentWidth: 620,
        horizontalPadding: 32,
        heroSize: 300,
        metaSpacing: 12,
        sectionSpacing: 38,
        timelineBottomSpacing: 24,
        transportGap: 24,
        titleSize: 44,
      );
    }

    return const PlayerLayoutScale(
      maxContentWidth: 520,
      horizontalPadding: 20,
      heroSize: 240,
      metaSpacing: 10,
      sectionSpacing: 30,
      timelineBottomSpacing: 20,
      transportGap: 18,
      titleSize: 36,
    );
  }
}

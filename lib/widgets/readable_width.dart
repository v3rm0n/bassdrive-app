import 'package:flutter/material.dart';

import '../ui/theme/app_theme_tokens.dart';

/// Keeps page content to a readable column on wide windows, with subtle studio
/// rack framing on ultrawide desktop viewports. Below [maxWidth] it has no effect.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child, this.maxWidth = 960});

  static const double defaultMaxWidth = 960;

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showRackBorders = constraints.maxWidth > maxWidth + 48;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showRackBorders
                ? DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: const BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(color: AppColors.outline),
                      ),
                    ),
                    child: child,
                  )
                : child,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

/// Keeps page content to a readable column on wide windows. Below
/// [maxWidth] it has no effect.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child, this.maxWidth = 960});

  static const double defaultMaxWidth = 960;

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

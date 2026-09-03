import 'package:flutter/material.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceDim : colors.surface,
      ),
      child: Stack(
        children: [
          if (!isDark)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 240,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withValues(alpha: .12),
                        colors.primaryContainer.withValues(alpha: .07),
                        Colors.transparent,
                      ],
                      stops: const [0, .45, 1],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

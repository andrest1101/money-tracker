import 'package:flutter/material.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            Color.lerp(
              colors.surface,
              colors.primaryContainer,
              isDark ? .16 : .3,
            )!,
            colors.surface,
          ],
          stops: const [0, .46, 1],
        ),
      ),
      child: CustomPaint(
        painter: _FinancialGridPainter(
          color: colors.primary.withValues(alpha: isDark ? .055 : .035),
        ),
        child: child,
      ),
    );
  }
}

/// A quiet data-grid texture gives the app a finance-dashboard character
/// without competing with the content above it.
class _FinancialGridPainter extends CustomPainter {
  const _FinancialGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 36.0;

    for (var x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FinancialGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

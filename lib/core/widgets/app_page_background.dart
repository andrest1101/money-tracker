import 'package:flutter/material.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surface),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -70,
            child: _GlowOrb(
              color: colors.primary.withValues(alpha: .13),
              size: 280,
            ),
          ),
          Positioned(
            top: 190,
            left: -150,
            child: _GlowOrb(
              color: colors.secondary.withValues(alpha: .08),
              size: 300,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              104,
            ),
            children: [
              Row(
                children: [
                  SkeletonBox(width: 120, height: 14, colors: colors),
                  const Spacer(),
                  SkeletonBox(
                    width: 36,
                    height: 36,
                    radius: 18,
                    colors: colors,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SkeletonBox(
                    width: 40,
                    height: 40,
                    radius: 20,
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SkeletonBox(width: 150, height: 28, colors: colors),
              const SizedBox(height: AppSpacing.lg),
              SkeletonBox(
                width: double.infinity,
                height: 176,
                radius: AppRadius.hero,
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.section),
              SkeletonBox(width: 160, height: 20, colors: colors),
              const SizedBox(height: AppSpacing.sm),
              SkeletonBox(
                width: double.infinity,
                height: 64,
                radius: AppRadius.control,
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.section),
              SkeletonBox(width: 200, height: 20, colors: colors),
              const SizedBox(height: AppSpacing.sm),
              SkeletonBox(
                width: double.infinity,
                height: 150,
                radius: AppRadius.control,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SkeletonBox(
      width: double.infinity,
      height: height,
      radius: AppRadius.control,
      colors: colors,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.colors,
    this.radius = 12,
  });

  final double width;
  final double height;
  final ColorScheme colors;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

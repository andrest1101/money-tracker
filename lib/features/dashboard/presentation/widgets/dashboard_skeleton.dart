import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 130, height: 18, colors: colors),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 180, height: 30, colors: colors),
                  const SizedBox(height: 7),
                  SkeletonBox(width: 220, height: 12, colors: colors),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.list(
            children: [
              SkeletonBox(
                width: double.infinity,
                height: 160,
                radius: 28,
                colors: colors,
              ),
              const SizedBox(height: 12),
              SkeletonBox(
                width: double.infinity,
                height: 120,
                radius: 24,
                colors: colors,
              ),
              const SizedBox(height: 12),
              SkeletonBox(
                width: double.infinity,
                height: 130,
                radius: 24,
                colors: colors,
              ),
            ],
          ),
        ),
      ],
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
      radius: 24,
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
  final double radius;
  final ColorScheme colors;

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

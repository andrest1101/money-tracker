import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pengganti [SegmentedButton] untuk mode autentikasi.
///
/// SegmentedButton bawaan tidak melakukan ellipsis dan mudah memecah kata di
/// tengah saat layar sempit. Kontrol ini memakai lebar sama rata, tanpa ikon,
/// dan membiarkan label membungkus hanya di batas kata.
class AuthModeSwitcher extends StatelessWidget {
  const AuthModeSwitcher({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = AppMotion.durationOf(context, AppDuration.fast);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: _Segment(
                label: labels[index],
                selected: index == selectedIndex,
                duration: duration,
                onTap: () => onChanged(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control - AppSpacing.xxs),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Tetap aktif saat terpilih: pada mode passwordless, tab "Masuk"
          // berfungsi sebagai jalan kembali ke login biasa.
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppRadius.control - AppSpacing.xxs,
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.standard,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected ? scheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(
                AppRadius.control - AppSpacing.xxs,
              ),
              border: Border.all(
                color: selected ? scheme.outlineVariant : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

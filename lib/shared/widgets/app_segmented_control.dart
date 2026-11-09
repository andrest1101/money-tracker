import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

/// Kontrol segmen satu baris dengan lebar sama rata.
///
/// Berbeda dari [SegmentedButton] bawaan, label tidak pernah membungkus ke
/// baris kedua. Ukuran teks dihitung sekali agar label terpanjang tetap muat,
/// lalu dipakai untuk semua segmen supaya tinggi dan ukuran teks tetap seragam.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.semanticLabel,
  }) : assert(labels.length > 1, 'Butuh minimal dua segmen.'),
       assert(
         selectedIndex >= 0 && selectedIndex < labels.length,
         'selectedIndex di luar jumlah label.',
       );

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Label aksesibilitas untuk keseluruhan grup segmen.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = AppMotion.durationOf(context, AppDuration.fast);
    final segmentRadius = BorderRadius.circular(
      AppRadius.control - AppSpacing.xxs,
    );
    final baseStyle = (theme.textTheme.labelLarge ?? const TextStyle())
        .copyWith(fontWeight: FontWeight.w800, height: 1.2);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ruang yang tersisa setelah padding tiap segmen (4 kiri + 4 kanan)
            // dan hairline border segmen terpilih.
            final segmentWidth =
                (constraints.maxWidth - AppSpacing.xxs * (labels.length - 1)) /
                labels.length;
            final labelWidth = math.max(0.0, segmentWidth - AppSpacing.xs - 2);
            final labelStyle = _fitLabels(
              context: context,
              labels: labels,
              baseStyle: baseStyle,
              maxWidth: labelWidth,
            );

            return Row(
              children: [
                for (var index = 0; index < labels.length; index++) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: _Segment(
                      label: labels[index],
                      selected: index == selectedIndex,
                      duration: duration,
                      radius: segmentRadius,
                      labelStyle: labelStyle,
                      onTap: () => onChanged(index),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ukuran font bersama untuk semua label, agar segmen tetap seragam.
///
/// `TextPainter` mengukur dengan text scaler perangkat, jadi kontrol tetap muat
/// saat pengguna memperbesar ukuran teks tanpa memecah kata ke baris kedua.
TextStyle _fitLabels({
  required BuildContext context,
  required List<String> labels,
  required TextStyle baseStyle,
  required double maxWidth,
}) {
  if (maxWidth <= 0) return baseStyle;
  final direction = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  var widest = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: baseStyle),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    widest = math.max(widest, painter.width);
    painter.dispose();
  }
  if (widest <= 0 || widest <= maxWidth) return baseStyle;
  // 0.98 memberi ruang pembulatan sub-piksel agar ellipsis tidak muncul.
  final factor = (maxWidth * 0.98 / widest).clamp(0.7, 1.0);
  return baseStyle.apply(fontSizeFactor: factor);
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.duration,
    required this.radius,
    required this.labelStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Duration duration;
  final BorderRadius radius;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.standard,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: selected ? scheme.surface : Colors.transparent,
              borderRadius: radius,
              border: Border.all(
                color: selected ? scheme.outlineVariant : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: labelStyle.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

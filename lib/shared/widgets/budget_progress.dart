import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/rupiah_formatter.dart';

/// Bar anggaran 8dp yang beranimasi, dengan keterangan sisa.
///
/// Warna berubah menjadi [AppColors.danger] saat pemakaian mencapai 80%,
/// sesuai aturan PRD. Angka tetap ditampilkan walau anggaran belum diatur.
class BudgetProgress extends StatelessWidget {
  const BudgetProgress({
    super.key,
    required this.spent,
    required this.limit,
    this.caption,
  });

  final double spent;
  final double limit;
  final String? caption;

  bool get _hasLimit => limit > 0;

  double get _ratio {
    if (!_hasLimit) return 0;
    return (spent / limit).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isDanger = _hasLimit && spent / limit >= 0.8;
    final barColor = isDanger ? colors.danger : theme.colorScheme.primary;
    final remaining = limit - spent;
    final headerLabel = !_hasLimit
        ? 'Anggaran belum diatur'
        : remaining >= 0
        ? 'Sisa ${formatRupiah(remaining)}'
        : 'Lebih ${formatRupiah(remaining.abs())}';
    final percentage = _hasLimit ? '${(spent / limit * 100).round()}%' : '—';

    return Semantics(
      label: !_hasLimit
          ? 'Anggaran belum diatur'
          : 'Anggaran terpakai ${formatRupiah(spent)} dari '
                '${formatRupiah(limit)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  headerLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDanger ? colors.danger : colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                percentage,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDanger ? colors.danger : colors.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _ratio),
            duration: AppMotion.durationOf(context, AppDuration.progress),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: colors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              );
            },
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

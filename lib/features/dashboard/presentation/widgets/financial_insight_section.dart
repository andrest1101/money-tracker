import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/amount_text.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_inline.dart';
import '../../domain/entities/financial_insight_entity.dart';

/// Insight keuangan tanpa kartu: satu kalimat ringkas + dua metrik.
///
/// Seluruh blok bisa diketuk untuk membuka [FinancialInsightOverviewSheet].
class FinancialInsightSection extends StatelessWidget {
  const FinancialInsightSection({super.key, required this.insight, this.onTap});

  final FinancialInsightEntity insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final scheme = theme.colorScheme;
    final hasComparison = insight.previousExpense > 0;
    final improving = insight.expenseChangeRatio <= 0;
    final percent = (insight.expenseChangeRatio.abs() * 100).round();
    final sentence = !hasComparison
        ? (insight.expense == 0
              ? 'Belum ada pengeluaran pada periode ini.'
              : 'Ini periode pertama dengan pengeluaran tercatat.')
        : improving
        ? 'Pengeluaran turun $percent% dibanding periode sebelumnya.'
        : 'Pengeluaran naik $percent% dibanding periode sebelumnya.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Insight keuangan'),
        const SizedBox(height: AppSpacing.xxs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            sentence,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StatInline(
                          label: 'Pengeluaran',
                          amount: insight.expense,
                          tone: AmountTone.expense,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: StatInline(
                          label: 'Rata-rata / hari',
                          amount: insight.averageDailyExpense,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

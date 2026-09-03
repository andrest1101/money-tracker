import 'package:flutter/material.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/financial_insight_entity.dart';

class FinancialInsightCard extends StatelessWidget {
  const FinancialInsightCard({super.key, required this.insight, this.onTap});

  final FinancialInsightEntity insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final improving = insight.expenseChangeRatio <= 0;
    final trendColor = improving ? colors.tertiary : colors.error;
    final trend = insight.previousExpense == 0
        ? (insight.expense == 0 ? 'Pengeluaran stabil' : 'Belum ada pembanding')
        : '${(insight.expenseChangeRatio.abs() * 100).round()}% ${improving ? 'lebih rendah' : 'lebih tinggi'}';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: isDark ? colors.surfaceContainerHigh : colors.primaryContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        hoverColor: colors.primary.withValues(alpha: .06),
        splashColor: colors.primary.withValues(alpha: .1),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight keuangan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          insight.periodLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.lightbulb_outline_rounded, color: colors.tertiary),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InsightMetric(
                      label: 'Pengeluaran',
                      value: formatRupiah(insight.expense),
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InsightMetric(
                      label: 'Rata-rata / hari',
                      value: formatRupiah(insight.averageDailyExpense),
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      improving
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: trendColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$trend dibanding periode sebelumnya',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      insight.topCategory == null
                          ? 'Belum ada kategori pengeluaran pada periode ini.'
                          : 'Kategori terbesar: ${insight.topCategory} • ${insight.transactionCount} transaksi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

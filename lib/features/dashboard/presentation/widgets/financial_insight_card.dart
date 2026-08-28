import 'package:flutter/material.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/financial_insight_entity.dart';

class FinancialInsightCard extends StatelessWidget {
  const FinancialInsightCard({super.key, required this.insight});

  final FinancialInsightEntity insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final improving = insight.expenseChangeRatio <= 0;
    final trendColor = improving
        ? Colors.green.shade700
        : Colors.orange.shade800;
    final trend = insight.previousExpense == 0
        ? (insight.expense == 0 ? 'Pengeluaran stabil' : 'Belum ada pembanding')
        : '${(insight.expenseChangeRatio.abs() * 100).round()}% ${improving ? 'lebih rendah' : 'lebih tinggi'}';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colors.primaryContainer.withValues(alpha: 0.42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_graph_rounded, color: colors.primary),
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
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InsightMetric(
                    label: 'Pengeluaran',
                    value: formatRupiah(insight.expense),
                    color: Colors.red.shade700,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.65),
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
            const SizedBox(height: 12),
            Text(
              insight.topCategory == null
                  ? 'Belum ada kategori pengeluaran pada periode ini.'
                  : 'Kategori terbesar: ${insight.topCategory} • ${insight.transactionCount} transaksi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

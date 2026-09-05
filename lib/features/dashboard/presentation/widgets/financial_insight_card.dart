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
    final accentColor = isDark ? const Color(0xFF8BD5C8) : colors.primary;
    final expenseColor = isDark ? const Color(0xFFFF6B6B) : colors.error;
    final trendColor = improving
        ? (isDark ? const Color(0xFF8BD5A5) : colors.tertiary)
        : expenseColor;
    final trend = insight.previousExpense == 0
        ? (insight.expense == 0 ? 'Pengeluaran stabil' : 'Belum ada pembanding')
        : '${(insight.expenseChangeRatio.abs() * 100).round()}% ${improving ? 'lebih rendah' : 'lebih tinggi'}';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF22282E), Color(0xFF1C2127)]
                : [
                    colors.primaryContainer,
                    colors.secondaryContainer.withValues(alpha: .72),
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? const Color(0xFF343B43)
                : colors.primary.withValues(alpha: .16),
          ),
        ),
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
                        color: accentColor.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.auto_graph_rounded, color: accentColor),
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
                    Icon(Icons.lightbulb_outline_rounded, color: accentColor),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InsightMetric(
                        label: 'Pengeluaran',
                        value: formatRupiah(insight.expense),
                        color: expenseColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InsightMetric(
                        label: 'Rata-rata / hari',
                        value: formatRupiah(insight.averageDailyExpense),
                        color: accentColor,
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
                    color: isDark
                        ? const Color(0xFF292F36)
                        : colors.surfaceContainerHigh,
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
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode memakai aksen lembut agar nominal tetap terbaca tanpa silau.
    final isExpense =
        color == theme.colorScheme.error || color == const Color(0xFFFF6B6B);
    final displayColor = isExpense
        ? (isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE53935))
        : (isDark ? const Color(0xFF8BD5C8) : const Color(0xFF0D9488));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: .12),
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
                color: displayColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

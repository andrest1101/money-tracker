import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../../analytics/domain/entities/cash_flow_point_entity.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../domain/entities/financial_insight_entity.dart';

class FinancialInsightCard extends ConsumerWidget {
  const FinancialInsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.onChartTap,
  });

  final FinancialInsightEntity insight;
  final VoidCallback? onTap;
  final VoidCallback? onChartTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final improving = insight.expenseChangeRatio <= 0;
    final trendColor = improving ? colors.tertiary : colors.error;
    final trend = insight.previousExpense == 0
        ? (insight.expense == 0 ? 'Pengeluaran stabil' : 'Belum ada pembanding')
        : '${(insight.expenseChangeRatio.abs() * 100).round()}% ${improving ? 'lebih rendah' : 'lebih tinggi'}';

    if (insight.transactionCount == 0) {
      return Card(
        elevation: 0,
        color: colors.primaryContainer.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.insights_outlined, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insight sedang menunggu data',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambahkan beberapa transaksi agar pola keuanganmu bisa dianalisis.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cashFlowAsync = ref.watch(cashFlowPointsProvider);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colors.primaryContainer.withValues(alpha: 0.42),
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
                      color: colors.primary.withValues(alpha: 0.14),
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
              cashFlowAsync.when(
                loading: () => const SizedBox(height: 58),
                error: (_, __) => const SizedBox.shrink(),
                data: (points) => points.every((point) => !point.hasActivity)
                    ? const SizedBox.shrink()
                    : _InsightChartPreview(points: points, onTap: onChartTap),
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
      ),
    );
  }
}

class _InsightChartPreview extends StatelessWidget {
  const _InsightChartPreview({required this.points, this.onTap});

  final List<CashFlowPointEntity> points;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxValue = points.fold<double>(0, (max, point) {
      final value = point.income > point.expense ? point.income : point.expense;
      return value > max ? value : max;
    });

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: colors.primary.withValues(alpha: .08),
        splashColor: colors.primary.withValues(alpha: .12),
        child: Ink(
          height: 88,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.primary.withValues(alpha: .16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 15,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Arus kas 7 hari terakhir',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ketuk untuk detail',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxValue == 0 ? 1 : maxValue * 1.2,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: [
                      for (var index = 0; index < points.length; index++)
                        BarChartGroupData(
                          x: index,
                          barsSpace: 2,
                          barRods: [
                            BarChartRodData(
                              toY: points[index].income,
                              width: 4,
                              color: colors.tertiary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: points[index].expense,
                              width: 4,
                              color: colors.error,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
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

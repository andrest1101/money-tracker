import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/financial_insight_entity.dart';
import '../../domain/usecases/calculate_budget_cycle_period_usecase.dart';

class FinancialInsightOverviewSheet extends StatelessWidget {
  const FinancialInsightOverviewSheet({
    super.key,
    required this.insight,
    required this.transactions,
    required this.cycleDay,
  });

  final FinancialInsightEntity insight;
  final List<TransactionEntity> transactions;
  final int cycleDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cycle = const CalculateBudgetCyclePeriodUseCase().execute(
      date: DateTime.now(),
      cycleDay: cycleDay,
    );
    final current = transactions.where((transaction) {
      return !transaction.date.isBefore(cycle.start) &&
          !transaction.date.isAfter(DateTime.now());
    }).toList();
    final categories = <String, double>{};
    for (final transaction in current) {
      if (transaction.isExpense) {
        categories[transaction.category] =
            (categories[transaction.category] ?? 0) + transaction.amount;
      }
    }
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategory = sortedCategories.isEmpty
        ? null
        : sortedCategories.first;
    final improving = insight.expenseChangeRatio <= 0;
    final trendColor = improving ? colors.tertiary : colors.error;
    final difference = insight.expense - insight.previousExpense;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .92,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight keuangan',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatDateShort(cycle.start)} - ${formatDateShort(cycle.end)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ringkasan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InsightOverviewMetric(
                      label: 'Pemasukan',
                      value: formatRupiah(insight.income),
                      color: colors.tertiary,
                      icon: Icons.south_west_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InsightOverviewMetric(
                      label: 'Pengeluaran',
                      value: formatRupiah(insight.expense),
                      color: colors.error,
                      icon: Icons.north_east_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _InsightOverviewMetric(
                label: 'Saldo bersih',
                value: formatRupiah(insight.net),
                color: insight.net >= 0 ? colors.primary : colors.error,
                icon: Icons.account_balance_wallet_outlined,
                wide: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Perbandingan pengeluaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: trendColor.withValues(alpha: .28)),
                ),
                child: Row(
                  children: [
                    Icon(
                      improving
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: trendColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.previousExpense == 0
                            ? 'Belum ada data pembanding dari siklus sebelumnya.'
                            : '${difference.abs() == 0 ? 'Tidak ada perubahan' : formatRupiah(difference.abs())} ${difference <= 0 ? 'lebih rendah' : 'lebih tinggi'} dari siklus sebelumnya.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Arus pengeluaran 7 hari terakhir',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 220,
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .55),
                  ),
                ),
                child: _CashFlowChart(transactions: current, colors: colors),
              ),
              const SizedBox(height: 20),
              Text(
                'Kategori terbesar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (maxCategory == null)
                Text('Belum ada pengeluaran pada siklus ini.')
              else
                ...sortedCategories
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: colors.primaryContainer,
                          child: Text('${entry.key + 1}'),
                        ),
                        title: Text(entry.value.key),
                        trailing: Text(
                          formatRupiah(entry.value.value),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              _InsightOverviewMetric(
                label: 'Rata-rata pengeluaran per hari',
                value: formatRupiah(insight.averageDailyExpense),
                color: colors.primary,
                icon: Icons.show_chart_rounded,
                wide: true,
              ),
              const SizedBox(height: 10),
              _InsightOverviewMetric(
                label: 'Transaksi pada periode ini',
                value: '${insight.transactionCount} transaksi',
                color: colors.primary,
                icon: Icons.receipt_long_outlined,
                wide: true,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({required this.transactions, required this.colors});

  final List<TransactionEntity> transactions;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      return date;
    });
    final values = days.map((day) {
      var total = 0.0;
      for (final transaction in transactions) {
        if (transaction.isExpense &&
            transaction.date.year == day.year &&
            transaction.date.month == day.month &&
            transaction.date.day == day.day) {
          total += transaction.amount;
        }
      }
      return total;
    }).toList();
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return BarChart(
      BarChartData(
        maxY: maxValue == 0 ? 1 : maxValue * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  formatRupiah(rod.toY),
                  TextStyle(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${days[value.toInt().clamp(0, 6)].day}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < values.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  width: 18,
                  borderRadius: BorderRadius.circular(5),
                  color: colors.error,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InsightOverviewMetric extends StatelessWidget {
  const _InsightOverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

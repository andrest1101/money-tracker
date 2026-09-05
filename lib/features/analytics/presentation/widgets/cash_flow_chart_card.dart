import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/cash_flow_point_entity.dart';
import '../providers/analytics_providers.dart';

class CashFlowChartCard extends ConsumerWidget {
  const CashFlowChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final range = ref.watch(cashFlowRangeProvider);
    final pointsAsync = ref.watch(cashFlowPointsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arus kas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pemasukan dan pengeluaran berdasarkan tanggal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.bar_chart_rounded, color: colors.primary),
              ],
            ),
            const SizedBox(height: 14),
            _RangeSelector(range: range),
            const SizedBox(height: 16),
            pointsAsync.when(
              loading: () => const SizedBox(
                height: 230,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _ChartMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Grafik belum tersedia',
                message: 'Periksa koneksi lalu coba lagi.',
                action: () => ref.invalidate(cashFlowPointsProvider),
              ),
              data: (points) => points.every((point) => !point.hasActivity)
                  ? const _ChartMessage(
                      icon: Icons.insights_outlined,
                      title: 'Belum ada arus kas',
                      message:
                          'Catat transaksi untuk melihat pergerakan uangmu.',
                    )
                  : _ChartContent(points: points),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({required this.range});

  final CashFlowRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final item in [
          (CashFlowRange.sevenDays, '7 Hari'),
          (CashFlowRange.thirtyDays, '30 Hari'),
          (CashFlowRange.activeCycle, 'Siklus'),
        ])
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: item.$1 == CashFlowRange.activeCycle ? 0 : 6,
              ),
              child: InkWell(
                onTap: () =>
                    ref.read(cashFlowRangeProvider.notifier).setRange(item.$1),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: range == item.$1
                        ? colors.primaryContainer
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: range == item.$1
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChartContent extends StatefulWidget {
  const _ChartContent({required this.points});

  final List<CashFlowPointEntity> points;

  @override
  State<_ChartContent> createState() => _ChartContentState();
}

class _ChartContentState extends State<_ChartContent> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final points = widget.points;
    final income = points.fold<double>(0, (sum, point) => sum + point.income);
    final expense = points.fold<double>(0, (sum, point) => sum + point.expense);
    final maxValue = points.fold<double>(0, (max, point) {
      final highest = point.income > point.expense
          ? point.income
          : point.expense;
      return highest > max ? highest : max;
    });

    return Column(
      children: [
        Row(
          children: [
            _LegendDot(
              color: colors.tertiary,
              label: 'Masuk ${formatRupiah(income)}',
            ),
            const SizedBox(width: 14),
            _LegendDot(
              color: colors.error,
              label: 'Keluar ${formatRupiah(expense)}',
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_selectedIndex case final index?) ...[
          _SelectedCashFlow(
            point: points[index],
            onClear: () => setState(() => _selectedIndex = null),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 210,
          child: BarChart(
            BarChartData(
              maxY: maxValue == 0 ? 1 : maxValue * 1.22,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: 12,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue == 0 ? 1 : maxValue / 3,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.outlineVariant.withValues(alpha: .35),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  final index = response?.spot?.touchedBarGroupIndex;
                  if (index == null || index < 0 || index >= points.length) {
                    return;
                  }
                  setState(() => _selectedIndex = index);
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.inverseSurface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        '${rodIndex == 0 ? 'Masuk' : 'Keluar'}\n${formatRupiah(rod.toY)}',
                        TextStyle(
                          color: colors.onInverseSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      final point = points[index];
                      final show =
                          points.length <= 10 ||
                          index % ((points.length / 6).ceil()) == 0;
                      return SideTitleWidget(
                        meta: meta,
                        child: show
                            ? Text(
                                '${point.date.day}',
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var index = 0; index < points.length; index++)
                  BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: points[index].income,
                        width: 7,
                        color: colors.tertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: points[index].expense,
                        width: 7,
                        color: colors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedCashFlow extends StatelessWidget {
  const _SelectedCashFlow({required this.point, required this.onClear});

  final CashFlowPointEntity point;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.date.day}/${point.date.month}/${point.date.year}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Masuk ${formatRupiah(point.income)}  •  Keluar ${formatRupiah(point.expense)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Sembunyikan detail',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 190,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: action,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

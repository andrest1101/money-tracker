import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/category_expense_entity.dart';
import '../providers/dashboard_providers.dart';

const _piePalette = [
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFFE53935),
  Color(0xFF00ACC1),
  Color(0xFF6D4C41),
  Color(0xFFF4511E),
];

class CategoryExpensePieCard extends ConsumerWidget {
  const CategoryExpensePieCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryExpensesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) {
          return const _EmptyExpenseCard();
        }
        return _CategoryExpenseContent(categories: categories);
      },
    );
  }
}

class _CategoryExpenseContent extends StatelessWidget {
  const _CategoryExpenseContent({required this.categories});

  final List<CategoryExpenseEntity> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total =
        categories.fold<double>(0, (sum, item) => sum + item.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran per Kategori',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 168,
                  height: 168,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      startDegreeOffset: -90,
                      sections: [
                        for (var i = 0; i < categories.length; i++)
                          PieChartSectionData(
                            value: categories[i].amount,
                            color: _piePalette[i % _piePalette.length],
                            radius: 34,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < categories.length; i++)
                        _LegendRow(
                          color: _piePalette[i % _piePalette.length],
                          category: categories[i].category,
                          amountLabel: formatRupiah(categories[i].amount),
                          percentLabel:
                              '${((categories[i].amount / total) * 100).round()}%',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.category,
    required this.amountLabel,
    required this.percentLabel,
  });

  final Color color;
  final String category;
  final String amountLabel;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountLabel,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  percentLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _EmptyExpenseCard extends StatelessWidget {
  const _EmptyExpenseCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Belum ada pengeluaran bulan ini. Yuk catat transaksimu!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
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
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: ListTile(
          leading: Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Grafik pengeluaran tidak tersedia'),
          trailing: IconButton(
            tooltip: 'Coba lagi',
            onPressed: () => ref.invalidate(categoryExpensesProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const _EmptyExpenseCard();
        }
        return _CategoryExpenseContent(categories: categories);
      },
    );
  }
}

class _CategoryExpenseContent extends ConsumerStatefulWidget {
  const _CategoryExpenseContent({required this.categories});

  final List<CategoryExpenseEntity> categories;

  @override
  ConsumerState<_CategoryExpenseContent> createState() =>
      _CategoryExpenseContentState();
}

class _CategoryExpenseContentState
    extends ConsumerState<_CategoryExpenseContent> {
  int _selectedIndex = 0;

  void _selectCategory(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _showCategoryDetails(CategoryExpenseEntity category) {
    final transactions = ref.read(transactionsStreamProvider).value ?? const [];
    final now = DateTime.now();
    final categoryTransactions = transactions.where((transaction) {
      return transaction.isExpense &&
          transaction.category == category.category &&
          transaction.date.year == now.year &&
          transaction.date.month == now.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CategoryDetailsSheet(
        category: category,
        transactions: categoryTransactions,
        totalExpense: widget.categories.fold<double>(
          0,
          (sum, item) => sum + item.amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.categories;
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);
    final selected = categories[_selectedIndex.clamp(0, categories.length - 1)];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                        'Pengeluaran per Kategori',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketuk bagian chart untuk menjelajah',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.touch_app_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 48,
                      startDegreeOffset: -90,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          final touched = response?.touchedSection;
                          if (touched == null ||
                              touched.touchedSectionIndex < 0) {
                            return;
                          }
                          _selectCategory(touched.touchedSectionIndex);
                        },
                      ),
                      sections: [
                        for (var i = 0; i < categories.length; i++)
                          PieChartSectionData(
                            value: categories[i].amount,
                            color: _piePalette[i % _piePalette.length]
                                .withValues(
                                  alpha: i == _selectedIndex ? 1 : 0.35,
                                ),
                            radius: i == _selectedIndex ? 38 : 30,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                IgnorePointer(
                  child: SizedBox(
                    width: 104,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selected.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatRupiah(selected.amount),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color:
                                  _piePalette[_selectedIndex %
                                      _piePalette.length],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${((selected.amount / total) * 100).round()}% total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < categories.length; i++)
              InkWell(
                onTap: () => _selectCategory(i),
                borderRadius: BorderRadius.circular(12),
                child: _LegendRow(
                  color: _piePalette[i % _piePalette.length],
                  category: categories[i].category,
                  amountLabel: formatRupiah(categories[i].amount),
                  percentLabel:
                      '${((categories[i].amount / total) * 100).round()}%',
                  selected: i == _selectedIndex,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showCategoryDetails(selected),
                icon: const Icon(Icons.analytics_outlined, size: 19),
                label: Text('Lihat detail ${selected.category}'),
              ),
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
    required this.selected,
  });

  final Color color;
  final String category;
  final String amountLabel;
  final String percentLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.5,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryDetailsSheet extends StatelessWidget {
  const _CategoryDetailsSheet({
    required this.category,
    required this.transactions,
    required this.totalExpense,
  });

  final CategoryExpenseEntity category;
  final List<TransactionEntity> transactions;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = transactions.isEmpty
        ? 0.0
        : category.amount / transactions.length;
    final largest = transactions.isEmpty
        ? 0.0
        : transactions
              .map((item) => item.amount)
              .reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Pengeluaran', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    category.category,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total bulan ini',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatRupiah(category.amount),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${transactions.length} transaksi  •  ${((category.amount / (totalExpense == 0 ? 1 : totalExpense)) * 100).round()}% dari total pengeluaran',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailMetric(
                          label: 'Rata-rata',
                          value: formatRupiah(average),
                          icon: Icons.show_chart_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DetailMetric(
                          label: 'Terbesar',
                          value: formatRupiah(largest),
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Transaksi kategori ini',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada transaksi kategori ini',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: transactions.length,
                      itemBuilder: (_, index) =>
                          TransactionTile(transaction: transactions[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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

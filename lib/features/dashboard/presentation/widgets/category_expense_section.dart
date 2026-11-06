import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/category_palette.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/amount_text.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_inline.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_expense_entity.dart';
import '../../domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_error_view.dart';
import 'dashboard_skeleton.dart';

/// Pengeluaran per kategori: satu bar bertumpuk + daftar peringkat maksimal
/// lima baris. Menggantikan PieChart lama agar ruang vertikal lebih efisien.
class CategoryExpenseSection extends ConsumerWidget {
  const CategoryExpenseSection({super.key, required this.onAddExpense});

  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryExpensesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Pengeluaran per kategori'),
        const SizedBox(height: AppSpacing.xxs),
        categoriesAsync.when(
          loading: () => const SectionSkeleton(height: 120),
          error: (_, __) => DashboardSectionError(
            label: 'Pengeluaran per kategori tidak tersedia',
            onRetry: () => ref.invalidate(categoryExpensesProvider),
          ),
          data: (categories) => categories.isEmpty
              ? EmptyState(
                  compact: true,
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pengeluaran bulan ini',
                  message:
                      'Catat pengeluaran pertamamu untuk melihat ke mana '
                      'uangmu pergi. Ketuk tombol + di kanan bawah untuk '
                      'mulai mencatat.',
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                )
              : _CategoryExpenseContent(categories: categories),
        ),
      ],
    );
  }
}

class _CategoryExpenseContent extends ConsumerStatefulWidget {
  const _CategoryExpenseContent({required this.categories});

  final List<CategoryExpenseEntity> categories;

  @override
  ConsumerState<_CategoryExpenseContent> createState() => _CategoryExpenseContentState();
}

class _CategoryExpenseContentState extends ConsumerState<_CategoryExpenseContent> {
  late String _selectedCategory = widget.categories.first.category;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final categories = widget.categories;
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);
    final topCategories = categories.take(5).toList(growable: false);
    final selected = categories.firstWhere(
      (item) => item.category == _selectedCategory,
      orElse: () => categories.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryStackedBar(
          key: const ValueKey('category-expense-stacked-bar'),
          categories: categories,
          total: total,
          selectedCategory: selected.category,
          onSelected: (category) => setState(() => _selectedCategory = category),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: context.appColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  'Terpilih: ${selected.category} · ${(selected.amount / total * 100).round()}%',
                  key: const ValueKey('category-expense-selected-label'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                key: const ValueKey('category-expense-details-action'),
                onPressed: () => _openDetails(context, ref, selected, total),
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
                label: const Text('Detail'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < topCategories.length; i++)
          _CategoryRow(
            category: topCategories[i],
            total: total,
            selected: topCategories[i].category == selected.category,
            showDivider: i != topCategories.length - 1,
            onSelect: () => setState(() => _selectedCategory = topCategories[i].category),
          ),
        if (categories.length > topCategories.length)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '${categories.length - topCategories.length} kategori lain '
              'tersembunyi',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: context.appColors.textSecondary),
            ),
          ),
      ],
    );
  }

  void _openDetails(
    BuildContext context,
    WidgetRef ref,
    CategoryExpenseEntity category,
    double totalExpense,
  ) {
    final transactions = ref.read(transactionsStreamProvider).value ?? const [];
    final cycle = const CalculateBudgetCyclePeriodUseCase().execute(
      date: DateTime.now(),
      cycleDay: ref.read(budgetCycleDateProvider),
    );
    final endOfCycle = DateTime(cycle.end.year, cycle.end.month, cycle.end.day, 23, 59, 59, 999);
    final categoryTransactions = transactions.where((transaction) {
      return transaction.isExpense &&
          transaction.category == category.category &&
          !transaction.date.isBefore(cycle.start) &&
          !transaction.date.isAfter(endOfCycle);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CategoryExpenseDetailsSheet(
        category: category,
        transactions: categoryTransactions,
        totalExpense: totalExpense,
      ),
    );
  }
}

class _CategoryStackedBar extends StatelessWidget {
  const _CategoryStackedBar({
    super.key,
    required this.categories,
    required this.total,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<CategoryExpenseEntity> categories;
  final double total;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final semantics = categories
        .map(
          (item) =>
              '${item.category} ${((item.amount / total) * 100).round()} persen'
              '${item.category == selectedCategory ? ', dipilih' : ''}',
        )
        .join(', ');

    return Semantics(
      label: 'Komposisi pengeluaran. $semantics',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          height: 14,
          child: Row(
            children: [
              for (final item in categories)
                Expanded(
                  flex: ((item.amount / total) * 1000).round().clamp(1, 1000).toInt(),
                  child: Semantics(
                    button: true,
                    selected: item.category == selectedCategory,
                    label: '${item.category}, ${(item.amount / total * 100).round()} persen',
                    onTap: () => onSelected(item.category),
                    child: ExcludeSemantics(
                      child: Material(
                        color: item.category == selectedCategory
                            ? CategoryPalette.color(
                                item.category,
                                brightness,
                              ).withValues(alpha: .90)
                            : CategoryPalette.color(
                                item.category,
                                brightness,
                              ).withValues(alpha: .45),
                        child: InkWell(
                          onTap: () => onSelected(item.category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              border: item.category == selectedCategory
                                  ? Border.all(
                                      color: CategoryPalette.color(
                                        item.category,
                                        brightness,
                                      ).withValues(alpha: .8),
                                      width: 1,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.total,
    required this.selected,
    required this.showDivider,
    required this.onSelect,
  });

  final CategoryExpenseEntity category;
  final double total;
  final bool selected;
  final bool showDivider;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final percent = ((category.amount / total) * 100).round();

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? CategoryPalette.background(
                      category.category,
                      theme.brightness,
                    ).withValues(alpha: .15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: Semantics(
                selected: selected,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      CategoryIcon(category: category.category),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.category,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (selected)
                              Text(
                                'Kategori dipilih',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      SizedBox(
                        key: const ValueKey('category-expense-amount-column'),
                        width: 112,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: AmountText(
                                amount: category.amount,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$percent%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, indent: 52, color: colors.outline),
      ],
    );
  }
}

class _CategoryExpenseDetailsSheet extends StatelessWidget {
  const _CategoryExpenseDetailsSheet({
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
    final colors = theme.colorScheme;
    final average = transactions.isEmpty ? 0.0 : category.amount / transactions.length;
    final largest = transactions.isEmpty
        ? 0.0
        : transactions.map((item) => item.amount).reduce((a, b) => a > b ? a : b);
    final percent = totalExpense <= 0 ? 0 : ((category.amount / totalExpense) * 100).round();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: FractionallySizedBox(
            heightFactor: .88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.xxs,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail pengeluaran', style: theme.textTheme.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(category.category, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.hero),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total bulan ini',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onPrimaryContainer.withValues(alpha: .72),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            AmountText(
                              amount: category.amount,
                              color: colors.onPrimaryContainer,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              '${transactions.length} transaksi  •  '
                              '$percent% dari total pengeluaran',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onPrimaryContainer.withValues(alpha: .78),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailMetric(
                              label: 'Rata-rata',
                              amount: average,
                              icon: Icons.show_chart_rounded,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: _DetailMetric(
                              label: 'Terbesar',
                              amount: largest,
                              icon: Icons.trending_up_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                  child: Text('Transaksi kategori ini', style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Expanded(
                  child: transactions.isEmpty
                      ? EmptyState(
                          compact: true,
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum ada transaksi',
                          message: 'Transaksi kategori ini akan muncul di sini.',
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          itemCount: transactions.length,
                          itemBuilder: (_, index) {
                            final transaction = transactions[index];
                            return TransactionTile(
                              category: transaction.category,
                              amount: transaction.amount,
                              isExpense: transaction.isExpense,
                              note: transaction.note,
                              timeLabel: formatDateShort(transaction.date),
                              showDivider: index != transactions.length - 1,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.xs,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.amount, required this.icon});

  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: StatInline(label: label, amount: amount, valueStyle: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

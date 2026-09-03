import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../savings/data/providers/savings_goal_repository_provider.dart';
import '../../../dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/history_providers.dart';
import '../providers/quick_add_controller.dart';
import '../widgets/quick_add_transaction_sheet.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/category_filter_sheet.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  static const _periodFormatter = CalculateBudgetCyclePeriodUseCase();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionOptions(TransactionEntity transaction) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                transaction.category,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                formatRupiah(transaction.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Transaksi'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      QuickAddTransactionSheet(transaction: transaction),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Hapus Transaksi',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(transaction);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDailyOverview(
    String date,
    List<TransactionEntity> transactions,
    ({double income, double expense}) summary,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _DailyOverviewSheet(
        date: date,
        transactions: transactions,
        summary: summary,
        onTransactionTap: (transaction) {
          Navigator.pop(sheetContext);
          _showTransactionOptions(transaction);
        },
        onTransactionDismissed: _confirmDelete,
      ),
    );
  }

  void _confirmDelete(TransactionEntity transaction) async {
    // Get goal title if allocation transaction
    String? goalTitle;
    if (transaction.isAllocation && transaction.goalId != null) {
      try {
        final savingsRepo = ref.read(savingsGoalRepositoryProvider);
        final goal = await savingsRepo.getGoalById(transaction.goalId!);
        goalTitle = goal.title;
      } catch (e) {
        // Ignore if goal not found
      }
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Hapus Transaksi?'),
        content: Text(
          transaction.isAllocation && goalTitle != null
              ? 'Alokasi sebesar ${formatRupiah(transaction.amount)} untuk "$goalTitle" akan dihapus dan uang kembali ke saldo utama.'
              : 'Transaksi ${transaction.category} sebesar ${formatRupiah(transaction.amount)} akan dihapus permanen.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await ref
        .read(quickAddControllerProvider.notifier)
        .deleteTransaction(transaction);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            transaction.isAllocation
                ? 'Alokasi berhasil dihapus dan uang dikembalikan ke saldo'
                : 'Transaksi berhasil dihapus',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus transaksi. Coba lagi ya.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _pickDateRange(HistoryDateRange? currentRange) async {
    final today = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
      initialDateRange: currentRange == null
          ? null
          : DateTimeRange(start: currentRange.start, end: currentRange.end),
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
      cancelText: 'Batal',
    );
    if (!mounted || picked == null) return;

    final accepted = ref
        .read(historyDateRangeProvider.notifier)
        .setRange(picked.start, picked.end);
    if (!accepted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rentang maksimal adalah 31 hari.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingIntent = ref.watch(historyNavigationIntentProvider);
    ref.listen<HistoryNavigationIntent?>(historyNavigationIntentProvider, (
      _,
      intent,
    ) {
      if (intent != null) _scheduleApplyIntent(intent);
    });
    if (pendingIntent != null) _scheduleApplyIntent(pendingIntent);
    final grouped = ref.watch(filteredGroupedTransactionsProvider);
    final dailySummary = ref.watch(dailySummaryProvider);
    final filter = ref.watch(historyFilterProvider);
    final category = ref.watch(historyCategoryProvider);
    final cycleOnly = ref.watch(historyCycleProvider);
    final dateRange = ref.watch(historyDateRangeProvider);
    final categories = ref.watch(historyCategoriesProvider);
    final allTransactions =
        ref.watch(transactionsStreamProvider).value ?? const [];
    final categoryCounts = <String, int>{};
    final categoryTypes = <String, TransactionType>{};
    for (final transaction in allTransactions) {
      categoryCounts[transaction.category] =
          (categoryCounts[transaction.category] ?? 0) + 1;
      categoryTypes.putIfAbsent(transaction.category, () => transaction.type);
    }
    final cycle = _periodFormatter.execute(
      date: DateTime.now(),
      cycleDay: ref.watch(budgetCycleDateProvider),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(historySearchQueryProvider.notifier).setQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(historySearchQueryProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Card(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateRange(dateRange),
                        icon: Icon(
                          dateRange == null
                              ? Icons.date_range_outlined
                              : Icons.event_available_rounded,
                          size: 18,
                        ),
                        label: Text(
                          dateRange == null
                              ? 'Tanggal'
                              : '${formatDateShort(dateRange.start)} - ${formatDateShort(dateRange.end)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            builder: (_) => CategoryFilterSheet(
                              categories: categories,
                              counts: categoryCounts,
                              types: categoryTypes,
                              selectedCategory: category,
                            ),
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(historyCategoryProvider.notifier)
                              .setCategory(selected.isEmpty ? null : selected);
                        },
                        icon: Icon(
                          category == null
                              ? Icons.category_outlined
                              : Icons.filter_alt_rounded,
                          size: 18,
                        ),
                        label: Text(
                          category ?? 'Kategori',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Siklus aktif'),
                      avatar: cycleOnly
                          ? null
                          : const Icon(Icons.autorenew_rounded, size: 16),
                      selected: cycleOnly,
                      onSelected: (_) =>
                          ref.read(historyCycleProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (cycleOnly)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Siklus: ${formatDateShort(cycle.start)} - ${formatDateShort(cycle.end)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (dateRange != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rentang ${dateRange.lengthInDays} hari',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (filter != null ||
              category != null ||
              cycleOnly ||
              dateRange != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Filter aktif${filter != null ? ' • ${filter == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'}' : ''}${category != null ? ' • $category' : ''}${cycleOnly ? ' • Siklus' : ''}${dateRange != null ? ' • Rentang tanggal' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      resetHistoryFilters(ref);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: filter == null,
                  onTap: () {
                    ref.read(historyFilterProvider.notifier).setType(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pemasukan',
                  selected: filter == TransactionType.income,
                  color: theme.colorScheme.tertiary,
                  onTap: () {
                    ref
                        .read(historyFilterProvider.notifier)
                        .setType(TransactionType.income);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pengeluaran',
                  selected: filter == TransactionType.expense,
                  color: theme.colorScheme.error,
                  onTap: () {
                    ref
                        .read(historyFilterProvider.notifier)
                        .setType(TransactionType.expense);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            ref.watch(historySearchQueryProvider).isNotEmpty ||
                                    filter != null ||
                                    category != null ||
                                    cycleOnly
                                ? 'Tidak ada transaksi yang cocok'
                                : 'Belum ada transaksi',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ref.watch(historySearchQueryProvider).isNotEmpty ||
                                    filter != null ||
                                    category != null ||
                                    cycleOnly
                                ? 'Coba ubah filter atau kata kunci pencarianmu.'
                                : 'Semua transaksimu akan muncul di sini. '
                                      'Yuk mulai catat pengeluaran atau pemasukan!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final date = grouped.keys.elementAt(index);
                      final transactions = grouped[date]!;
                      final summary = dailySummary[date];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: summary == null
                                    ? null
                                    : () => _showDailyOverview(
                                        date,
                                        transactions,
                                        summary,
                                      ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    12,
                                    12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today_rounded,
                                          size: 17,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              date,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${transactions.length} transaksi  •  Ketuk untuk overview',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (summary != null)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (summary.income > 0)
                                              _SummaryAmount(
                                                text:
                                                    '+${formatRupiah(summary.income)}',
                                                color:
                                                    theme.colorScheme.tertiary,
                                              ),
                                            if (summary.expense > 0)
                                              _SummaryAmount(
                                                text:
                                                    '-${formatRupiah(summary.expense)}',
                                                color: theme.colorScheme.error,
                                              ),
                                          ],
                                        ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              ...transactions.map(
                                (t) => TransactionTile(
                                  transaction: t,
                                  onTap: () => _showTransactionOptions(t),
                                  onDismissed: () => _confirmDelete(t),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _scheduleApplyIntent(HistoryNavigationIntent intent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(historyNavigationIntentProvider) != intent) {
        return;
      }
      resetHistoryFilters(ref);
      if (intent.target == HistoryNavigationTarget.activeCycle) {
        ref.read(historyCycleProvider.notifier).toggle();
      } else if (intent.category != null) {
        ref.read(historyCategoryProvider.notifier).setCategory(intent.category);
        ref.read(historyCycleProvider.notifier).toggle();
      }
      ref.read(historyNavigationIntentProvider.notifier).consume();
    });
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.end,
          softWrap: false,
        ),
      ),
    );
  }
}

class _DailyOverviewSheet extends StatelessWidget {
  const _DailyOverviewSheet({
    required this.date,
    required this.transactions,
    required this.summary,
    required this.onTransactionTap,
    required this.onTransactionDismissed,
  });

  final String date;
  final List<TransactionEntity> transactions;
  final ({double income, double expense}) summary;
  final ValueChanged<TransactionEntity> onTransactionTap;
  final ValueChanged<TransactionEntity> onTransactionDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final net = summary.income - summary.expense;
    final netColor = net >= 0 ? colors.tertiary : colors.error;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Harian', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Pemasukan',
                          value: formatRupiah(summary.income),
                          color: colors.tertiary,
                          icon: Icons.south_west_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Pengeluaran',
                          value: formatRupiah(summary.expense),
                          color: colors.error,
                          icon: Icons.north_east_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: netColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selisih bersih',
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          '${net >= 0 ? '+' : '-'}${formatRupiah(net.abs())}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: netColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Daftar transaksi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: transactions.length,
                itemBuilder: (context, index) => TransactionTile(
                  transaction: transactions[index],
                  onTap: () => onTransactionTap(transactions[index]),
                  onDismissed: () =>
                      onTransactionDismissed(transactions[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? chipColor : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

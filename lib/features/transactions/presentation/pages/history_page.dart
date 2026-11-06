import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../shared/widgets/app_entrance.dart';
import '../../../../shared/widgets/amount_text.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/filter_sheet.dart';
import '../../../../shared/widgets/transaction_tile.dart' as shared;
import '../../../savings/data/providers/savings_goal_repository_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/dashboard_error_view.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/history_providers.dart';
import '../providers/quick_add_controller.dart';
import '../widgets/quick_add_transaction_sheet.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _openEdit(transaction);
        },
        onTransactionDismissed: _confirmDelete,
      ),
    );
  }

  void _confirmDelete(TransactionEntity transaction) async {
    String? goalTitle;
    if (transaction.isAllocation && transaction.goalId != null) {
      try {
        final savingsRepo = ref.read(savingsGoalRepositoryProvider);
        final goal = await savingsRepo.getGoalById(transaction.goalId!);
        goalTitle = goal.title;
      } catch (_) {
        goalTitle = null;
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

  FilterSelection _currentFilterSelection() {
    final range = ref.read(historyDateRangeProvider);
    final today = DateTime.now();
    final expected7DayStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final expected30DayStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 29));
    final period = range == null
        ? FilterPeriod.all
        : (range.start == expected7DayStart && range.lengthInDays == 7
              ? FilterPeriod.last7Days
              : range.start == expected30DayStart && range.lengthInDays == 30
              ? FilterPeriod.last30Days
              : FilterPeriod.custom);
    return FilterSelection(
      period: period,
      dateRange: range == null
          ? null
          : DateTimeRange(start: range.start, end: range.end),
      category: ref.read(historyCategoryProvider),
      activeCycleOnly: ref.read(historyCycleProvider),
    );
  }

  bool _hasSecondaryFilters({
    required String? category,
    required bool cycleOnly,
    required HistoryDateRange? dateRange,
  }) => category != null || cycleOnly || dateRange != null;

  Future<void> _openFilters(List<String> categories) async {
    final selection = await showFilterSheet(
      context,
      categories: categories,
      initial: _currentFilterSelection(),
    );
    if (!mounted || selection == null) return;

    ref.read(historyCategoryProvider.notifier).setCategory(selection.category);
    if (ref.read(historyCycleProvider) != selection.activeCycleOnly) {
      ref.read(historyCycleProvider.notifier).toggle();
    }

    final range = switch (selection.period) {
      FilterPeriod.all => null,
      FilterPeriod.last7Days => _presetRange(7),
      FilterPeriod.last30Days => _presetRange(30),
      FilterPeriod.custom => selection.dateRange,
    };
    if (range == null) {
      ref.read(historyDateRangeProvider.notifier).clear();
    } else {
      ref
          .read(historyDateRangeProvider.notifier)
          .setRange(range.start, range.end);
    }
  }

  DateTimeRange _presetRange(int days) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final start = todayStart.subtract(Duration(days: days - 1));
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  void _removeCategoryFilter() {
    ref.read(historyCategoryProvider.notifier).setCategory(null);
  }

  void _removeCycleFilter() {
    ref.read(historyCycleProvider.notifier).toggle();
  }

  void _removeDateFilter() {
    ref.read(historyDateRangeProvider.notifier).clear();
  }

  void _resetAllFilters() {
    resetHistoryFilters(ref);
    _searchController.clear();
    setState(() {});
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
    final allTransactionsAsync = ref.watch(transactionsStreamProvider);
    final grouped = ref.watch(filteredGroupedTransactionsProvider);
    final dailySummary = ref.watch(dailySummaryProvider);
    final filter = ref.watch(historyFilterProvider);
    final category = ref.watch(historyCategoryProvider);
    final cycleOnly = ref.watch(historyCycleProvider);
    final dateRange = ref.watch(historyDateRangeProvider);
    final categories = ref.watch(historyCategoriesProvider);
    final theme = Theme.of(context);
    final hasSecondaryFilters = _hasSecondaryFilters(
      category: category,
      cycleOnly: cycleOnly,
      dateRange: dateRange,
    );
    final hasAnyFilters = filter != null || hasSecondaryFilters;
    final sortedDays = grouped.entries.toList()
      ..sort((a, b) {
        final aDate = a.value
            .map((transaction) => transaction.date)
            .reduce((left, right) => left.isAfter(right) ? left : right);
        final bDate = b.value
            .map((transaction) => transaction.date)
            .reduce((left, right) => left.isAfter(right) ? left : right);
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: _searchVisible ? 'Tutup pencarian' : 'Cari transaksi',
            onPressed: () {
              setState(() => _searchVisible = !_searchVisible);
              if (!_searchVisible) {
                _searchController.clear();
                ref.read(historySearchQueryProvider.notifier).setQuery('');
              }
            },
            icon: Icon(
              _searchVisible ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Filter transaksi',
            onPressed: () => _openFilters(categories),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded),
                if (hasAnyFilters)
                  Positioned(
                    right: -2,
                    top: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
      body: AppEntrance(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                if (_searchVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.xxs,
                      AppSpacing.screen,
                      AppSpacing.xs,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        ref
                            .read(historySearchQueryProvider.notifier)
                            .setQuery(value);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(historySearchQueryProvider.notifier)
                                      .setQuery('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: SegmentedButton<TransactionType?>(
                    key: const ValueKey('history-type-filter'),
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<TransactionType?>(
                        value: null,
                        label: Text('Semua'),
                      ),
                      ButtonSegment<TransactionType?>(
                        value: TransactionType.income,
                        label: Text('Pemasukan'),
                      ),
                      ButtonSegment<TransactionType?>(
                        value: TransactionType.expense,
                        label: Text('Pengeluaran'),
                      ),
                    ],
                    selected: {filter},
                    onSelectionChanged: (selection) => ref
                        .read(historyFilterProvider.notifier)
                        .setType(selection.first),
                  ),
                ),
                if (hasAnyFilters)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screen,
                      ),
                      children: [
                        if (filter != null)
                          _ActiveFilterChip(
                            label: filter == TransactionType.income
                                ? 'Pemasukan'
                                : 'Pengeluaran',
                            onDeleted: () => ref
                                .read(historyFilterProvider.notifier)
                                .setType(null),
                          ),
                        if (category != null)
                          _ActiveFilterChip(
                            label: category,
                            onDeleted: _removeCategoryFilter,
                          ),
                        if (cycleOnly)
                          _ActiveFilterChip(
                            label: 'Siklus aktif',
                            onDeleted: _removeCycleFilter,
                          ),
                        if (dateRange != null)
                          _ActiveFilterChip(
                            label:
                                '${formatDateShort(dateRange.start)} – ${formatDateShort(dateRange.end)}',
                            onDeleted: _removeDateFilter,
                          ),
                        TextButton(
                          onPressed: _resetAllFilters,
                          child: const Text('Reset semua'),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child:
                      allTransactionsAsync.hasError
                      ? DashboardErrorView(
                          onRetry: () =>
                              ref.invalidate(transactionsStreamProvider),
                        )
                      : allTransactionsAsync.isLoading &&
                            allTransactionsAsync.value == null
                      ? const Center(child: CircularProgressIndicator())
                      : grouped.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title:
                              hasAnyFilters ||
                                  ref
                                      .watch(historySearchQueryProvider)
                                      .isNotEmpty
                              ? 'Tidak ada transaksi yang cocok'
                              : 'Belum ada transaksi',
                          message:
                              hasAnyFilters ||
                                  ref
                                      .watch(historySearchQueryProvider)
                                      .isNotEmpty
                              ? 'Coba ubah filter atau kata kunci pencarianmu.'
                              : 'Transaksimu akan muncul di sini. Ketuk tombol + '
                                    'di kanan bawah untuk mencatat transaksi.',
                          compact: true,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen,
                            AppSpacing.xs,
                            AppSpacing.screen,
                            104,
                          ),
                          itemCount: sortedDays.length,
                          itemBuilder: (context, index) {
                            final entry = sortedDays[index];
                            final date = entry.key;
                            final transactions = entry.value;
                            final summary = dailySummary[date];

                            return Column(
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
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                date,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${transactions.length} transaksi · Ketuk untuk ringkasan',
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
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
                                              _SummaryAmount(
                                                amount:
                                                    summary.income -
                                                    summary.expense,
                                              ),
                                            ],
                                          ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  indent: 52,
                                  color: context.appColors.outline,
                                ),
                                ...transactions.map(
                                  (t) => shared.TransactionTile(
                                    category: t.category,
                                    amount: t.amount,
                                    isExpense: t.isExpense,
                                    note: t.note,
                                    timeLabel: _formatTime(t.date),
                                    onTap: () => _openEdit(t),
                                    onDismissed: () => _confirmDelete(t),
                                    dismissKey: t.id,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEdit(TransactionEntity transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => QuickAddTransactionSheet(transaction: transaction),
    );
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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
  const _SummaryAmount({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: AmountText(
          amount: amount,
          tone: amount >= 0 ? AmountTone.income : AmountTone.expense,
          showSign: true,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.end,
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                itemCount: transactions.length,
                itemBuilder: (context, index) => shared.TransactionTile(
                  category: transactions[index].category,
                  amount: transactions[index].amount,
                  isExpense: transactions[index].isExpense,
                  note: transactions[index].note,
                  timeLabel:
                      '${transactions[index].date.hour.toString().padLeft(2, '0')}:${transactions[index].date.minute.toString().padLeft(2, '0')}',
                  onTap: () => onTransactionTap(transactions[index]),
                  onDismissed: () =>
                      onTransactionDismissed(transactions[index]),
                  dismissKey: transactions[index].id,
                  padding: EdgeInsets.zero,
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: InputChip(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        onDeleted: onDeleted,
        deleteButtonTooltipMessage: 'Hapus filter $label',
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/history_providers.dart';
import '../../domain/entities/budget_overview_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/category_expense_pie_card.dart';
import '../widgets/dashboard_empty_state.dart';
import '../widgets/financial_insight_card.dart';
import '../widgets/financial_insight_overview_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final storedUserName = ref.watch(userNameProvider);
    final authUser = ref.watch(currentUserProvider);
    final userName = _resolveDisplayName(storedUserName, authUser);

    void openAddSheet() => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickAddTransactionSheet(),
    );

    return Scaffold(
      body: summaryAsync.when(
        loading: () => _DashboardSkeleton(userName: userName),
        error: (_, __) => _DashboardErrorView(
          onRetry: () => ref.invalidate(transactionsStreamProvider),
        ),
        data: (summary) {
          final isEmpty = transactionsAsync.value?.isEmpty ?? false;
          return CustomScrollView(
            slivers: [
              _DashboardHeader(userName: userName),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.list(
                  children: [
                    if (isEmpty) ...[
                      DashboardEmptyState(
                        userName: userName,
                        onAdd: openAddSheet,
                      ),
                    ] else ...[
                      _BalanceHeroCard(
                        summary: summary,
                        transactions: transactionsAsync.value ?? const [],
                      ),
                      const SizedBox(height: 12),
                      _BudgetStatusSection(summary: summary),
                      const SizedBox(height: 12),
                      ref
                          .watch(financialInsightProvider)
                          .when(
                            loading: () => const _SectionSkeleton(height: 130),
                            error: (_, __) => _DashboardSectionError(
                              label: 'Insight keuangan tidak tersedia',
                              onRetry: () =>
                                  ref.invalidate(financialInsightProvider),
                            ),
                            data: (insight) => FinancialInsightCard(
                              insight: insight,
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => FinancialInsightOverviewSheet(
                                  insight: insight,
                                  transactions:
                                      transactionsAsync.value ?? const [],
                                  cycleDay: ref.read(budgetCycleDateProvider),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      const CategoryExpensePieCard(),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _resolveDisplayName(String storedName, User? user) {
  final cleanStoredName = storedName.trim();
  if (cleanStoredName.isNotEmpty) return cleanStoredName;
  // Fallback lama untuk data sebelum ada pengaturan nama; sekarang default di
  // SettingsService sudah "Pengguna", jadi ini hanya untuk migrasi.
  if (user != null && !user.isAnonymous) {
    final googleName = user.displayName?.trim() ?? '';
    if (googleName.isNotEmpty) return googleName;
    final emailName = user.email?.split('@').first.trim() ?? '';
    if (emailName.isNotEmpty) return emailName;
  }
  return 'Pengguna';
}

// ─────────────────────────────────────────────────────────────
// App Bar (SliverAppBar with greeting)
// ─────────────────────────────────────────────────────────────

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final greeting = _greeting();
    final displayName = userName.trim().isEmpty
        ? 'Kamu'
        : userName.trim().split(' ').first;
    final user = ref.watch(currentUserProvider);
    final isGuest = user?.isAnonymous ?? true;

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau arus uang dan targetmu hari ini.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isGuest)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: .4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tamu',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Selamat malam';
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

// ─────────────────────────────────────────────────────────────
// Balance Hero Card
// ─────────────────────────────────────────────────────────────

class _BalanceHeroCard extends ConsumerWidget {
  const _BalanceHeroCard({required this.summary, required this.transactions});

  final MonthlySummaryEntity summary;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPrivacy = ref.watch(privacyModeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = summary.balance >= 0;

    // Semantic colors from the theme (no hard-coded shade values).
    final incomeColor = colors.tertiary;
    final expenseColor = colors.error;
    final balanceColor = isPositive ? colors.primary : colors.error;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () => _showBalanceOverview(context, isPrivacy),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : null,
            gradient: isDark
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primaryContainer,
                      colors.secondaryContainer.withValues(alpha: 0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? colors.outlineVariant
                  : colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: label + privacy toggle
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saldo Siklus Ini',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _PrivacyToggle(
                      isPrivacy: isPrivacy,
                      colors: colors,
                      ref: ref,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Balance amount
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(isPrivacy),
                      isPrivacy ? 'Rp •••••••' : formatRupiah(summary.balance),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isPrivacy
                            ? colors.onSurfaceVariant
                            : balanceColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Income / Expense tiles
                Row(
                  children: [
                    Expanded(
                      child: _FlowTile(
                        icon: Icons.south_west_rounded,
                        label: 'Pemasukan',
                        amount: isPrivacy
                            ? 'Rp •••'
                            : formatRupiah(summary.totalIncome),
                        color: incomeColor,
                        isPrivacy: isPrivacy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FlowTile(
                        icon: Icons.north_east_rounded,
                        label: 'Pengeluaran',
                        amount: isPrivacy
                            ? 'Rp •••'
                            : formatRupiah(summary.totalExpense),
                        color: expenseColor,
                        isPrivacy: isPrivacy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBalanceOverview(BuildContext context, bool isPrivacy) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BalanceOverviewSheet(
        summary: summary,
        transactions: transactions,
        isPrivacy: isPrivacy,
      ),
    );
  }
}

class _BalanceOverviewSheet extends StatelessWidget {
  const _BalanceOverviewSheet({
    required this.summary,
    required this.transactions,
    required this.isPrivacy,
  });

  final MonthlySummaryEntity summary;
  final List<TransactionEntity> transactions;
  final bool isPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visibleTransactions = transactions
        .where((transaction) => !transaction.isAllocation)
        .toList();
    final largestExpense = visibleTransactions
        .where((transaction) => transaction.isExpense)
        .fold<TransactionEntity?>(
          null,
          (largest, transaction) =>
              largest == null || transaction.amount > largest.amount
              ? transaction
              : largest,
        );
    String amount(double value) =>
        isPrivacy ? 'Rp •••••••' : formatRupiah(value);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan saldo', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Siklus anggaran berjalan',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? colors.surface
                      : colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: theme.brightness == Brightness.dark
                      ? Border.all(color: colors.outlineVariant)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo bersih',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount(summary.balance),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: summary.balance >= 0
                            ? colors.primary
                            : colors.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BalanceOverviewMetric(
                      label: 'Pemasukan',
                      value: amount(summary.totalIncome),
                      icon: Icons.south_west_rounded,
                      color: colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BalanceOverviewMetric(
                      label: 'Pengeluaran',
                      value: amount(summary.totalExpense),
                      icon: Icons.north_east_rounded,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _BalanceOverviewMetric(
                label: 'Transaksi tercatat',
                value: '${summary.transactionCount} transaksi',
                icon: Icons.receipt_long_outlined,
                color: colors.primary,
                wide: true,
              ),
              if (largestExpense != null) ...[
                const SizedBox(height: 18),
                Text(
                  'Pengeluaran terbesar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.errorContainer,
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: colors.onErrorContainer,
                    ),
                  ),
                  title: Text(largestExpense.category),
                  subtitle: Text(
                    largestExpense.note.isEmpty
                        ? 'Transaksi terbesar pada siklus ini'
                        : largestExpense.note,
                  ),
                  trailing: Text(
                    amount(largestExpense.amount),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup ringkasan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceOverviewMetric extends StatelessWidget {
  const _BalanceOverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
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

class _PrivacyToggle extends StatelessWidget {
  const _PrivacyToggle({
    required this.isPrivacy,
    required this.colors,
    required this.ref,
  });
  final bool isPrivacy;
  final ColorScheme colors;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(privacyModeProvider.notifier).toggle(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              key: ValueKey(isPrivacy),
              isPrivacy
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  const _FlowTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isPrivacy,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final bool isPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isPrivacy ? colors.onSurfaceVariant : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Budget Status Section
// ─────────────────────────────────────────────────────────────

class _BudgetStatusSection extends ConsumerWidget {
  const _BudgetStatusSection({required this.summary});

  final MonthlySummaryEntity summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status Anggaran',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showBudgetInfo(context),
                    tooltip: 'Apa itu status anggaran?',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (budgetLimit == null || budgetLimit <= 0)
              _NoBudgetMessage(colors: colors, theme: theme)
            else
              _BudgetAlertContent(
                onOpenOverview: (overview) =>
                    _showBudgetOverview(context, overview, ref),
              ),
          ],
        ),
      ),
    );
  }

  void _showBudgetInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _BudgetInfoSheet(),
    );
  }

  void _showBudgetOverview(
    BuildContext context,
    BudgetOverviewEntity overview,
    WidgetRef ref,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BudgetOverviewSheet(
        overview: overview,
        onOpenHistory: (target) {
          final navigator = Navigator.of(context);
          if (target == null) {
            ref
                .read(historyNavigationIntentProvider.notifier)
                .openActiveCycle();
          } else {
            ref
                .read(historyNavigationIntentProvider.notifier)
                .openCategoryInActiveCycle(target);
          }
          navigator.pop();
        },
      ),
    );
  }
}

class _BudgetInfoSheet extends StatelessWidget {
  const _BudgetInfoSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tentang Status Anggaran', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Lampu lalu lintas untuk pengeluaranmu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status ini membandingkan total pengeluaran dalam siklus aktif dengan batas anggaran yang kamu atur. Gunakan sebagai pengingat sebelum pengeluaran mulai berlebihan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            const _BudgetInfoLevel(
              icon: Icons.check_circle_outline_rounded,
              title: 'Aman',
              description: 'Pengeluaran masih di bawah 80% anggaran.',
            ),
            const SizedBox(height: 10),
            const _BudgetInfoLevel(
              icon: Icons.warning_amber_rounded,
              title: 'Perlu diperhatikan',
              description: 'Pengeluaran sudah mencapai 80% atau lebih.',
            ),
            const SizedBox(height: 10),
            const _BudgetInfoLevel(
              icon: Icons.error_outline_rounded,
              title: 'Terlampaui',
              description: 'Total pengeluaran sudah melewati batas anggaran.',
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? colors.surface
                    : colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: theme.brightness == Brightness.dark
                    ? Border.all(color: colors.outlineVariant)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tips: catat semua pengeluaran kecil. Pengeluaran kecil yang sering dilakukan bisa menjadi penyebab “bocor halus”.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetInfoLevel extends StatelessWidget {
  const _BudgetInfoLevel({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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

class _NoBudgetMessage extends StatelessWidget {
  const _NoBudgetMessage({required this.colors, required this.theme});
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Atur batas anggaran di Pengaturan untuk mulai memantau pengeluaran.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetAlertContent extends ConsumerWidget {
  const _BudgetAlertContent({required this.onOpenOverview});

  final ValueChanged<BudgetOverviewEntity> onOpenOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return overviewAsync.when(
      loading: () => const _SectionSkeleton(height: 80),
      error: (_, __) => Text(
        'Detail anggaran tidak tersedia.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      data: (overview) =>
          _BudgetAlertBody(overview: overview, onOpenOverview: onOpenOverview),
    );
  }
}

class _BudgetAlertBody extends StatelessWidget {
  const _BudgetAlertBody({
    required this.overview,
    required this.onOpenOverview,
  });

  final BudgetOverviewEntity overview;
  final ValueChanged<BudgetOverviewEntity> onOpenOverview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Use semantic theme colors instead of hard-coded shades.
    final statusColor = overview.isExceeded
        ? colors.error
        : overview.isWarning
        ? colors.tertiary
        : colors.primary;

    final statusLabel = overview.isExceeded
        ? 'Anggaran terlampaui'
        : overview.isWarning
        ? 'Perlu diperhatikan'
        : 'Pengeluaran terkendali';

    final statusIcon = overview.isExceeded
        ? Icons.error_outline_rounded
        : overview.isWarning
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return InkWell(
      onTap: () => onOpenOverview(overview),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(overview.spentRatio * 100).round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: overview.spentRatio.clamp(0.0, 1.0),
              minHeight: 10,
              color: statusColor,
              backgroundColor: statusColor.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 10),
          // Amount row
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatRupiah(overview.totalExpense)} dari ${formatRupiah(overview.budgetLimit)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  overview.isExceeded
                      ? 'Lebih ${formatRupiah(overview.remaining.abs())}'
                      : 'Sisa ${formatRupiah(overview.remaining)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Period + tap hint
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${formatDateShort(overview.periodStart)} – ${formatDateShort(overview.periodEnd)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.touch_app_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Detail',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Budget Overview Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _BudgetOverviewSheet extends StatelessWidget {
  const _BudgetOverviewSheet({
    required this.overview,
    required this.onOpenHistory,
  });

  final BudgetOverviewEntity overview;
  final ValueChanged<String?>? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = overview.isExceeded
        ? colors.error
        : overview.isWarning
        ? colors.tertiary
        : colors.primary;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview Anggaran', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${formatDateShort(overview.periodStart)} – ${formatDateShort(overview.periodEnd)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Gradient status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.68)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.isExceeded ? 'Melebihi batas' : 'Sisa anggaran',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRupiah(overview.remaining.abs()),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overview.spentRatio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(overview.spentRatio * 100).round()}% digunakan dari ${formatRupiah(overview.budgetLimit)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Metrics row
              Row(
                children: [
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Transaksi',
                      value: '${overview.transactionCount}',
                      icon: Icons.receipt_long_outlined,
                      onTap: onOpenHistory == null
                          ? null
                          : () => onOpenHistory!(null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Rata-rata / hari',
                      value: formatRupiah(overview.averageDailyExpense),
                      icon: Icons.show_chart_rounded,
                      onTap: () => _showMetricDetail(
                        context,
                        title: 'Rata-rata pengeluaran harian',
                        message:
                            'Angka ini dihitung dari total pengeluaran yang sudah terjadi dibagi jumlah hari yang telah berjalan pada siklus ini.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _BudgetMetric(
                label: 'Estimasi akhir periode',
                value: formatRupiah(overview.projectedExpense),
                icon: Icons.insights_rounded,
                wide: true,
                onTap: () => _showMetricDetail(
                  context,
                  title: 'Estimasi akhir periode',
                  message:
                      'Proyeksi ini menggunakan rata-rata pengeluaran harian saat ini untuk memperkirakan total pengeluaran sampai akhir siklus.',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kategori terbesar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (overview.topCategories.isEmpty)
                Text(
                  'Belum ada pengeluaran pada periode ini.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...overview.topCategories.asMap().entries.map((entry) {
                  final item = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: onOpenHistory == null
                        ? null
                        : () => onOpenHistory!(item.category),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(
                      item.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Text(
                      formatRupiah(item.amount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Tutup'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMetricDetail(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onAction != null)
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel ?? 'Lihat detail'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.wide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final content = Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
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

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading Skeleton
// ─────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 130, height: 18, colors: colors),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 180, height: 30, colors: colors),
                  const SizedBox(height: 7),
                  _SkeletonBox(width: 220, height: 12, colors: colors),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.list(
            children: [
              _SkeletonBox(
                width: double.infinity,
                height: 160,
                radius: 28,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _SkeletonBox(
                width: double.infinity,
                height: 120,
                radius: 24,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _SkeletonBox(
                width: double.infinity,
                height: 130,
                radius: 24,
                colors: colors,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _SkeletonBox(
      width: double.infinity,
      height: height,
      radius: 24,
      colors: colors,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.colors,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error Views
// ─────────────────────────────────────────────────────────────

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data keuangan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internetmu lalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionError extends StatelessWidget {
  const _DashboardSectionError({required this.label, required this.onRetry});

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.cloud_off_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(label),
        trailing: IconButton(
          tooltip: 'Coba lagi',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}

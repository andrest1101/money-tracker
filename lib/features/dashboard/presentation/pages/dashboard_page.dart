import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/navigation/navigation_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../settings/presentation/widgets/profile_avatar_sheet.dart';
import '../../../../shared/widgets/app_entrance.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/history_providers.dart';
import '../../../transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/budget_status_section.dart';
import '../widgets/category_expense_section.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/financial_insight_overview_sheet.dart';
import '../widgets/financial_insight_section.dart';
import '../widgets/recent_transactions_section.dart';

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

    void openEditSheet(TransactionEntity transaction) =>
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => QuickAddTransactionSheet(transaction: transaction),
        );

    void openHistory() {
      resetHistoryFilters(ref);
      ref.read(shellTabIndexProvider.notifier).select(ShellTabIndex.history);
    }

    final body = summaryAsync.when(
      loading: () => const DashboardSkeleton(),
      error: (_, __) => DashboardErrorView(
        onRetry: () => ref.invalidate(transactionsStreamProvider),
      ),
      data: (summary) {
        final transactions = (transactionsAsync.value ?? const [])
            .where((transaction) => !transaction.isAllocation)
            .toList(growable: false);

        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.md,
                  AppSpacing.screen,
                  104,
                ),
                children: [
                  DashboardHeader(userName: userName),
                  const SizedBox(height: AppSpacing.lg),
                  BalanceHeroCard(summary: summary, transactions: transactions),
                  const SizedBox(height: AppSpacing.section),
                  const BudgetStatusSection(),
                  const SizedBox(height: AppSpacing.section),
                  CategoryExpenseSection(onAddExpense: openAddSheet),
                  const SizedBox(height: AppSpacing.section),
                  _insightBlock(context, ref, transactions),
                  const SizedBox(height: AppSpacing.section),
                  RecentTransactionsSection(
                    transactions: transactions,
                    onSeeAll: openHistory,
                    onTransactionTap: openEditSheet,
                    onAddTransaction: openAddSheet,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(body: AppEntrance(child: body));
  }

  Widget _insightBlock(
    BuildContext context,
    WidgetRef ref,
    List<TransactionEntity> transactions,
  ) {
    return ref
        .watch(financialInsightProvider)
        .when(
          loading: () => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Insight keuangan'),
              SizedBox(height: AppSpacing.xxs),
              SectionSkeleton(height: 96),
            ],
          ),
          error: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Insight keuangan'),
              const SizedBox(height: AppSpacing.xxs),
              DashboardSectionError(
                label: 'Insight keuangan tidak tersedia',
                onRetry: () => ref.invalidate(financialInsightProvider),
              ),
            ],
          ),
          data: (insight) => FinancialInsightSection(
            insight: insight,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => FinancialInsightOverviewSheet(
                insight: insight,
                transactions: transactions,
                cycleDay: ref.read(budgetCycleDateProvider),
              ),
            ),
          ),
        );
  }
}

String _resolveDisplayName(String storedName, User? user) {
  final cleanStoredName = storedName.trim();
  if (cleanStoredName.isNotEmpty && cleanStoredName != 'Pengguna') {
    return cleanStoredName;
  }
  if (user != null && !user.isAnonymous) {
    final googleName = user.displayName?.trim() ?? '';
    if (googleName.isNotEmpty) return googleName;
    final emailName = user.email?.split('@').first.trim() ?? '';
    if (emailName.isNotEmpty) return emailName;
  }
  return user?.isAnonymous ?? true ? 'Tamu' : 'Pengguna';
}

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final greeting = _greeting();
    final displayName = userName.trim().isEmpty
        ? 'Kamu'
        : userName.trim().split(' ').first;
    final avatar = presetAvatarFor(ref.watch(profileAvatarProvider));
    final avatarIconColor = avatar.color.computeLuminance() > .5
        ? AppColors.light.textPrimary
        : AppColors.light.surface;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Semantics(
          button: true,
          label: 'Ubah foto profil',
          child: Material(
            color: avatar.color,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ProfileAvatarSheet.show(context),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(avatar.icon, color: avatarIconColor, size: 19),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Semantics(
          button: true,
          label: 'Notifikasi',
          child: Material(
            color: colors.surfaceVariant,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Belum ada notifikasi baru')),
              ),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.notifications_none_rounded, size: 21),
              ),
            ),
          ),
        ),
      ],
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

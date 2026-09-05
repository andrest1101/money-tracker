import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../../transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../../../settings/presentation/widgets/profile_avatar_sheet.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/budget_status_section.dart';
import '../widgets/category_expense_pie_card.dart';
import '../widgets/dashboard_empty_state.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_skeleton.dart';
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
        loading: () => DashboardSkeleton(userName: userName),
        error: (_, __) => DashboardErrorView(
          onRetry: () => ref.invalidate(transactionsStreamProvider),
        ),
        data: (summary) {
          final isEmpty = transactionsAsync.value?.isEmpty ?? false;
          return CustomScrollView(
            slivers: [
              DashboardHeader(userName: userName),
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
                      BalanceHeroCard(
                        summary: summary,
                        transactions: transactionsAsync.value ?? const [],
                      ),
                      const SizedBox(height: 12),
                      BudgetStatusSection(summary: summary),
                      const SizedBox(height: 12),
                      ref
                          .watch(financialInsightProvider)
                          .when(
                            loading: () => const SectionSkeleton(height: 130),
                            error: (_, __) => DashboardSectionError(
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
  if (user != null && !user.isAnonymous) {
    final googleName = user.displayName?.trim() ?? '';
    if (googleName.isNotEmpty) return googleName;
    final emailName = user.email?.split('@').first.trim() ?? '';
    if (emailName.isNotEmpty) return emailName;
  }
  return 'Pengguna';
}

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.userName});

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
    final avatar = presetAvatarFor(ref.watch(profileAvatarProvider));

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: avatar.color,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => ProfileAvatarSheet.show(context),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: avatar.color,
                      child: Icon(avatar.icon, color: Colors.white, size: 25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isGuest) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tamu',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.45,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Notifikasi',
                child: Material(
                  color: colors.surfaceContainerHigh,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Belum ada notifikasi baru'),
                      ),
                    ),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.notifications_none_rounded, size: 21),
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Selamat malam';
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

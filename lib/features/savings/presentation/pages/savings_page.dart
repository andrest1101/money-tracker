import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_providers.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/allocate_fund_sheet.dart';
import '../widgets/goal_card.dart';
import '../widgets/savings_overview.dart';

class SavingsPage extends ConsumerStatefulWidget {
  const SavingsPage({super.key});

  @override
  ConsumerState<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends ConsumerState<SavingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddGoalSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddGoalSheet(),
    );
  }

  void _showAllocateSheet(SavingsGoalEntity goal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AllocateFundSheet(goal: goal),
    );
  }

  Future<void> _confirmDeleteGoal(SavingsGoalEntity goal) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_forever_rounded,
          color: theme.colorScheme.error,
          size: 44,
        ),
        title: const Text('Hapus Target?'),
        content: Text(
          '"${goal.title}" beserta semua riwayat alokasinya akan dihapus permanen. '
          'Dana yang sudah dialokasikan (${formatRupiah(goal.currentAmount)}) '
          'akan dikembalikan ke saldo utama.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .deleteGoal(goal);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      messenger.showSnackBar(
        SnackBar(content: Text('"${goal.title}" berhasil dihapus.')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus target. Coba lagi ya.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sortOption = ref.watch(savingsSortControllerProvider);
    final activeAsync = ref.watch(activeGoalsProvider);
    final completedAsync = ref.watch(completedGoalsProvider);

    final activeCount = activeAsync.value?.length ?? 0;
    final completedCount = completedAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tabungan'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_rounded, size: 18),
                  const SizedBox(width: 6),
                  const Text('Aktif'),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 6),
                    _TabBadge(count: activeCount, color: cs.primary),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 18),
                  const SizedBox(width: 6),
                  const Text('Selesai'),
                  if (completedCount > 0) ...[
                    const SizedBox(width: 6),
                    _TabBadge(count: completedCount, color: cs.tertiary),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Target Baru'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: SavingsOverview(
              activeCount: activeCount,
              completedCount: completedCount,
            ),
          ),
          // Sort filter chips
          _SortFilterRow(currentSort: sortOption),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Aktif
                _GoalListView(
                  goalsAsync: activeAsync,
                  emptyIcon: Icons.savings_outlined,
                  emptyTitle: 'Belum ada target aktif',
                  emptySubtitle:
                      'Tap "Target Baru" untuk mulai menabung\nuntuk impianmu!',
                  onAllocate: _showAllocateSheet,
                  onDelete: _confirmDeleteGoal,
                ),
                // Tab 2: Selesai
                _GoalListView(
                  goalsAsync: completedAsync,
                  emptyIcon: Icons.emoji_events_outlined,
                  emptyTitle: 'Belum ada target selesai',
                  emptySubtitle:
                      'Target yang sudah mencapai 100% akan muncul di sini.',
                  onAllocate: _showAllocateSheet,
                  onDelete: _confirmDeleteGoal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sort filter chips row ──────────────────────────────────────────────────

class _SortFilterRow extends ConsumerWidget {
  const _SortFilterRow({required this.currentSort});

  final SavingsSortOption currentSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'Urutkan:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SortChip(
                    label: 'Terbaru',
                    icon: Icons.fiber_new_rounded,
                    selected: currentSort == SavingsSortOption.newest,
                    onTap: () => ref
                        .read(savingsSortControllerProvider.notifier)
                        .setSortOption(SavingsSortOption.newest),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Terlama',
                    icon: Icons.history_rounded,
                    selected: currentSort == SavingsSortOption.oldest,
                    onTap: () => ref
                        .read(savingsSortControllerProvider.notifier)
                        .setSortOption(SavingsSortOption.oldest),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Progress',
                    icon: Icons.bar_chart_rounded,
                    selected: currentSort == SavingsSortOption.progress,
                    onTap: () => ref
                        .read(savingsSortControllerProvider.notifier)
                        .setSortOption(SavingsSortOption.progress),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.45)
                : cs.outlineVariant.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? color : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab badge ──────────────────────────────────────────────────────────────

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ── Goal list view (shared between tabs) ──────────────────────────────────

class _GoalListView extends ConsumerWidget {
  const _GoalListView({
    required this.goalsAsync,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onAllocate,
    required this.onDelete,
  });

  final AsyncValue<List<SavingsGoalEntity>> goalsAsync;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(SavingsGoalEntity) onAllocate;
  final void Function(SavingsGoalEntity) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return goalsAsync.when(
      loading: () => const _GoalListSkeleton(),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 64, color: cs.error),
              const SizedBox(height: 16),
              Text('Gagal memuat data', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Periksa koneksi internetmu lalu coba lagi.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(savingsGoalsStreamProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (goals) {
        if (goals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      emptyIcon,
                      size: 52,
                      color: cs.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    emptyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: goals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => GoalCard(
            goal: goals[index],
            onAllocate: () => onAllocate(goals[index]),
            onDelete: () => onDelete(goals[index]),
          ),
        );
      },
    );
  }
}

class _GoalListSkeleton extends StatelessWidget {
  const _GoalListSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 210,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

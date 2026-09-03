import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_providers.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/allocate_fund_sheet.dart';
import '../widgets/goal_card.dart';

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
      showDragHandle: true,
      builder: (_) => const AddGoalSheet(),
    );
  }

  void _showAllocateSheet(SavingsGoalEntity goal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
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
          '${goal.isCompleted ? 'Riwayat alokasi tetap dicatat sebagai transaksi historis agar saldo tidak berubah.' : 'Dana yang sudah dialokasikan (${formatRupiah(goal.currentAmount)}) akan dikembalikan ke saldo utama.'}',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
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

  Future<void> _toggleArchive(SavingsGoalEntity goal) async {
    final value = !goal.isArchived;
    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .setArchived(goal, value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (value
                    ? 'Target dipindahkan ke arsip.'
                    : 'Target dikembalikan dari arsip.')
              : 'Arsip target gagal diperbarui.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sortOption = ref.watch(savingsSortControllerProvider);
    final activeAsync = ref.watch(activeGoalsProvider);
    final completedAsync = ref.watch(completedGoalsProvider);
    final archivedMode = ref.watch(archivedModeProvider);
    final archivedActiveAsync = ref.watch(archivedActiveGoalsProvider);
    final archivedCompletedAsync = ref.watch(archivedCompletedGoalsProvider);

    final activeList = archivedMode ? archivedActiveAsync : activeAsync;
    final completedList = archivedMode
        ? archivedCompletedAsync
        : completedAsync;
    final activeCount = activeList.value?.length ?? 0;
    final completedCount = completedList.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(archivedMode ? 'Target Diarsipkan' : 'Target Tabungan'),
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
          // Sort filter chips
          _SortFilterRow(currentSort: sortOption),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: _ArchiveButton(
                selected: archivedMode,
                onPressed: () =>
                    ref.read(archivedModeProvider.notifier).toggle(),
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Aktif
                _GoalListView(
                  goalsAsync: activeList,
                  emptyIcon: Icons.savings_outlined,
                  emptyTitle: archivedMode
                      ? 'Belum ada target aktif di arsip'
                      : 'Belum ada target aktif',
                  emptySubtitle: archivedMode
                      ? 'Target aktif yang kamu arsipkan akan muncul di sini.'
                      : 'Tap "Target Baru" untuk mulai menabung\nuntuk impianmu!',
                  onAllocate: _showAllocateSheet,
                  onDelete: _confirmDeleteGoal,
                  onArchive: (goal) => _toggleArchive(goal),
                ),
                // Tab 2: Selesai
                _GoalListView(
                  goalsAsync: completedList,
                  emptyIcon: Icons.emoji_events_outlined,
                  emptyTitle: archivedMode
                      ? 'Belum ada target selesai di arsip'
                      : 'Belum ada target selesai',
                  emptySubtitle: archivedMode
                      ? 'Target selesai yang kamu arsipkan akan muncul di sini.'
                      : 'Target yang sudah mencapai 100% akan muncul di sini.',
                  onAllocate: _showAllocateSheet,
                  onDelete: _confirmDeleteGoal,
                  onArchive: (goal) => _toggleArchive(goal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortFilterRow extends ConsumerWidget {
  const _SortFilterRow({required this.currentSort});

  final SavingsSortOption currentSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 17, color: colors.onSurfaceVariant),
          const SizedBox(width: 7),
          Text(
            'Urutkan',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(width: 8),
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
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: .12)
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: .5)
                : colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveButton extends StatelessWidget {
  const _ArchiveButton({required this.selected, required this.onPressed});

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        selected ? Icons.inventory_2_rounded : Icons.archive_outlined,
        size: 17,
      ),
      label: Text(selected ? 'Kembali' : 'Diarsipkan'),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? colors.primary : colors.onSurfaceVariant,
        backgroundColor: isDark
            ? colors.surfaceContainerHigh
            : (selected
                  ? colors.primaryContainer
                  : colors.surfaceContainerHigh),
        side: BorderSide(
          color: selected
              ? colors.primary.withValues(alpha: .55)
              : colors.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    required this.onArchive,
  });

  final AsyncValue<List<SavingsGoalEntity>> goalsAsync;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(SavingsGoalEntity) onAllocate;
  final void Function(SavingsGoalEntity) onDelete;
  final void Function(SavingsGoalEntity) onArchive;

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
            onArchive: () => onArchive(goals[index]),
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
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

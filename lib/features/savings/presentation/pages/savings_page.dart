import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_entrance.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_providers.dart';
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

  String _sortLabel(SavingsSortOption option) => switch (option) {
    SavingsSortOption.newest => 'Terbaru',
    SavingsSortOption.oldest => 'Terlama',
    SavingsSortOption.progress => 'Progres tertinggi',
  };

  Future<void> _showSortOptions(SavingsSortOption currentSort) async {
    final selection = await showModalBottomSheet<SavingsSortOption>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urutkan target',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pilih urutan yang paling membantu kamu.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final option in SavingsSortOption.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    currentSort == option
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: currentSort == option
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(_sortLabel(option)),
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (selection == null || !mounted) return;
    try {
      await ref
          .read(savingsSortControllerProvider.notifier)
          .setSortOption(selection);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Urutan target gagal disimpan.'),
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
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opsi target',
            onSelected: (action) {
              switch (action) {
                case 'sort':
                  _showSortOptions(sortOption);
                case 'archive':
                  ref.read(archivedModeProvider.notifier).toggle();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    archivedMode
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  title: Text(archivedMode ? 'Target aktif' : 'Diarsipkan'),
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sort_rounded),
                  title: const Text('Urutkan'),
                  subtitle: Text(_sortLabel(sortOption)),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aktif'),
                  if (activeCount > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _TabBadge(count: activeCount, color: cs.primary),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Selesai'),
                  if (completedCount > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _TabBadge(
                      count: completedCount,
                      color: context.appColors.success,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: AppEntrance(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxContentWidth,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _GoalListView(
                        goalsAsync: activeList,
                        emptyIcon: Icons.savings_outlined,
                        emptyTitle: archivedMode
                            ? 'Belum ada target aktif di arsip'
                            : 'Belum ada target aktif',
                        emptySubtitle: archivedMode
                            ? 'Target aktif yang kamu arsipkan akan muncul di sini.'
                            : 'Ketuk tombol + di bawah untuk mulai menabung bagi impianmu.',
                        onAllocate: _showAllocateSheet,
                        onDelete: _confirmDeleteGoal,
                        onArchive: _toggleArchive,
                      ),
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
                        onArchive: _toggleArchive,
                      ),
                    ],
                  ),
                ),
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
          height: 1.2,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptySubtitle,
                compact: false,
                padding: EdgeInsets.zero,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            104,
          ),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        104,
      ),
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

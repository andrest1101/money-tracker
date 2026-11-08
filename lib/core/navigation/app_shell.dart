import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/savings/presentation/pages/savings_page.dart';
import '../../features/savings/presentation/widgets/add_goal_sheet.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/presentation/pages/history_page.dart';
import '../../features/transactions/presentation/providers/history_providers.dart';
import '../../features/transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../theme/app_spacing.dart';
import 'navigation_providers.dart';

/// Kerangka utama Savu: `NavigationBar` empat tab + FAB kontekstual.
///
/// Halaman yang pernah dibuka disimpan di dalam [IndexedStack] agar state
/// (posisi scroll, filter, pencarian) tetap hidup saat berpindah tab.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const List<Widget> _pages = [
    DashboardPage(),
    SavingsPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  final Set<int> _visited = {ShellTabIndex.home};

  void _selectTab(int index) {
    _visited.add(index);
    ref.read(shellTabIndexProvider.notifier).select(index);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(shellTabIndexProvider);
    _visited.add(index);

    ref.listen<HistoryNavigationIntent?>(historyNavigationIntentProvider, (
      _,
      intent,
    ) {
      if (intent == null) return;
      _selectTab(ShellTabIndex.history);
    });

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < _pages.length; i++)
            if (_visited.contains(i)) _pages[i] else const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        animationDuration: AppDuration.normal,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Target',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Pengaturan',
          ),
        ],
      ),
      floatingActionButton: _buildFab(index),
    );
  }

  Widget? _buildFab(int index) {
    if (index == ShellTabIndex.settings) return null;

    final isSavingsTab = index == ShellTabIndex.savings;
    return FloatingActionButton.extended(
      key: ValueKey('fab-$index'),
      tooltip: isSavingsTab ? 'Buat target' : 'Catat transaksi',
      onPressed: isSavingsTab ? _openAddGoal : _openAddTransaction,
      icon: const Icon(Icons.add_rounded),
      label: Text(isSavingsTab ? 'Buat target' : 'Catat transaksi'),
    );
  }

  void _openAddTransaction() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickAddTransactionSheet(),
    );
  }

  void _openAddGoal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddGoalSheet(),
    );
  }
}

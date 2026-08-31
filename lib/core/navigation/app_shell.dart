import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/savings/presentation/pages/savings_page.dart';
import '../../features/savings/presentation/widgets/add_goal_sheet.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/presentation/pages/history_page.dart';
import '../../features/transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../widgets/app_page_background.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    SavingsPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          reverseDuration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: FloatingPillNavigation(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          onActionSelected: _showCreateOptions,
        ),
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _CreateOptionsSheet(),
    );
  }
}

class FloatingPillNavigation extends StatelessWidget {
  const FloatingPillNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onActionSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onActionSelected;

  static const _items = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Beranda',
    ),
    (icon: Icons.savings_outlined, activeIcon: Icons.savings, label: 'Target'),
    (
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Riwayat',
    ),
    (
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Pengaturan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .5),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .16),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _FloatingPillDestination(
                item: _items[0],
                selected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
            ),
            Expanded(
              child: _FloatingPillDestination(
                item: _items[1],
                selected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
            ),
            _FloatingActionDestination(onTap: onActionSelected),
            Expanded(
              child: _FloatingPillDestination(
                item: _items[2],
                selected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ),
            Expanded(
              child: _FloatingPillDestination(
                item: _items[3],
                selected: selectedIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingActionDestination extends StatelessWidget {
  const _FloatingActionDestination({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Semantics(
        button: true,
        label: 'Tambah catatan atau target',
        child: Transform.translate(
          offset: const Offset(0, -15),
          child: Material(
            color: colors.primary,
            elevation: 6,
            shadowColor: colors.primary.withValues(alpha: .35),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 54,
                height: 54,
                child: Icon(Icons.add_rounded, size: 29, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateOptionsSheet extends StatelessWidget {
  const _CreateOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat sesuatu yang baru',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Pilih yang ingin kamu tambahkan ke MoneyTracker.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _CreateOptionTile(
              icon: Icons.receipt_long_rounded,
              title: 'Buat Catatan Baru',
              subtitle: 'Catat pemasukan atau pengeluaran',
              color: colors.primary,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const QuickAddTransactionSheet(),
                );
              },
            ),
            const SizedBox(height: 10),
            _CreateOptionTile(
              icon: Icons.savings_rounded,
              title: 'Buat Target Tabungan Baru',
              subtitle: 'Mulai rencanakan impianmu',
              color: colors.tertiary,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const AddGoalSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOptionTile extends StatelessWidget {
  const _CreateOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingPillDestination extends StatelessWidget {
  const _FloatingPillDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ({IconData icon, IconData activeIcon, String label}) item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  color: foreground,
                  size: 21,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11,
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

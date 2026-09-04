import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../domain/entities/transaction_entity.dart';

class ManageCategoriesSheet extends ConsumerWidget {
  const ManageCategoriesSheet({
    super.key,
    required this.type,
    required this.categories,
  });

  final TransactionType type;
  final List<String> categories;

  static Future<void> show(
    BuildContext context, {
    required TransactionType type,
    required List<String> categories,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ManageCategoriesSheet(type: type, categories: categories),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hidden = type == TransactionType.expense
        ? ref.watch(hiddenExpenseCategoriesProvider)
        : ref.watch(hiddenIncomeCategoriesProvider);
    final hiddenSet = hidden.toSet();
    final visible = categories.where((category) => !hiddenSet.contains(category));
    final hiddenCategories = categories.where(hiddenSet.contains);
    final isExpense = type == TransactionType.expense;
    final accent = isExpense ? colors.error : colors.primary;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        minChildSize: .48,
        maxChildSize: .92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(
              'Kelola kategori',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isExpense
                  ? 'Rapikan pilihan kategori pengeluaranmu.'
                  : 'Rapikan pilihan kategori pemasukanmu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _ManageCategoryInfo(accent: accent),
            const SizedBox(height: 20),
            _CategorySectionTitle(
              title: 'Kategori aktif',
              count: visible.length,
            ),
            const SizedBox(height: 8),
            if (visible.isEmpty)
              const _CategoryEmptyState(
                icon: Icons.visibility_off_outlined,
                text: 'Semua kategori sedang disembunyikan.',
              )
            else
              ...visible.map(
                (category) => _CategoryManageTile(
                  category: category,
                  icon: category == 'Alokasi Tabungan'
                      ? Icons.lock_outline_rounded
                      : Icons.visibility_outlined,
                  actionLabel: category == 'Alokasi Tabungan'
                      ? 'Kategori sistem'
                      : 'Sembunyikan',
                  accent: accent,
                  onPressed: category == 'Alokasi Tabungan'
                      ? null
                      : () => _toggle(context, ref, category),
                ),
              ),
            if (hiddenCategories.isNotEmpty) ...[
              const SizedBox(height: 20),
              _CategorySectionTitle(
                title: 'Kategori tersembunyi',
                count: hiddenCategories.length,
              ),
              const SizedBox(height: 8),
              ...hiddenCategories.map(
                (category) => _CategoryManageTile(
                  category: category,
                  icon: Icons.visibility_off_outlined,
                  actionLabel: 'Tampilkan',
                  accent: colors.primary,
                  onPressed: () => _toggle(context, ref, category),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    String category,
  ) async {
    if (category == 'Alokasi Tabungan') return;
    final hidden = type == TransactionType.expense
        ? ref.read(hiddenExpenseCategoriesProvider)
        : ref.read(hiddenIncomeCategoriesProvider);
    final isHidden = hidden.contains(category);
    if (!isHidden) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.visibility_off_outlined),
          title: Text('Sembunyikan $category?'),
          content: const Text(
            'Kategori ini tidak akan muncul saat membuat transaksi baru. '
            'Transaksi lama tetap aman di riwayat.',
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Sembunyikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final success = type == TransactionType.expense
        ? await ref.read(hiddenExpenseCategoriesProvider.notifier).toggle(category)
        : await ref.read(hiddenIncomeCategoriesProvider.notifier).toggle(category);
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori gagal diperbarui. Coba lagi.')),
    );
  }
}

class _ManageCategoryInfo extends StatelessWidget {
  const _ManageCategoryInfo({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sembunyikan kategori yang tidak relevan. Data transaksi lama tidak akan dihapus.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _CategorySectionTitle extends StatelessWidget {
  const _CategorySectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CategoryManageTile extends StatelessWidget {
  const _CategoryManageTile({
    required this.category,
    required this.icon,
    required this.actionLabel,
    required this.accent,
    this.onPressed,
  });

  final String category;
  final IconData icon;
  final String actionLabel;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colors.surfaceContainerHigh,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: .12),
          foregroundColor: accent,
          child: Icon(icon, size: 20),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 17),
          label: Text(actionLabel),
        ),
      ),
    );
  }
}

class _CategoryEmptyState extends StatelessWidget {
  const _CategoryEmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

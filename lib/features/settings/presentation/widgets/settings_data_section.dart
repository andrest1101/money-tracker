import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/export/presentation/providers/export_controller.dart';
import '../../../../features/export/presentation/widgets/export_sheet.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'settings_snack_bar.dart';

class DataManagementCard extends ConsumerWidget {
  const DataManagementCard({super.key});

  void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    final danger = context.appColors.danger;
    final onDanger = Theme.of(context).colorScheme.onError;
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: danger),
        title: const Text('Hapus Semua Data?'),
        content: const SingleChildScrollView(
          child: Text(
            'Tindakan ini akan menghapus SELURUH transaksi dan target tabungan secara permanen dari server. Tindakan ini tidak dapat dibatalkan.',
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: onDanger,
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Hapus Semua'),
                ),
              ),
            ],
          ),
        ],
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      ),
    );
    if (firstConfirm != true || !context.mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => const FinalDeleteConfirmationDialog(),
    );
    if (secondConfirm != true || !context.mounted) return;

    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .deleteAllData();
    if (!context.mounted) return;
    showSettingsSnackBar(
      context,
      message: success
          ? 'Semua transaksi dan target berhasil dihapus.'
          : 'Data gagal dihapus. Coba lagi.',
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final danger = context.appColors.danger;
    final transactions = ref.watch(transactionsStreamProvider);
    final isExporting = ref.watch(exportControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              enabled: !isExporting,
              onTap: () async {
                final items = transactions.value ?? const [];
                if (items.isEmpty) {
                  _showInfoMessage(
                    context,
                    'Belum ada transaksi untuk diekspor.',
                  );
                  return;
                }
                final shared = await ExportSheet.show(context);
                if (!context.mounted || shared != true) return;
                showSettingsSnackBar(
                  context,
                  message: 'Laporan siap dibagikan.',
                );
              },
              leading: Icon(Icons.ios_share_rounded, color: cs.primary),
              title: const Text('Ekspor Data'),
              subtitle: Text(
                isExporting
                    ? 'Menyiapkan file...'
                    : 'Laporan Excel atau CSV transaksi',
              ),
              trailing: isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              onTap: () => _showDeleteAllDialog(context, ref),
              leading: Icon(Icons.delete_forever_rounded, color: danger),
              title: Text(
                'Hapus Seluruh Data',
                style: TextStyle(color: danger, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Reset akun dan mulai dari nol'),
            ),
          ],
        ),
      ),
    );
  }
}

class FinalDeleteConfirmationDialog extends StatefulWidget {
  const FinalDeleteConfirmationDialog({super.key});

  @override
  State<FinalDeleteConfirmationDialog> createState() =>
      _FinalDeleteConfirmationDialogState();
}

class _FinalDeleteConfirmationDialogState
    extends State<FinalDeleteConfirmationDialog> {
  bool _hasConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final danger = context.appColors.danger;
    final onDanger = Theme.of(context).colorScheme.onError;
    return AlertDialog(
      icon: Icon(Icons.gpp_maybe_rounded, color: danger, size: 44),
      title: const Text('Konfirmasi terakhir'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data transaksi, alokasi, dan target tabungan akan dihapus permanen. Pastikan kamu benar-benar ingin melanjutkan.',
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _hasConfirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Saya mengerti bahwa tindakan ini tidak dapat dibatalkan.',
              ),
              onChanged: (value) {
                setState(() => _hasConfirmed = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _hasConfirmed
                    ? () => Navigator.pop(context, true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: danger,
                  foregroundColor: onDanger,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                child: const Text('Hapus Semua'),
              ),
            ),
          ],
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }
}

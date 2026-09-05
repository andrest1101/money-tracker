import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import 'settings_snack_bar.dart';

class FinancialSettingsCard extends ConsumerWidget {
  const FinancialSettingsCard({super.key});

  void _showSetBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    double? currentLimit,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SetBudgetDialog(currentLimit: currentLimit),
    );
  }

  void _showSetCycleDialog(
    BuildContext context,
    WidgetRef ref,
    int currentDay,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SetCycleDialog(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLimit = ref.watch(budgetLimitProvider);
    final currentCycle = ref.watch(budgetCycleDateProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isSet = currentLimit != null && currentLimit > 0;

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
              onTap: () => _showSetBudgetDialog(context, ref, currentLimit),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: cs.primary,
                ),
              ),
              title: Text(
                'Batas Anggaran Bulanan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: isSet
                  ? Text(
                      formatRupiah(currentLimit),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text('Belum diatur'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 64),
            ListTile(
              onTap: () => _showSetCycleDialog(context, ref, currentCycle),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.orange.shade800,
                ),
              ),
              title: Text(
                'Siklus Anggaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Dimulai tanggal $currentCycle setiap bulan'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class SetBudgetDialog extends ConsumerStatefulWidget {
  const SetBudgetDialog({super.key, required this.currentLimit});
  final double? currentLimit;

  @override
  ConsumerState<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<SetBudgetDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.currentLimit != null && widget.currentLimit! > 0) {
      _controller.text = formatRupiah(
        widget.currentLimit!,
      ).replaceFirst('Rp ', '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final raw = _controller.text.trim().replaceAll('.', '');
    final limit = double.tryParse(raw);

    if (limit == null || limit < 0) {
      setState(() => _errorText = 'Masukkan nominal anggaran yang valid.');
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });
    final saved = await ref
        .read(budgetLimitProvider.notifier)
        .setBudgetLimit(limit == 0 ? null : limit);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!saved) {
      showSettingsSnackBar(
        context,
        message: 'Batas anggaran gagal disimpan.',
        isError: true,
      );
      return;
    }
    Navigator.of(context).pop();
    showSettingsSnackBar(context, message: 'Batas anggaran diperbarui.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batas Anggaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atur batas pengeluaran bulanan agar aplikasi dapat memberikan peringatan sebelum kamu boros.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Batas Nominal',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Isi 0 untuk mematikan peringatan',
                helperMaxLines: 2,
                errorText: _errorText,
                errorMaxLines: 2,
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }
}

class SetCycleDialog extends ConsumerStatefulWidget {
  const SetCycleDialog({super.key, required this.currentDay});
  final int currentDay;

  @override
  ConsumerState<SetCycleDialog> createState() => _SetCycleDialogState();
}

class _SetCycleDialogState extends ConsumerState<SetCycleDialog> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tanggal Siklus'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kapan biasanya kamu menerima uang bulanan/gajian? Anggaran akan di-reset pada tanggal ini.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              items: List.generate(28, (index) => index + 1)
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text('Tanggal $day'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedDay = value);
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
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final saved = await ref
                      .read(budgetCycleDateProvider.notifier)
                      .setDate(_selectedDay);
                  if (!context.mounted) return;
                  if (!saved) {
                    showSettingsSnackBar(
                      context,
                      message: 'Siklus anggaran gagal disimpan.',
                      isError: true,
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  showSettingsSnackBar(
                    context,
                    message: 'Siklus anggaran diperbarui.',
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }
}

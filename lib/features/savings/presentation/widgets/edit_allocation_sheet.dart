import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/quick_add_controller.dart';
import '../../domain/entities/savings_goal_entity.dart';

class EditAllocationSheet extends ConsumerStatefulWidget {
  const EditAllocationSheet({
    super.key,
    required this.transaction,
    required this.goal,
  });

  final TransactionEntity transaction;
  final SavingsGoalEntity goal;

  @override
  ConsumerState<EditAllocationSheet> createState() =>
      _EditAllocationSheetState();
}

class _EditAllocationSheetState extends ConsumerState<EditAllocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text =
        formatRupiah(widget.transaction.amount).replaceFirst('Rp ', '');
    _noteController.text = widget.transaction.note;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _maxNewAmount {
    // currentAmount goal termasuk kontribusi transaksi ini
    // jadi max = targetAmount - (currentAmount - oldAmount)
    final alreadyAllocatedByOthers =
        widget.goal.currentAmount - widget.transaction.amount;
    return widget.goal.targetAmount - alreadyAllocatedByOthers;
  }

  String? _validateAmount(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Nominal wajib diisi';
    final parsed = double.tryParse(raw.replaceAll('.', ''));
    if (parsed == null) return 'Nominal harus berupa angka';
    if (parsed < 0) return 'Nominal tidak boleh negatif';
    if (parsed > _maxNewAmount) {
      return 'Maks ${formatRupiah(_maxNewAmount)} (sisa target)';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll('.', '')) ?? 0;

    // Jika nominal 0, konfirmasi withdraw
    if (amount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(
            Icons.undo_rounded,
            color: Colors.orange.shade700,
            size: 40,
          ),
          title: const Text('Tarik Semua Alokasi?'),
          content: Text(
            'Alokasi ${formatRupiah(widget.transaction.amount)} untuk "${widget.goal.title}" '
            'akan dicabut dan uang kembali ke saldo utama.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
              ),
              child: const Text('Tarik'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    // Buat entity yang sudah di-correct: type & goalId dari transaksi original
    final updatedTransaction = TransactionEntity(
      id: widget.transaction.id,
      amount: amount,
      type: widget.transaction.type,
      category: widget.transaction.category,
      date: widget.transaction.date,
      note: _noteController.text.trim(),
      goalId: widget.transaction.goalId,
    );

    final success = await ref
        .read(quickAddControllerProvider.notifier)
        .updateTransaction(updatedTransaction);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      Navigator.of(context).pop();
      if (amount == 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Alokasi ${formatRupiah(widget.transaction.amount)} berhasil ditarik ke saldo.',
            ),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Alokasi diperbarui menjadi ${formatRupiah(amount)}!',
            ),
          ),
        );
      }
    } else {
      final error = ref.read(quickAddControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error?.toString().replaceFirst('InvalidAllocationException: ', '') ??
                'Gagal memperbarui alokasi. Coba lagi ya.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSaving = ref.watch(quickAddControllerProvider).isLoading;
    const accentColor = Color(0xFF4CAF50); // teal-green for savings

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Alokasi',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Target: ${widget.goal.title}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info card — alokasi saat ini
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Alokasi saat ini: ${formatRupiah(widget.transaction.amount)}'
                          '  •  Maks: ${formatRupiah(_maxNewAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nominal field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: _validateAmount,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nominal Baru',
                    hintText: '50.000',
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                    helperText: 'Isi 0 untuk menarik semua alokasi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Catatan field
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    hintText: 'Contoh: nabung dari uang jajan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    isSaving ? 'Menyimpan...' : 'Perbarui Alokasi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

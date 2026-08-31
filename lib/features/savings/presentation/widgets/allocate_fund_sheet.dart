import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/usecases/allocate_to_goal_usecase.dart';
import '../providers/savings_providers.dart';
import 'goal_celebration_dialog.dart';

class AllocateFundSheet extends ConsumerStatefulWidget {
  const AllocateFundSheet({super.key, required this.goal});

  final SavingsGoalEntity goal;

  @override
  ConsumerState<AllocateFundSheet> createState() => _AllocateFundSheetState();
}

class _AllocateFundSheetState extends ConsumerState<AllocateFundSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  static const _allocateToGoal = AllocateToGoalUseCase();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _availableBalance =>
      ref.read(monthlySummaryProvider).value?.balance ?? 0;

  String? _validateAmount(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Nominal wajib diisi';

    final parsed = double.tryParse(raw.replaceAll('.', ''));
    if (parsed == null) return 'Nominal harus berupa angka';

    try {
      _allocateToGoal.execute(
        goal: widget.goal,
        amount: parsed,
        availableBalance: _availableBalance,
      );
      return null;
    } on InvalidAllocationException catch (e) {
      return e.message;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll('.', '')) ?? 0;

    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .allocateToGoal(goal: widget.goal, amount: amount);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      final completed = amount >= widget.goal.remainingAmount;
      if (completed && mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => GoalCelebrationDialog(goalTitle: widget.goal.title),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${formatRupiah(amount)} dialokasikan ke "${widget.goal.title}"!',
          ),
        ),
      );
    } else {
      final errorMessage = ref
          .read(savingsActionsControllerProvider)
          .when(
            data: (_) => 'Gagal mengalokasikan dana. Coba lagi ya.',
            loading: () => 'Alokasi masih diproses. Coba lagi sebentar.',
            error: (error, _) => error.toString(),
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSaving = ref.watch(savingsActionsControllerProvider).isLoading;

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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Alokasikan Dana',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk target "${widget.goal.title}" • sisa '
                  '${formatRupiah(widget.goal.remainingAmount)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: _validateAmount,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    hintText: '50.000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saldo utama: ${formatRupiah(_availableBalance)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.savings_outlined),
                  label: Text(isSaving ? 'Mengalokasikan...' : 'Alokasikan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

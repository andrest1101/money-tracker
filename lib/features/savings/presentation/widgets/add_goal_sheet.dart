import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_providers.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll('.', '')) ?? 0;
    final now = DateTime.now();

    final goal = SavingsGoalEntity(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      targetAmount: amount,
      currentAmount: 0,
      deadline: _deadline,
      createdAt: now,
    );

    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .addGoal(goal);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Target "${goal.title}" berhasil dibuat!')),
      );
    } else {
      final errorMessage = ref
          .read(savingsActionsControllerProvider)
          .when(
            data: (_) => 'Gagal membuat target. Coba lagi ya.',
            loading: () => 'Target masih diproses. Coba lagi sebentar.',
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
    final monthNames = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
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
                  'Target Tabungan Baru',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Judul wajib diisi'
                      : null,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Judul target',
                    hintText: 'Contoh: Handphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) return 'Nominal target wajib diisi';
                    final parsed = double.tryParse(raw.replaceAll('.', ''));
                    if (parsed == null) return 'Nominal harus berupa angka';
                    if (parsed <= 0) return 'Nominal harus lebih dari 0';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nominal target',
                    hintText: '5.000.000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDeadline,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    'Tenggat: ${_deadline.day} ${monthNames[_deadline.month - 1]} '
                    '${_deadline.year}',
                  ),
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
                      : const Icon(Icons.flag_outlined),
                  label: Text(isSaving ? 'Menyimpan...' : 'Buat Target'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

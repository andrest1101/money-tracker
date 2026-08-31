import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/usecases/update_savings_goal_usecase.dart';
import '../providers/savings_providers.dart';

class EditGoalSheet extends ConsumerStatefulWidget {
  const EditGoalSheet({super.key, required this.goal});

  final SavingsGoalEntity goal;

  @override
  ConsumerState<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends ConsumerState<EditGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _deadline;

  static const _monthNames = [
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _amountController = TextEditingController(
      text: formatRupiah(widget.goal.targetAmount).replaceFirst('Rp ', ''),
    );
    _deadline = widget.goal.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isBefore(DateTime.now())
          ? DateTime.now()
          : _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && mounted) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll('.', '')) ?? 0;

    try {
      final updatedGoal = const UpdateSavingsGoalUseCase().execute(
        goal: widget.goal,
        title: _titleController.text,
        targetAmount: amount,
        deadline: _deadline,
      );
      final success = await ref
          .read(savingsActionsControllerProvider.notifier)
          .updateGoal(updatedGoal);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Target "${updatedGoal.title}" diperbarui.')),
        );
      } else {
        _showError('Gagal memperbarui target. Coba lagi ya.');
      }
    } on FormatException catch (error) {
      _showError(error.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Target Tabungan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dana yang sudah dialokasikan tetap aman dan tidak berubah.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Judul wajib diisi'
                      : null,
                  decoration: const InputDecoration(labelText: 'Judul target'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    final parsed = double.tryParse(raw.replaceAll('.', ''));
                    if (raw.isEmpty) return 'Nominal target wajib diisi';
                    if (parsed == null) return 'Nominal harus berupa angka';
                    if (parsed <= 0) return 'Nominal harus lebih dari 0';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nominal target',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDeadline,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    'Tenggat: ${_deadline.day} ${_monthNames[_deadline.month - 1]} ${_deadline.year}',
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
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

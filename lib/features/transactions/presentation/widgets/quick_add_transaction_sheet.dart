import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/quick_add_controller.dart';

const _monthNames = [
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

class QuickAddTransactionSheet extends ConsumerStatefulWidget {
  const QuickAddTransactionSheet({super.key, this.transaction});

  final TransactionEntity? transaction;

  bool get isEditMode => transaction != null;

  @override
  ConsumerState<QuickAddTransactionSheet> createState() =>
      _QuickAddTransactionSheetState();
}

class _QuickAddTransactionSheetState
    extends ConsumerState<QuickAddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  final Map<TransactionType, List<String>> _extraCategoriesByType = {
    TransactionType.expense: const [],
    TransactionType.income: const [],
  };
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _amountController.text = formatRupiah(t.amount).replaceFirst('Rp ', '');
      _noteController.text = t.note;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory != null) return;
    final categories = _categories;
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final base = _selectedType == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final all = <String>[
      ...base,
      ...(_extraCategoriesByType[_selectedType] ?? const <String>[]),
    ];
    if (widget.transaction?.isAllocation == true) {
      return all;
    }
    return all.where((c) => c != 'Alokasi Tabungan').toList();
  }

  String get _noteHint {
    const examples = {
      'Makanan': 'makan siang di warung',
      'Transportasi': 'ongkos ojek ke kampus',
      'Bensin': 'isi bensin motor',
      'Pulsa & Kuota': 'beli paket internet',
      'Kesehatan & Perawatan': 'beli vitamin',
      'Hiburan': 'nonton film bioskop',
      'Kos & Tagihan': 'bayar listrik kos',
      'Belanja': 'beli kebutuhan harian',
      'Lainnya': 'kebutuhan lainnya',
      'Uang Kiriman': 'kiriman dari orang tua',
      'Beasiswa': 'beasiswa bulan ini',
      'Gaji Part-time': 'gaji kerja part-time',
      'Alokasi Tabungan': 'alokasi dana ke target tabungan',
    };
    final example = examples[_selectedCategory];
    if (example != null) return 'Contoh: $example';

    final category = _selectedCategory?.trim();
    if (category == null || category.isEmpty) {
      return 'Contoh: tulis detail transaksi';
    }
    return 'Contoh: detail $category';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addCustomCategory() async {
    _customCategoryController.clear();
    final category = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kategori Baru'),
        content: SingleChildScrollView(
          child: TextField(
            controller: _customCategoryController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama kategori',
              hintText: 'Contoh: Kosmetik',
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).pop(_customCategoryController.text),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Tambah'),
                ),
              ),
            ],
          ),
        ],
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      ),
    );

    final trimmed = category?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    setState(() {
      final customCategories =
          _extraCategoriesByType[_selectedType] ?? const <String>[];
      final alreadyExists =
          customCategories.contains(trimmed) ||
          (_selectedType == TransactionType.expense
                  ? ref.read(expenseCategoriesProvider)
                  : ref.read(incomeCategoriesProvider))
              .contains(trimmed);
      if (!alreadyExists) {
        _extraCategoriesByType[_selectedType] = [
          ...customCategories,
          trimmed,
        ];
      }
      _selectedCategory = trimmed;
    });
  }

  void _switchType(TransactionType type) {
    setState(() {
      _selectedType = type;
      final available = _categories;
      if (!available.contains(_selectedCategory)) {
        _selectedCategory = available.isEmpty ? null : available.first;
      }
    });
  }

  String? _validateAmount(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Nominal wajib diisi';
    final parsed = double.tryParse(raw.replaceAll('.', ''));
    if (parsed == null) return 'Nominal harus berupa angka';
    if (parsed < 0) return 'Nominal tidak boleh negatif';

    // Allow 0 for allocation edit with warning
    if (parsed == 0 &&
        widget.isEditMode &&
        widget.transaction?.isAllocation == true) {
      return 'Nominal 0 akan withdraw semua alokasi (transaksi akan dihapus)';
    }

    if (parsed <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kategori dulu ya')));
      return;
    }

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll('.', '')) ?? 0;

    // Show confirmation dialog if editing allocation to 0
    if (widget.isEditMode &&
        widget.transaction?.isAllocation == true &&
        amount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Withdraw Semua Alokasi?'),
          content: SingleChildScrollView(
            child: Text(
              'Uang ${formatRupiah(widget.transaction!.amount)} akan kembali ke saldo utama dan riwayat alokasi ini akan dihapus.',
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Withdraw'),
                  ),
                ),
              ],
            ),
          ],
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
        ),
      );

      if (confirm != true) return;
    }

    final transaction = TransactionEntity(
      id: widget.isEditMode
          ? widget.transaction!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      type: _selectedType,
      category: category,
      date: _selectedDate,
      note: _noteController.text.trim(),
      goalId: widget.transaction?.goalId,
    );

    final success = widget.isEditMode
        ? await ref
              .read(quickAddControllerProvider.notifier)
              .updateTransaction(transaction)
        : await ref
              .read(quickAddControllerProvider.notifier)
              .submit(transaction);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Transaksi berhasil diperbarui!'
                : 'Transaksi ${formatRupiah(amount)} tersimpan!',
          ),
        ),
      );
    } else {
      final errorMessage = ref
          .read(quickAddControllerProvider)
          .when(
            data: (_) => 'Gagal menyimpan transaksi. Coba lagi ya.',
            loading: () => 'Transaksi masih diproses. Coba lagi sebentar.',
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
    final categories = _categories;
    final isSaving = ref.watch(quickAddControllerProvider).isLoading;
    final isEdit = widget.isEditMode;

    final typeColor = _selectedType == TransactionType.expense
        ? Colors.red.shade600
        : Colors.green.shade700;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEdit ? Icons.edit : Icons.add,
                        color: typeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: _validateAmount,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nominal',
                    hintText: '25.000',
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      borderSide: BorderSide(color: typeColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        icon: Icon(Icons.north_east, size: 18),
                        label: Text('Pengeluaran'),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        icon: Icon(Icons.south_west, size: 18),
                        label: Text('Pemasukan'),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (selection) =>
                        _switchType(selection.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Kategori',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final category in categories)
                      ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        selectedColor: typeColor.withValues(alpha: 0.15),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: _selectedCategory == category
                            ? BorderSide(
                                color: typeColor.withValues(alpha: 0.5),
                              )
                            : null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                    ActionChip(
                      avatar: Icon(Icons.add, size: 16, color: typeColor),
                      label: Text('Baru', style: TextStyle(color: typeColor)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: _addCustomCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tanggal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: typeColor),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Catatan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _noteHint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                      borderSide: BorderSide(color: typeColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: typeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                      : Icon(isEdit ? Icons.check : Icons.add),
                  label: Text(
                    isSaving
                        ? (isEdit ? 'Memperbarui...' : 'Menyimpan...')
                        : (isEdit ? 'Perbarui' : 'Simpan'),
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

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import 'app_bottom_sheet.dart';

/// Periode cepat pada [FilterSheet].
enum FilterPeriod { all, last7Days, last30Days, custom }

/// Hasil pilihan filter. Bottom sheet mengembalikan objek ini lewat
/// `Navigator.pop`.
@immutable
class FilterSelection {
  const FilterSelection({
    this.period = FilterPeriod.all,
    this.dateRange,
    this.category,
    this.activeCycleOnly = false,
  });

  final FilterPeriod period;
  final DateTimeRange? dateRange;
  final String? category;
  final bool activeCycleOnly;

  bool get hasActiveFilters =>
      period != FilterPeriod.all || category != null || activeCycleOnly;

  @override
  bool operator ==(Object other) {
    return other is FilterSelection &&
        other.period == period &&
        other.category == category &&
        other.activeCycleOnly == activeCycleOnly &&
        other.dateRange?.start == dateRange?.start &&
        other.dateRange?.end == dateRange?.end;
  }

  @override
  int get hashCode => Object.hash(
    period,
    category,
    activeCycleOnly,
    dateRange?.start,
    dateRange?.end,
  );
}

/// Membuka [FilterSheet] dan mengembalikan pilihan saat user menekan Terapkan.
Future<FilterSelection?> showFilterSheet(
  BuildContext context, {
  required List<String> categories,
  FilterSelection initial = const FilterSelection(),
}) {
  return showModalBottomSheet<FilterSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => FilterSheet(categories: categories, initial: initial),
  );
}

/// Bottom sheet filter: periode, kategori, dan siklus anggaran aktif.
///
/// Komponen ini presentational. Penghubung ke provider Riwayat dilakukan di
/// layar Riwayat agar sheet bisa dipakai ulang di layar lain.
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.categories,
    this.initial = const FilterSelection(),
    this.maxRangeDays = 31,
  });

  final List<String> categories;
  final FilterSelection initial;
  final int maxRangeDays;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterPeriod _period;
  late DateTimeRange? _dateRange;
  late String? _category;
  late bool _activeCycleOnly;
  String? _error;

  @override
  void initState() {
    super.initState();
    _period = widget.initial.period;
    _dateRange = widget.initial.dateRange;
    _category = widget.initial.category;
    _activeCycleOnly = widget.initial.activeCycleOnly;
  }

  bool get _canApply => _period != FilterPeriod.custom || _dateRange != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppBottomSheetLayout(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.filterTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                AppStrings.filterDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(text: AppStrings.period),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _periodChip(
                    label: AppStrings.allTime,
                    period: FilterPeriod.all,
                  ),
                  _periodChip(
                    label: AppStrings.last7Days,
                    period: FilterPeriod.last7Days,
                  ),
                  _periodChip(
                    label: AppStrings.last30Days,
                    period: FilterPeriod.last30Days,
                  ),
                  _periodChip(
                    label: _rangeChipLabel,
                    period: FilterPeriod.custom,
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(text: AppStrings.category),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: const Text(AppStrings.allCategories),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final category in widget.categories)
                    ChoiceChip(
                      label: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: _category == category,
                      onSelected: (_) {
                        setState(() {
                          _category = _category == category ? null : category;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _activeCycleOnly,
                onChanged: (value) => setState(() => _activeCycleOnly = value),
                title: Text(
                  AppStrings.activeCycle,
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  AppStrings.activeCycleDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text(AppStrings.reset),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canApply ? _apply : null,
                      child: const Text(AppStrings.apply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _rangeChipLabel {
    final range = _dateRange;
    if (_period != FilterPeriod.custom || range == null) {
      return AppStrings.customRange;
    }
    return '${formatDateShort(range.start)} – ${formatDateShort(range.end)}';
  }

  Widget _periodChip({required String label, required FilterPeriod period}) {
    return ChoiceChip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: _period == period,
      onSelected: (_) => _selectPeriod(period),
    );
  }

  void _selectPeriod(FilterPeriod period) {
    if (period == FilterPeriod.custom) {
      _pickRange();
      return;
    }
    setState(() {
      _period = period;
      _error = null;
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final firstDate = DateTime(now.year - 5);
    final initialRange =
        _dateRange != null &&
            !_dateRange!.start.isBefore(firstDate) &&
            !_dateRange!.end.isAfter(lastDate)
        ? _dateRange
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
      helpText: AppStrings.pickRange,
      saveText: AppStrings.apply,
      cancelText: AppStrings.cancel,
    );
    if (picked == null || !mounted) return;

    final days = picked.end.difference(picked.start).inDays + 1;
    if (days > widget.maxRangeDays) {
      setState(() => _error = AppStrings.rangeTooLong);
      return;
    }

    setState(() {
      _dateRange = DateTimeRange(
        start: DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        ),
        end: DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
          999,
        ),
      );
      _period = FilterPeriod.custom;
      _error = null;
    });
  }

  void _reset() {
    setState(() {
      _period = FilterPeriod.all;
      _dateRange = null;
      _category = null;
      _activeCycleOnly = false;
      _error = null;
    });
  }

  void _apply() {
    if (!_canApply) {
      setState(() => _error = AppStrings.rangeRequired);
      return;
    }
    Navigator.of(context).pop(
      FilterSelection(
        period: _period,
        dateRange: _period == FilterPeriod.custom ? _dateRange : null,
        category: _category,
        activeCycleOnly: _activeCycleOnly,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

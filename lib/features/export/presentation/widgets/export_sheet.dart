import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../../settings/presentation/widgets/settings_snack_bar.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/usecases/resolve_export_period.dart';
import '../providers/export_controller.dart';

/// Bottom sheet pilihan format, periode, dan pemisah CSV.
///
/// Seluruh perhitungan angka dilakukan di Domain; widget ini hanya memilih
/// opsi dan menampilkan pratinjau jumlah transaksi.
class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key});

  /// Mengembalikan `true` jika file berhasil dibagikan.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const AppBottomSheetLayout(child: ExportSheet()),
    );
  }

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  ExportFormat _format = ExportFormat.xlsx;
  ExportPeriodType _period = ExportPeriodType.allTime;
  CsvDelimiter _delimiter = CsvDelimiter.semicolon;
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final transactions =
        ref.watch(transactionsStreamProvider).value ?? const [];
    final isExporting = ref.watch(exportControllerProvider).isLoading;
    final preview = _ExportPreview.from(
      period: _period,
      customRange: _customRange,
      transactions: transactions,
      now: DateTime.now(),
      cycleDay: ref.watch(budgetCycleDateProvider),
    );
    final isCustomWithoutRange =
        _period == ExportPeriodType.custom && _customRange == null;
    final canShare =
        !isExporting && preview.count > 0 && !isCustomWithoutRange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.ios_share_rounded,
                  color: scheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ekspor data',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bagikan laporan atau data mentah.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionLabel('Format'),
            const SizedBox(height: AppSpacing.xs),
            AppSegmentedControl(
              labels: const ['Laporan Excel', 'CSV Data'],
              selectedIndex: _format == ExportFormat.xlsx ? 0 : 1,
              semanticLabel: 'Format file ekspor',
              onChanged: isExporting
                  ? (_) {}
                  : (index) {
                      setState(() {
                        _format = index == 0
                            ? ExportFormat.xlsx
                            : ExportFormat.csv;
                      });
                    },
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _format == ExportFormat.xlsx
                  ? 'Laporan 5 sheet: Ringkasan, Transaksi, Per Kategori, Bulanan, dan Target Tabungan.'
                  : 'Satu tabel bersih untuk diolah di Excel, Google Sheets, atau Python.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionLabel('Periode'),
            const SizedBox(height: AppSpacing.xs),
            AppSegmentedControl(
              labels: const ['Semua', 'Bulan ini', 'Siklus', 'Tanggal'],
              selectedIndex: ExportPeriodType.values.indexOf(_period),
              semanticLabel: 'Periode ekspor',
              onChanged: isExporting
                  ? (_) {}
                  : (index) {
                      final type = ExportPeriodType.values[index];
                      setState(() => _period = type);
                      if (type == ExportPeriodType.custom &&
                          _customRange == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _pickDateRange();
                        });
                      }
                    },
            ),
            if (_period == ExportPeriodType.custom) ...[
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: isExporting ? null : _pickDateRange,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _customRange == null
                      ? 'Pilih rentang tanggal'
                      : _rangeLabel(_customRange!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (_format == ExportFormat.csv) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionLabel('Pemisah CSV'),
              const SizedBox(height: AppSpacing.xs),
              AppSegmentedControl(
                labels: const ['Titik koma (;)', 'Koma (,)'],
                selectedIndex: _delimiter == CsvDelimiter.semicolon ? 0 : 1,
                semanticLabel: 'Pemisah kolom CSV',
                onChanged: isExporting
                    ? (_) {}
                    : (index) {
                        setState(() {
                          _delimiter = index == 0
                              ? CsvDelimiter.semicolon
                              : CsvDelimiter.comma;
                        });
                      },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    preview.count == 0
                        ? Icons.info_outline_rounded
                        : Icons.receipt_long_rounded,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      preview.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: canShare ? _share : null,
              icon: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              label: Text(isExporting ? 'Menyiapkan...' : _shareLabel),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'File dibuat sementara dan hanya dibagikan lewat sheet sistem.',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String get _shareLabel {
    return _format == ExportFormat.xlsx ? 'Bagikan Laporan' : 'Bagikan CSV';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange =
        _customRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initialRange,
      helpText: 'Pilih rentang transaksi',
      saveText: 'Simpan',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = picked;
      _period = ExportPeriodType.custom;
    });
  }

  Future<void> _share() async {
    final transactions =
        ref.read(transactionsStreamProvider).value ?? const [];
    final goals = ref.read(savingsGoalsStreamProvider).value ?? const [];
    final options = ExportOptions(
      format: _format,
      period: _period,
      delimiter: _delimiter,
      customStart: _customRange?.start,
      customEnd: _customRange?.end,
    );

    final success = await ref
        .read(exportControllerProvider.notifier)
        .export(
          options: options,
          transactions: transactions,
          goals: goals,
        );
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    final message = ref.read(exportControllerProvider).error?.toString() ??
        'Ekspor gagal. Coba lagi.';
    showSettingsSnackBar(context, message: message, isError: true);
  }

  String _rangeLabel(DateTimeRange range) {
    final start = formatDateShort(range.start);
    final end = formatDateShort(range.end);
    return '$start – $end';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ExportPreview {
  const _ExportPreview({
    required this.count,
    required this.message,
    this.start,
    this.end,
  });

  final int count;
  final DateTime? start;
  final DateTime? end;
  final String message;

  static _ExportPreview from({
    required ExportPeriodType period,
    required DateTimeRange? customRange,
    required List<TransactionEntity> transactions,
    required DateTime now,
    required int cycleDay,
  }) {
    if (period == ExportPeriodType.custom && customRange == null) {
      return const _ExportPreview(
        count: 0,
        message: 'Pilih rentang tanggal untuk membagikan file.',
      );
    }

    final resolved = const ResolveExportPeriodUseCase().execute(
      type: period,
      now: now,
      cycleDay: cycleDay,
      customStart: customRange?.start,
      customEnd: customRange?.end,
    );

    final dates = <DateTime>[
      for (final transaction in transactions)
        if (_matchesPeriod(
          transaction.date,
          resolved.start,
          resolved.end,
          resolved.isAllTime,
        ))
          DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          ),
    ]..sort();

    if (dates.isEmpty) {
      return const _ExportPreview(
        count: 0,
        message: 'Belum ada transaksi di periode ini.',
      );
    }

    final start = resolved.start ?? dates.first;
    final end = resolved.end ?? dates.last;
    final startText = formatDateShort(start);
    final endText = formatDateShort(end);
    final range = startText == endText ? startText : '$startText – $endText';

    return _ExportPreview(
      count: dates.length,
      start: start,
      end: end,
      message: '${dates.length} transaksi · $range',
    );
  }

  static bool _matchesPeriod(
    DateTime date,
    DateTime? start,
    DateTime? end,
    bool isAllTime,
  ) {
    if (isAllTime) return true;
    final value = DateTime(date.year, date.month, date.day);
    return start != null &&
        end != null &&
        !value.isBefore(DateTime(start.year, start.month, start.day)) &&
        !value.isAfter(DateTime(end.year, end.month, end.day));
  }
}

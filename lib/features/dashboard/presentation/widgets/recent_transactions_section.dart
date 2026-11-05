import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Transaksi terbaru di Beranda: maksimal lima baris tanpa kartu.
class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.onSeeAll,
    required this.onTransactionTap,
    required this.onAddTransaction,
  });

  final List<TransactionEntity> transactions;
  final VoidCallback onSeeAll;
  final ValueChanged<TransactionEntity> onTransactionTap;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Transaksi terbaru',
          actionLabel: recent.isEmpty ? null : 'Lihat semua',
          onAction: recent.isEmpty ? null : onSeeAll,
        ),
        if (recent.isEmpty)
          EmptyState(
            compact: true,
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada transaksi',
            message:
                'Catat pemasukan atau pengeluaran pertamamu untuk mulai '
                'melihat pola keuangan.',
            actionLabel: 'Catat transaksi',
            onAction: onAddTransaction,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          )
        else
          for (var i = 0; i < recent.length; i++)
            TransactionTile(
              category: recent[i].category,
              amount: recent[i].amount,
              isExpense: recent[i].isExpense,
              note: recent[i].note,
              timeLabel: _timeLabel(recent[i].date),
              onTap: () => onTransactionTap(recent[i]),
              showDivider: i != recent.length - 1,
              padding: EdgeInsets.zero,
            ),
      ],
    );
  }

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return formatDateShort(date);
  }
}

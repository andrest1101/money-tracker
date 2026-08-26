import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_providers.dart';
import '../widgets/transaction_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final theme = Theme.of(context);

    if (grouped.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada transaksi',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua transaksimu akan muncul di sini. '
                  'Yuk mulai catat pengeluaran atau pemasukan!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dates = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final transactions = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  date,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...transactions.map(
                (t) => Column(
                  children: [
                    TransactionTile(transaction: t),
                    const Divider(height: 1, indent: 68),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/generate_transactions_csv_usecase.dart';

class TransactionExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> export(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return false;

    state = const AsyncLoading();
    try {
      final csv = const GenerateTransactionsCsvUseCase().execute(transactions);
      final file = XFile.fromData(
        utf8.encode(csv),
        mimeType: 'text/csv',
        name: 'moneytracker-transaksi.csv',
      );
      await SharePlus.instance.share(
        ShareParams(files: [file], subject: 'Ekspor transaksi MoneyTracker'),
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

final transactionExportControllerProvider =
    NotifierProvider<TransactionExportController, AsyncValue<void>>(
      TransactionExportController.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/transaction_repository_provider.dart';
import '../../domain/entities/transaction_entity.dart';

class QuickAddController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addTransaction(transaction);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final quickAddControllerProvider =
    NotifierProvider<QuickAddController, AsyncValue<void>>(
  QuickAddController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/group_transactions_by_date_usecase.dart';

final _groupByDate = const GroupTransactionsByDateUseCase();

final groupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? const [];
  return _groupByDate.execute(transactions: transactions);
});

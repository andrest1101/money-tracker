import '../entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions();

  Future<void> addTransaction(TransactionEntity transaction);

  Future<void> updateTransaction(TransactionEntity transaction);

  Future<void> deleteTransaction(String id);
}

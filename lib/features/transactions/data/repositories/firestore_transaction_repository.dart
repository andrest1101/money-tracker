import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryException implements Exception {
  const TransactionRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'TransactionRepositoryException: $message'
      '${cause == null ? '' : ' | cause: $cause'}';
}

class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String collectionName = 'transactions';

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(collectionName);

  @override
  Stream<List<TransactionEntity>> watchTransactions() async* {
    try {
      yield* _transactionsRef.orderBy('date', descending: true).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      throw TransactionRepositoryException('Gagal memuat transaksi', e);
    }
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _transactionsRef.doc(model.id).set(model.toMap());
    } catch (e) {
      throw TransactionRepositoryException('Gagal menambahkan transaksi', e);
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _transactionsRef.doc(model.id).update(model.toMap());
    } catch (e) {
      throw TransactionRepositoryException('Gagal memperbarui transaksi', e);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRef.doc(id).delete();
    } catch (e) {
      throw TransactionRepositoryException('Gagal menghapus transaksi', e);
    }
  }
}

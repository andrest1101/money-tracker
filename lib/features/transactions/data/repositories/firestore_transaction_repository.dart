import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  FirestoreTransactionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String collectionName = 'transactions';

  CollectionReference<Map<String, dynamic>> get _transactionsRef {
    final user = _auth.currentUser;
    if (user == null) return _firestore.collection(collectionName);
    return _firestore.collection('users').doc(user.uid).collection(collectionName);
  }

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

  @override
  Future<TransactionEntity> getTransactionById(String id) async {
    try {
      final doc = await _transactionsRef.doc(id).get();
      if (!doc.exists) {
        throw const TransactionRepositoryException('Transaksi tidak ditemukan');
      }
      return TransactionModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      if (e is TransactionRepositoryException) rethrow;
      throw TransactionRepositoryException('Gagal mengambil transaksi', e);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../transactions/data/repositories/firestore_transaction_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepositoryException implements Exception {
  const SavingsGoalRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SavingsGoalRepositoryException: $message'
      '${cause == null ? '' : ' | cause: $cause'}';
}

class FirestoreSavingsGoalRepository implements SavingsGoalRepository {
  FirestoreSavingsGoalRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collectionName = 'savings_goals';

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection(_collectionName);

  @override
  Stream<List<SavingsGoalEntity>> watchGoals() async* {
    try {
      yield* _goalsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => SavingsGoalModel.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      throw SavingsGoalRepositoryException('Gagal memuat target tabungan', e);
    }
  }

  @override
  Future<void> addGoal(SavingsGoalEntity goal) async {
    try {
      final model = SavingsGoalModel.fromEntity(goal);
      await _goalsRef.doc(model.id).set(model.toMap());
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal menambahkan target tabungan',
        e,
      );
    }
  }

  @override
  Future<void> updateGoal(SavingsGoalEntity goal) async {
    try {
      final model = SavingsGoalModel.fromEntity(goal);
      await _goalsRef.doc(model.id).update(model.toMap());
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal memperbarui target tabungan',
        e,
      );
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _goalsRef.doc(id).delete();
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal menghapus target tabungan',
        e,
      );
    }
  }

  @override
  Future<void> deleteGoalWithAllocations(String goalId) async {
    try {
      final allocationDocs = await _firestore
          .collection(FirestoreTransactionRepository.collectionName)
          .where('goalId', isEqualTo: goalId)
          .get();

      // Keep a safety margin below Firestore's 500-operation batch limit.
      const batchSize = 450;
      for (var offset = 0; offset < allocationDocs.docs.length; offset += batchSize) {
        final end = (offset + batchSize).clamp(0, allocationDocs.docs.length);
        final batch = _firestore.batch();
        for (final doc in allocationDocs.docs.sublist(offset, end)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      final goalBatch = _firestore.batch();
      goalBatch.delete(_goalsRef.doc(goalId));
      await goalBatch.commit();
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal menghapus target dan alokasi tabungan',
        e,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      final goals = await _goalsRef.get();
      final transactions = await _firestore
          .collection(FirestoreTransactionRepository.collectionName)
          .get();
      final references = [
        ...goals.docs.map((doc) => doc.reference),
        ...transactions.docs.map((doc) => doc.reference),
      ];

      // Firestore membatasi satu WriteBatch maksimal 500 operasi.
      for (var offset = 0; offset < references.length; offset += 450) {
        final batch = _firestore.batch();
        final end = offset + 450 < references.length
            ? offset + 450
            : references.length;
        for (final reference in references.sublist(offset, end)) {
          batch.delete(reference);
        }
        await batch.commit();
      }
    } catch (e) {
      throw SavingsGoalRepositoryException('Gagal menghapus seluruh data', e);
    }
  }

  @override
  Future<SavingsGoalEntity> getGoalById(String id) async {
    try {
      final doc = await _goalsRef.doc(id).get();
      if (!doc.exists) {
        throw SavingsGoalRepositoryException('Target tabungan tidak ditemukan');
      }
      return SavingsGoalModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      if (e is SavingsGoalRepositoryException) rethrow;
      throw SavingsGoalRepositoryException(
        'Gagal mengambil target tabungan',
        e,
      );
    }
  }

  @override
  Future<void> allocateToGoal({
    required SavingsGoalEntity goal,
    required double newCurrentAmount,
    required TransactionEntity allocationTransaction,
  }) async {
    try {
      final transaction = TransactionModel.fromEntity(allocationTransaction);
      final goalReference = _goalsRef.doc(goal.id);
      final transactionReference = _firestore
          .collection(FirestoreTransactionRepository.collectionName)
          .doc(transaction.id);

      await _firestore.runTransaction((firestoreTransaction) async {
        final goalSnapshot = await firestoreTransaction.get(goalReference);
        if (!goalSnapshot.exists) {
          throw const SavingsGoalRepositoryException(
            'Target tabungan tidak ditemukan',
          );
        }

        final latestGoal = SavingsGoalModel.fromMap(
          goalSnapshot.id,
          goalSnapshot.data()!,
        );
        final updatedAmount = latestGoal.currentAmount + transaction.amount;
        if (updatedAmount > latestGoal.targetAmount) {
          throw const SavingsGoalRepositoryException(
            'Nominal alokasi melebihi sisa target tabungan',
          );
        }
        final updatedGoal = latestGoal.copyWith(
          currentAmount: updatedAmount,
        );

        firestoreTransaction.update(
          goalReference,
          SavingsGoalModel.fromEntity(updatedGoal).toMap(),
        );
        firestoreTransaction.set(transactionReference, transaction.toMap());
      });
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal mengalokasikan dana ke target',
        e,
      );
    }
  }

  @override
  Future<void> updateAllocation({
    required String goalId,
    required double newGoalAmount,
    required TransactionEntity updatedTransaction,
  }) async {
    try {
      final transaction = TransactionModel.fromEntity(updatedTransaction);
      final goalReference = _goalsRef.doc(goalId);
      final transactionReference = _firestore
          .collection(FirestoreTransactionRepository.collectionName)
          .doc(transaction.id);

      await _firestore.runTransaction((firestoreTransaction) async {
        final goalSnapshot = await firestoreTransaction.get(goalReference);
        final oldTransactionSnapshot =
            await firestoreTransaction.get(transactionReference);
        if (!goalSnapshot.exists) {
          throw const SavingsGoalRepositoryException(
            'Target tabungan tidak ditemukan',
          );
        }
        if (!oldTransactionSnapshot.exists) {
          throw const SavingsGoalRepositoryException(
            'Transaksi alokasi tidak ditemukan',
          );
        }

        final latestGoal = SavingsGoalModel.fromMap(
          goalSnapshot.id,
          goalSnapshot.data()!,
        );
        final oldTransaction = TransactionModel.fromMap(
          oldTransactionSnapshot.id,
          oldTransactionSnapshot.data()!,
        );
        final updatedAmount = latestGoal.currentAmount -
            oldTransaction.amount +
            transaction.amount;
        if (updatedAmount < 0) {
          throw const SavingsGoalRepositoryException(
            'Nominal edit membuat target tabungan negatif',
          );
        }
        if (updatedAmount > latestGoal.targetAmount) {
          throw const SavingsGoalRepositoryException(
            'Nominal alokasi melebihi target tabungan',
          );
        }
        final updatedGoal = latestGoal.copyWith(
          currentAmount: updatedAmount,
        );

        firestoreTransaction.update(
          goalReference,
          SavingsGoalModel.fromEntity(updatedGoal).toMap(),
        );
        firestoreTransaction.update(transactionReference, transaction.toMap());
      });
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal memperbarui alokasi tabungan',
        e,
      );
    }
  }

  @override
  Future<void> deleteAllocation({
    required String goalId,
    required double newGoalAmount,
    required String transactionId,
  }) async {
    try {
      final goalReference = _goalsRef.doc(goalId);
      final transactionReference = _firestore
          .collection(FirestoreTransactionRepository.collectionName)
          .doc(transactionId);

      await _firestore.runTransaction((firestoreTransaction) async {
        final goalSnapshot = await firestoreTransaction.get(goalReference);
        final allocationSnapshot =
            await firestoreTransaction.get(transactionReference);
        if (!goalSnapshot.exists) {
          throw const SavingsGoalRepositoryException(
            'Target tabungan tidak ditemukan',
          );
        }
        if (!allocationSnapshot.exists) {
          throw const SavingsGoalRepositoryException(
            'Transaksi alokasi tidak ditemukan',
          );
        }

        final latestGoal = SavingsGoalModel.fromMap(
          goalSnapshot.id,
          goalSnapshot.data()!,
        );
        final allocation = TransactionModel.fromMap(
          allocationSnapshot.id,
          allocationSnapshot.data()!,
        );
        final restoredAmount = latestGoal.currentAmount - allocation.amount;
        if (restoredAmount < 0) {
          throw const SavingsGoalRepositoryException(
            'Tidak dapat menghapus alokasi: saldo target menjadi negatif',
          );
        }
        final restoredGoal = latestGoal.copyWith(
          currentAmount: restoredAmount,
        );

        firestoreTransaction.update(
          goalReference,
          SavingsGoalModel.fromEntity(restoredGoal).toMap(),
        );
        firestoreTransaction.delete(transactionReference);
      });
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal menghapus alokasi tabungan',
        e,
      );
    }
  }
}

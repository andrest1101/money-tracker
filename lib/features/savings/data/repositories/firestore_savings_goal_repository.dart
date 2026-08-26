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
      yield* _goalsRef.orderBy('deadline').snapshots().map(
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
      throw SavingsGoalRepositoryException('Gagal menambahkan target tabungan', e);
    }
  }

  @override
  Future<void> updateGoal(SavingsGoalEntity goal) async {
    try {
      final model = SavingsGoalModel.fromEntity(goal);
      await _goalsRef.doc(model.id).update(model.toMap());
    } catch (e) {
      throw SavingsGoalRepositoryException('Gagal memperbarui target tabungan', e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _goalsRef.doc(id).delete();
    } catch (e) {
      throw SavingsGoalRepositoryException('Gagal menghapus target tabungan', e);
    }
  }

  @override
  Future<void> allocateToGoal({
    required SavingsGoalEntity goal,
    required double newCurrentAmount,
    required TransactionEntity allocationTransaction,
  }) async {
    try {
      final updatedGoal = SavingsGoalModel.fromEntity(
        goal.copyWith(currentAmount: newCurrentAmount),
      );
      final transaction = TransactionModel.fromEntity(allocationTransaction);

      final batch = _firestore.batch();
      batch.update(_goalsRef.doc(goal.id), updatedGoal.toMap());
      batch.set(
        _firestore
            .collection(FirestoreTransactionRepository.collectionName)
            .doc(transaction.id),
        transaction.toMap(),
      );

      await batch.commit();
    } catch (e) {
      throw SavingsGoalRepositoryException(
        'Gagal mengalokasikan dana ke target',
        e,
      );
    }
  }
}

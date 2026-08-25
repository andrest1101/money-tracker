import 'package:cloud_firestore/cloud_firestore.dart';

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
}

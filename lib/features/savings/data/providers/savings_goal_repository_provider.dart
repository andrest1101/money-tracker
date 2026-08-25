import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../repositories/firestore_savings_goal_repository.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return FirestoreSavingsGoalRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

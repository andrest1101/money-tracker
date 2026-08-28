import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).value ??
      ref.watch(firebaseAuthProvider).currentUser;
});

final anonymousAuthProvider = FutureProvider<User>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  final currentUser = auth.currentUser;
  if (currentUser != null) return currentUser;

  final credential = await auth.signInAnonymously();
  final user = credential.user;
  if (user == null) {
    throw StateError('Firebase Authentication tidak mengembalikan user');
  }
  return user;
});

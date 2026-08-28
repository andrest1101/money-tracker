import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  try {
    return ref.watch(authStateChangesProvider).value ??
        ref.watch(firebaseAuthProvider).currentUser;
  } catch (_) {
    // Keep non-authenticated UI renderable before Firebase bootstrap completes.
    return null;
  }
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

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> linkWithGoogle() async {
    state = const AsyncLoading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncData(null);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _linkCredential(credential);
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(
        'Login Google gagal. Periksa koneksi lalu coba lagi.',
        stackTrace,
      );
    }
  }

  Future<void> linkWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await _linkCredential(credential);
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Pembuatan akun gagal. Coba lagi.', stackTrace);
    }
  }

  Future<void> _linkCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sesi guest belum siap.',
      );
    }
    if (!user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'already-linked',
        message: 'Akun sudah diamankan.',
      );
    }
    await user.linkWithCredential(credential);
  }

  String _messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      'credential-already-in-use' || 'email-already-in-use' =>
        'Email tersebut sudah terdaftar. Gunakan email lain.',
      'weak-password' => 'Password terlalu mudah. Gunakan minimal 6 karakter.',
      'invalid-email' => 'Format email belum benar.',
      'account-exists-with-different-credential' =>
        'Email sudah terhubung dengan metode login lain.',
      'network-request-failed' => 'Koneksi bermasalah. Coba lagi.',
      'popup-closed-by-user' || 'canceled' => 'Login dibatalkan.',
      'already-linked' => 'Akun ini sudah diamankan.',
      _ => error.message ?? 'Autentikasi gagal. Coba lagi.',
    };
  }
}

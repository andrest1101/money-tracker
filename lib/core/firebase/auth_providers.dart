import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_storage/settings_providers.dart';

const _pendingEmailLinkEmailKey = 'pending_email_link_email';

final pendingEmailLinkEmailProvider = Provider<String?>((ref) {
  return ref
      .watch(sharedPreferencesProvider)
      .getString(_pendingEmailLinkEmailKey);
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  // userChanges also emits after User.reload(), allowing AuthGate to react
  // immediately when the user verifies the email.
  return ref.watch(firebaseAuthProvider).userChanges();
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

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> continueAsGuest() async {
    state = const AsyncLoading();
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        final credential = await _auth.signInAnonymously();
        if (credential.user == null) {
          throw StateError('Firebase tidak mengembalikan akun guest.');
        }
      }
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Mode guest gagal dimulai. Coba lagi.', stackTrace);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(
        'Login gagal. Periksa koneksi lalu coba lagi.',
        stackTrace,
      );
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.sendEmailVerification();
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Pendaftaran gagal. Coba lagi.', stackTrace);
    }
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'Sesi pengguna belum siap.',
        );
      }
      if (user.emailVerified) {
        state = const AsyncData(null);
        return;
      }
      await user.sendEmailVerification();
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(
        'Email verifikasi gagal dikirim. Coba lagi.',
        stackTrace,
      );
    }
  }

  Future<bool> reloadCurrentUser() async {
    state = const AsyncLoading();
    try {
      await _auth.currentUser?.reload();
      state = const AsyncData(null);
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
      return false;
    } catch (error, stackTrace) {
      state = AsyncError(
        'Status email gagal diperbarui. Coba lagi.',
        stackTrace,
      );
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Email reset password gagal dikirim.', stackTrace);
    }
  }

  Future<void> sendEmailLink(String email) async {
    state = const AsyncLoading();
    try {
      await _auth.sendSignInLinkToEmail(
        email: email.trim(),
        actionCodeSettings: ActionCodeSettings(
          url: Uri.https('money-tracker-e22c0.web.app', '/finishSignIn', {
            'email': email.trim(),
          }).toString(),
          handleCodeInApp: true,
          androidPackageName: 'com.example.money_tracker',
          androidInstallApp: true,
          androidMinimumVersion: '23',
        ),
      );
      await ref
          .read(sharedPreferencesProvider)
          .setString(_pendingEmailLinkEmailKey, email.trim());
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Link login gagal dikirim. Coba lagi.', stackTrace);
    }
  }

  Future<void> completeEmailLink({
    required String email,
    required String link,
  }) async {
    state = const AsyncLoading();
    try {
      if (!_auth.isSignInWithEmailLink(link)) {
        throw FirebaseAuthException(
          code: 'invalid-action-code',
          message: 'Link login tidak valid atau sudah kedaluwarsa.',
        );
      }
      final credential = EmailAuthProvider.credentialWithLink(
        email: email.trim(),
        emailLink: link.trim(),
      );
      final currentUser = _auth.currentUser;
      if (currentUser?.isAnonymous ?? false) {
        await currentUser!.linkWithCredential(credential);
      } else {
        await _auth.signInWithCredential(credential);
      }
      await ref
          .read(sharedPreferencesProvider)
          .remove(_pendingEmailLinkEmailKey);
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Link login tidak dapat digunakan.', stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _auth.signOut();
      if (!kIsWeb) await GoogleSignIn().signOut();
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Tidak dapat keluar dari akun.', stackTrace);
    }
  }

  Future<void> linkWithGoogle() async {
    state = const AsyncLoading();
    try {
      if (kIsWeb) {
        final user = _auth.currentUser;
        if (user == null || !user.isAnonymous) {
          throw FirebaseAuthException(
            code: 'already-linked',
            message: 'Akun sudah diamankan.',
          );
        }
        await user.linkWithPopup(GoogleAuthProvider());
      } else {
        final credential = await _googleCredential();
        if (credential == null) {
          state = const AsyncData(null);
          return;
        }
        await _linkCredential(credential);
      }
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } on PlatformException catch (error, stackTrace) {
      state = AsyncError(_googlePlatformMessage(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(
        'Login Google gagal (${error.runtimeType}). Periksa konfigurasi Google Sign-In lalu coba lagi.',
        stackTrace,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final credential = await _googleCredential();
        if (credential == null) {
          state = const AsyncData(null);
          return;
        }
        await _auth.signInWithCredential(credential);
      }
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
    } on PlatformException catch (error, stackTrace) {
      state = AsyncError(_googlePlatformMessage(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(
        'Login Google gagal (${error.runtimeType}). Periksa provider Google, SHA-1/SHA-256, lalu coba lagi.',
        stackTrace,
      );
    }
  }

  Future<AuthCredential?> _googleCredential() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  String _googlePlatformMessage(PlatformException error) {
    final code = error.code;
    if (code == '10' || code == 'sign_in_failed') {
      return 'Google Sign-In gagal (kode $code). Periksa SHA-1/SHA-256, package name, dan OAuth client Android di Firebase Console.';
    }
    if (code == '12501' || code == 'sign_in_canceled') {
      return 'Login Google dibatalkan.';
    }
    if (code == '7' || code == 'network_error') {
      return 'Google Sign-In tidak menemukan koneksi internet.';
    }
    return 'Google Sign-In gagal (kode $code). ${error.message ?? 'Periksa konfigurasi Firebase.'}';
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
      await _auth.currentUser?.sendEmailVerification();
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
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email atau password tidak sesuai.',
      'user-disabled' => 'Akun ini dinonaktifkan.',
      'expired-action-code' ||
      'invalid-action-code' => 'Link login tidak valid atau sudah kedaluwarsa.',
      'account-exists-with-different-credential' =>
        'Email sudah terhubung dengan metode login lain.',
      'network-request-failed' => 'Koneksi bermasalah. Coba lagi.',
      'popup-closed-by-user' || 'canceled' => 'Login dibatalkan.',
      'already-linked' => 'Akun ini sudah diamankan.',
      _ => error.message ?? 'Autentikasi gagal. Coba lagi.',
    };
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/errors/app_error_message.dart';

void main() {
  group('appErrorMessage', () {
    test('maps Firestore permission errors without exposing internals', () {
      expect(
        appErrorMessage(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        'Kamu tidak memiliki akses ke data ini.',
      );
    });

    test('maps unavailable services to a connection message', () {
      expect(
        appErrorMessage(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
        'Koneksi bermasalah. Periksa internet lalu coba lagi.',
      );
    });

    test('uses a safe fallback for unknown errors', () {
      expect(
        appErrorMessage(StateError('private implementation detail')),
        'Terjadi kesalahan. Coba lagi.',
      );
    });
  });

  group('authErrorMessage', () {
    test('tells the user when a sign-in provider is disabled', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'operation-not-allowed')),
        'Metode login ini belum diaktifkan di Firebase Console.',
      );
    });

    test('points invalid API keys to the Firebase configuration files', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'invalid-api-key')),
        contains('firebase_options.dart'),
      );
    });

    test('explains unauthorized domains for web authentication', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'unauthorized-domain')),
        contains('Domain aplikasi ini belum diizinkan'),
      );
    });

    test('separates an existing email from a linked credential', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'email-already-in-use')),
        contains('Masuk atau gunakan email lain'),
      );
      expect(
        authErrorMessage(
          FirebaseAuthException(code: 'credential-already-in-use'),
        ),
        contains('metode login lain'),
      );
    });

    test('keeps invalid credentials vague for account safety', () {
      final message = authErrorMessage(
        FirebaseAuthException(code: 'invalid-credential'),
      );
      expect(message, 'Email atau password tidak sesuai.');
      expect(message, isNot(contains('user-not-found')));
    });

    test('does not leak raw Firebase messages', () {
      expect(
        authErrorMessage(
          FirebaseAuthException(
            code: 'internal-error',
            message: 'private implementation detail',
          ),
        ),
        'Terjadi kesalahan. Coba lagi.',
      );
    });

    test('maps cancelled popups to a short message', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'popup-closed-by-user')),
        'Login dibatalkan.',
      );
    });
  });

  group('googleSignInErrorMessage', () {
    test('turns DEVELOPER_ERROR into SHA registration guidance', () {
      final message = googleSignInErrorMessage(
        PlatformException(
          code: 'sign_in_failed',
          message:
              'com.google.android.gms.common.api.ApiException: 10: DEVELOPER_ERROR',
        ),
      );
      expect(message, contains('SHA-1/SHA-256'));
      expect(message, contains('google-services.json'));
    });

    test('recognizes the numeric code 10', () {
      expect(
        googleSignInErrorMessage(PlatformException(code: '10')),
        contains('kode 10'),
      );
    });

    test('maps user cancellation', () {
      expect(
        googleSignInErrorMessage(PlatformException(code: '12501')),
        'Login Google dibatalkan.',
      );
    });

    test('maps missing connectivity', () {
      expect(
        googleSignInErrorMessage(PlatformException(code: 'network_error')),
        'Google Sign-In tidak menemukan koneksi internet.',
      );
    });

    test('falls back without exposing plugin internals', () {
      expect(
        googleSignInErrorMessage(
          PlatformException(code: 'unknown', message: 'private detail'),
        ),
        'Terjadi kesalahan. Coba lagi.',
      );
    });
  });
}

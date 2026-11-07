import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

const _defaultFallback = 'Terjadi kesalahan. Coba lagi.';

/// Mengubah error teknis menjadi pesan yang aman dan bisa ditindaklanjuti.
///
/// Detail internal (misalnya pesan mentah dari Firebase) tidak pernah
/// ditampilkan langsung ke pengguna.
String appErrorMessage(Object error, {String fallback = _defaultFallback}) {
  if (error is FirebaseAuthException) {
    return authErrorMessage(error, fallback: fallback);
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'Kamu tidak memiliki akses ke data ini.',
      'unavailable' || 'network-request-failed' =>
        'Koneksi bermasalah. Periksa internet lalu coba lagi.',
      'deadline-exceeded' => 'Server terlalu lama merespons. Coba lagi.',
      'not-found' => 'Data yang diminta tidak ditemukan.',
      'already-exists' => 'Data tersebut sudah ada.',
      'failed-precondition' => 'Operasi belum dapat dilakukan saat ini.',
      _ => fallback,
    };
  }
  if (error is PlatformException && _isGoogleSignInCode(error)) {
    return googleSignInErrorMessage(error, fallback: fallback);
  }
  if (error is FormatException) return error.message;
  if (error.toString().contains('Sesi pengguna belum siap')) {
    return 'Sesi pengguna belum siap. Coba lagi.';
  }
  return fallback;
}

/// Pesan untuk kegagalan masuk memakai email dan password.
///
/// Proyek Firebase dengan email enumeration protection dapat mengembalikan
/// kode `INVALID_LOGIN_CREDENTIALS` (huruf besar) alih-alih
/// `invalid-credential`. Kode tersebut tidak tertangkap oleh
/// [authErrorMessage] sehingga sebelumnya jatuh ke fallback generik.
///
/// Semua varian kredensial dipetakan ke satu pesan yang bisa ditindaklanjuti
/// tanpa membocorkan apakah email terdaftar atau password-nya yang salah.
String emailPasswordSignInErrorMessage(FirebaseAuthException error) {
  final code = error.code.toLowerCase();
  final message = (error.message ?? '').toLowerCase();

  const credentialCodes = {
    'invalid-credential',
    'invalid-credentials',
    'invalid-login-credentials',
    'invalid_login_credentials',
    'wrong-password',
    'user-not-found',
    'invalid-password',
  };

  final looksLikeCredentialFailure =
      credentialCodes.contains(code) ||
      message.contains('invalid_login_credentials') ||
      message.contains('invalid login credentials') ||
      message.contains('invalid_password') ||
      message.contains('wrong password') ||
      message.contains('email_not_found') ||
      message.contains('user not found');

  if (looksLikeCredentialFailure) {
    return 'Email atau password salah. Periksa kembali lalu coba lagi.';
  }

  return authErrorMessage(
    error,
    fallback: 'Login gagal karena kendala sistem. Coba lagi.',
  );
}

/// Pesan khusus kegagalan [FirebaseAuthException].
String authErrorMessage(
  FirebaseAuthException error, {
  String fallback = _defaultFallback,
}) {
  return switch (error.code) {
    'network-request-failed' => 'Koneksi bermasalah. Coba lagi.',
    'too-many-requests' =>
      'Terlalu banyak percobaan dari perangkat ini. Tunggu beberapa saat sebelum mencoba lagi.',
    'invalid-email' => 'Format email belum benar.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email atau password tidak sesuai.',
    'user-disabled' => 'Akun ini dinonaktifkan.',
    'email-already-in-use' =>
      'Email tersebut sudah terdaftar. Masuk atau gunakan email lain.',
    'credential-already-in-use' =>
      'Email tersebut sudah terdaftar di metode login lain.',
    'weak-password' => 'Password terlalu mudah. Gunakan minimal 6 karakter.',
    'operation-not-allowed' =>
      'Metode login ini belum diaktifkan di Firebase Console.',
    'invalid-api-key' || 'api-key-not-valid' =>
      'Konfigurasi Firebase tidak valid (API key). Periksa firebase_options.dart dan google-services.json.',
    'unauthorized-domain' =>
      'Domain aplikasi ini belum diizinkan di Firebase Authentication.',
    'account-exists-with-different-credential' =>
      'Email sudah terhubung dengan metode login lain. Masuk memakai metode tersebut.',
    'requires-recent-login' =>
      'Sesi sudah terlalu lama. Keluar lalu masuk kembali untuk melanjutkan.',
    'expired-action-code' ||
    'invalid-action-code' => 'Link login tidak valid atau sudah kedaluwarsa.',
    'missing-android-package-name' ||
    'missing-continue-uri' ||
    'missing-ios-bundle-id' =>
      'Konfigurasi link login belum lengkap. Periksa pengaturan email link di Firebase Console.',
    'popup-closed-by-user' || 'canceled' || 'cancelled' => 'Login dibatalkan.',
    'already-linked' => 'Akun ini sudah diamankan.',
    'no-current-user' => 'Sesi pengguna belum siap. Coba lagi.',
    _ => fallback,
  };
}

/// Pesan khusus kegagalan plugin `google_sign_in` di Android.
///
/// Kode `10` (DEVELOPER_ERROR) hampir selalu berarti SHA-1/SHA-256 dari
/// keystore yang dipakai build ini belum terdaftar di Firebase/Google Cloud.
String googleSignInErrorMessage(
  PlatformException error, {
  String fallback = _defaultFallback,
}) {
  final code = error.code.toLowerCase();
  final message = (error.message ?? '').toLowerCase();
  final isDeveloperError =
      code == '10' ||
      message.contains('apiexception: 10') ||
      message.contains('developer_error');

  if (isDeveloperError) {
    return 'Google Sign-In ditolak (kode 10). SHA-1/SHA-256 build ini belum terdaftar di Firebase Console. '
        'Tambahkan fingerprint keystore tersebut, unduh ulang google-services.json, lalu build ulang.';
  }
  if (code == '12501' || code == 'sign_in_canceled') {
    return 'Login Google dibatalkan.';
  }
  if (code == '12500' || code == 'sign_in_failed') {
    return 'Google Sign-In gagal. Pastikan provider Google aktif dan OAuth client Android cocok dengan package name serta SHA keystore.';
  }
  if (code == '7' || code == 'network_error') {
    return 'Google Sign-In tidak menemukan koneksi internet.';
  }
  return fallback;
}

bool _isGoogleSignInCode(PlatformException error) {
  const codes = {
    '10',
    '7',
    '12500',
    '12501',
    'sign_in_failed',
    'sign_in_canceled',
    'network_error',
  };
  return codes.contains(error.code.toLowerCase()) ||
      (error.message ?? '').toLowerCase().contains('apiexception');
}

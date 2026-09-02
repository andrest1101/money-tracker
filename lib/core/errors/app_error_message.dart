import 'package:firebase_auth/firebase_auth.dart';

String appErrorMessage(
  Object error, {
  String fallback = 'Terjadi kesalahan. Coba lagi.',
}) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' => 'Koneksi bermasalah. Coba lagi.',
      'too-many-requests' => 'Terlalu banyak percobaan. Tunggu beberapa saat.',
      _ => fallback,
    };
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
  if (error is FormatException) return error.message;
  if (error.toString().contains('Sesi pengguna belum siap')) {
    return 'Sesi pengguna belum siap. Coba lagi.';
  }
  return fallback;
}

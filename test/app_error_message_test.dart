import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_tracker/core/errors/app_error_message.dart';

void main() {
  test('maps Firestore permission errors without exposing internals', () {
    expect(
      appErrorMessage(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
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
}

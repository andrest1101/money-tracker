import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_message.dart';

/// Mengambil pesan error autentikasi yang aman untuk ditampilkan.
///
/// [AuthController] menyimpan pesan yang sudah ramah pengguna sebagai String,
/// tetapi helper ini tetap menjaga kompatibilitas bila suatu saat error mentah
/// ikut tersimpan.
String? authErrorText(AsyncValue<void> state) {
  final error = state.error;
  if (error == null) return null;
  if (error is String) return error;
  return appErrorMessage(error);
}

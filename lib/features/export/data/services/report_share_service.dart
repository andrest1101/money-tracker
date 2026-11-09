import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Membungkus `share_plus` agar repository tidak terikat langsung ke plugin.
class ReportShareService {
  const ReportShareService();

  Future<void> shareFile({
    required Uint8List bytes,
    required String name,
    required String mimeType,
    required String subject,
  }) async {
    final file = XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: name,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        subject: subject,
        // `XFile.name` diabaikan di Android/iOS, jadi nama eksplisit diberikan
        // lewat override ini agar WhatsApp/Excel menerima nama file yang jelas.
        fileNameOverrides: [name],
      ),
    );
  }
}

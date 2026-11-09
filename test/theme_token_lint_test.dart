import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga token Dompetku.
///
/// Mencegah literal warna, ukuran teks, dan penggunaan `Colors.*` yang tidak
/// terkontrol masuk kembali ke kode feature setelah pembersihan Batch A–C.
/// Allowlist hanya berisi warna konten statis yang memang tidak mengikuti
/// tema (ilustrasi, palet avatar, brand ikon); semuanya didokumentasikan.
const _colorAllowlist = <String>{
  // Aksen ilustrasi onboarding (seni, bukan palet UI).
  'lib/features/onboarding/presentation/pages/onboarding_page.dart',
  'lib/features/onboarding/presentation/widgets/onboarding_slide.dart',
  // Palet avatar preset (memakai foreground kontras tersendiri).
  'lib/features/settings/presentation/widgets/profile_avatar_sheet.dart',
  // Warna brand Gmail dan WhatsApp.
  'lib/features/settings/presentation/widgets/contact_us_entry.dart',
};

/// Spreadsheet XLSX memakai ukuran font dalam satuan poin, bukan textTheme
/// Flutter. Allowlist ini hanya untuk writer laporan Excel.
const _fontSizeAllowlist = <String>{
  'lib/features/export/data/exporters/xlsx_exporter.dart',
};

/// Beranda dijalankan oleh test runner Flutter dari root proyek.
final _libFiles = Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .map((file) => file.path.replaceAll('\\', '/'))
    .where((path) => path.endsWith('.dart'))
    .toList();

List<String> _violations(String pattern, bool Function(String path) skip) {
  final violations = <String>[];
  for (final path in _libFiles) {
    if (skip(path)) continue;
    final lines = File(path).readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      if (RegExp(pattern).hasMatch(lines[index])) {
        violations.add('$path:${index + 1}: ${lines[index].trim()}');
      }
    }
  }
  return violations;
}

void main() {
  test('tidak ada Color(0x...) literal di luar theme dan allowlist', () {
    final violations = _violations(
      'Color\\(0x',
      (path) =>
          path.startsWith('lib/core/theme/') || _colorAllowlist.contains(path),
    );
    expect(
      violations,
      isEmpty,
      reason:
          'Gunakan token di lib/core/theme (AppColors / ColorScheme). Jika memang '
          'perlu literal (mis. palet ilustrasi), tambahkan file ke _colorAllowlist '
          'beserta alasannya.\n${violations.join('\n')}',
    );
  });

  test('tidak ada fontSize: literal di luar core/theme', () {
    final violations = _violations(
      'fontSize:',
      (path) =>
          path.startsWith('lib/core/theme/') ||
          _fontSizeAllowlist.contains(path),
    );
    expect(
      violations,
      isEmpty,
      reason:
          'Gunakan textTheme / AppTextStyles dari lib/core/theme, bukan fontSize '
          'mentah. Untuk writer XLSX lihat _fontSizeAllowlist.\n'
          '${violations.join('\n')}',
    );
  });

  test('hanya Colors.transparent yang diperbolehkan di luar core/theme', () {
    final violations = _violations(
      '\\bColors\\.(?!transparent)',
      (path) => path.startsWith('lib/core/theme/'),
    );
    expect(
      violations,
      isEmpty,
      reason:
          'Colors.* di luar theme harus melalui token (AppColors / '
          'context.appColors).\n${violations.join('\n')}',
    );
  });

  test('tidak ada referensi skema gelap yang tersisa', () {
    final violations = _violations(
      'AppColors\\.dark|_darkScheme',
      (_) => false,
    );
    expect(
      violations,
      isEmpty,
      reason:
          'Dompetku hanya punya tema terang. Hapus sisa skema gelap.'
          '\n${violations.join('\n')}',
    );
  });
}

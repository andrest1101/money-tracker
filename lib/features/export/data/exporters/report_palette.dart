import 'package:excel_community/excel_community.dart';

/// Warna laporan XLSX.
///
/// Nilai diambil dari token produk (lihat `lib/core/theme/app_theme.dart`)
/// agar laporan konsisten dengan aplikasi. Excel tidak membaca ThemeData,
/// jadi nilainya disalin sebagai hex dan dijaga sebagai sumber tunggal.
abstract final class ReportPalette {
  static final ExcelColor brand = ExcelColor.fromHexString('FF315B7D');
  static final ExcelColor brandLight = ExcelColor.fromHexString('FFE2EBF3');
  static final ExcelColor onBrand = ExcelColor.fromHexString('FFFFFFFF');

  static final ExcelColor text = ExcelColor.fromHexString('FF151B23');
  static final ExcelColor muted = ExcelColor.fromHexString('FF596575');
  static final ExcelColor outline = ExcelColor.fromHexString('FFDDE2E8');
  static final ExcelColor surface = ExcelColor.fromHexString('FFEDF0F4');
  static final ExcelColor surfaceSoft = ExcelColor.fromHexString('FFF6F7F9');

  static final ExcelColor income = ExcelColor.fromHexString('FF12804A');
  static final ExcelColor success = ExcelColor.fromHexString('FF047857');
  static final ExcelColor danger = ExcelColor.fromHexString('FFC73A32');
}

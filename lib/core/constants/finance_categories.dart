/// Kategori sistem yang dipakai lintas fitur.
///
/// Nilai ini disimpan sebagai teks di Firestore, jadi jangan mengubah string
/// tanpa migrasi data lama.
abstract final class FinanceCategories {
  /// Penanda transaksi alokasi dana ke target tabungan.
  static const String savingsAllocation = 'Alokasi Tabungan';

  /// Awalan catatan transaksi alokasi yang dibuat otomatis.
  static const String savingsAllocationNotePrefix = 'Menabung untuk ';

  /// Catatan standar untuk transaksi alokasi target tabungan.
  static String savingsAllocationNote(String goalTitle) {
    return '$savingsAllocationNotePrefix$goalTitle';
  }
}

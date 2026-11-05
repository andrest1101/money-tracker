/// Label bersama yang dipakai lintas fitur.
///
/// Copy spesifik layar tetap tinggal di widget layarnya agar tidak menjadi
/// tempat sampah string. Hanya label yang benar-benar dipakai bersama yang
/// dikumpulkan di sini.
abstract final class AppStrings {
  // Aksi umum
  static const String delete = 'Hapus';
  static const String reset = 'Reset';
  static const String apply = 'Terapkan';
  static const String cancel = 'Batal';

  // Filter
  static const String filterTitle = 'Filter';
  static const String filterDescription =
      'Atur periode, kategori, dan siklus anggaran.';
  static const String period = 'Periode';
  static const String category = 'Kategori';
  static const String activeCycle = 'Siklus anggaran aktif';
  static const String activeCycleDescription =
      'Hanya transaksi dalam periode anggaran berjalan.';
  static const String allTime = 'Semua waktu';
  static const String last7Days = '7 hari';
  static const String last30Days = '30 hari';
  static const String customRange = 'Rentang tanggal';
  static const String pickRange = 'Pilih rentang tanggal';
  static const String allCategories = 'Semua kategori';
  static const String rangeTooLong = 'Rentang maksimal 31 hari.';
  static const String rangeRequired = 'Pilih rentang tanggal dulu.';

  // Target tabungan
  static const String editGoal = 'Edit target';
  static const String archiveGoal = 'Arsipkan target';
  static const String unarchiveGoal = 'Kembalikan dari arsip';
  static const String deleteGoal = 'Hapus target';
  static const String allocateFund = 'Alokasikan dana';
  static const String goalActions = 'Aksi target';
  static const String goalCompleted = 'Target tercapai!';
  static const String goalOverdue = 'Tenggat terlewat';
}

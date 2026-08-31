# Roadmap Perbaikan MoneyTracker

Dokumen ini adalah sumber kebenaran untuk pekerjaan lanjutan MoneyTracker.
Perbarui status setiap kali sebuah tahap selesai agar sesi berikutnya dapat
langsung melanjutkan tanpa mengulang analisis.

Status yang digunakan: `Belum dimulai`, `Berjalan`, `Selesai`, `Ditunda`.

## Status Saat Ini

| Area | Tahap aktif | Status |
| --- | --- | --- |
| Dashboard | Balance Card Overview dan Budget Overview interaktif | Selesai |
| Analytics | Konsistensi periode chart | Selesai |
| Savings | Edit target tabungan | Selesai |
| History | Redesign dasar dan filter | Selesai |
| Navigation | Floating pill, center action, dan transisi | Selesai |
| Quality | Test suite dan Windows allocation workaround | Berjalan |

## A. Dashboard dan Interaksi Detail

### A1. Balance Card Overview

- Status: `Selesai`
- Jadikan Balance Card dapat diketuk.
- Buat bottom sheet detail saldo siklus aktif.
- Tampilkan pemasukan, pengeluaran, saldo bersih, jumlah transaksi, dan periode.
- Tampilkan kategori pengeluaran terbesar jika tersedia.
- Hormati Privacy Mode untuk seluruh nominal di overview.
- Implementasi: `_BalanceOverviewSheet` di `dashboard_page.dart`.
- Catatan: current amount allocation tidak dihitung sebagai pengeluaran terbesar.

### A2. Budget Overview Interaktif

- Status: `Selesai`
- Jadikan metric transaksi dapat membuka History dengan filter siklus aktif.
- Tambahkan detail perhitungan rata-rata pengeluaran harian.
- Tambahkan detail proyeksi akhir periode.
- Jadikan kategori terbesar dapat membuka History berdasarkan kategori.
- Header Status Anggaran dibuat statis; hanya body status/progress yang menjadi
  satu interaction surface untuk membuka overview.
- Metric transaksi dan kategori di dalam overview memiliki jalur langsung ke
  History dengan filter yang sesuai.

### A3. Dashboard Polish

- Status: `Belum dimulai`
- Pastikan semua card memiliki hierarchy, spacing, dan hit target konsisten.
- Tambahkan feedback visual saat card dapat diketuk.
- Audit empty, loading, error, dan retry state setiap section.

## B. Analytics dan Chart Keuangan

### B1. Konsistensi Periode Chart

- Status: `Selesai`
- Samakan detail pie chart dengan budget cycle aktif.
- Pastikan siklus lintas bulan tidak menghasilkan angka berbeda.
- Tambahkan test chart untuk siklus tanggal 25 sampai 24.
- Summary dan category aggregation sekarang menerima rentang tanggal inklusif.
- Provider Dashboard memakai periode budget cycle yang sama.
- Detail pie chart mengikuti budget cycle dan batas akhir hari.
- Regression test tersedia di `test/calculate_cycle_summary_usecase_test.dart`.

### B2. Cash Flow Chart

- Status: `Selesai`
- Buat use case agregasi pemasukan dan pengeluaran per hari/minggu.
- Tampilkan bar chart memakai `fl_chart`.
- Sediakan filter 7 hari, 30 hari, dan siklus aktif.
- Sediakan empty state saat data belum cukup.
- Implementasi tersedia di `features/analytics`.
- Tooltip menampilkan nominal dengan format Rupiah bertitik.
- Chart memakai data harian inklusif dari periode yang dipilih.
- Chart tidak lagi menjadi card terpisah di Dashboard.
- Preview arus kas sekarang menjadi bagian dari Financial Insight Card dan
  detail lengkapnya dibuka melalui overview card tersebut.

### B2.1 Financial Insight Overview

- Status: `Selesai`
- Card Insight Keuangan sekarang dapat diketuk untuk membuka overview detail.
- Overview menampilkan pemasukan, pengeluaran, saldo bersih, perbandingan
  dengan periode sebelumnya, chart pengeluaran tujuh hari, top kategori, rata-rata
  harian, dan jumlah transaksi.
- Perhitungan mengikuti budget cycle aktif.
- Implementasi berada di `financial_insight_overview_sheet.dart`.
- Polish UI: hierarchy header, surface card, border accent, semantic emerald
  coloring, dan tooltip chart dengan format Rupiah bertitik.

### B2.2 Expense Flow Chart Overview

- Status: `Selesai`
- Preview chart arus pengeluaran di Financial Insight Card sekarang memiliki
  hit target dan feedback hover/splash sendiri.
- Klik chart membuka overview khusus yang menampilkan total pengeluaran,
  rata-rata harian, hari aktif, puncak pengeluaran, rincian setiap hari, dan
  rekomendasi finansial berdasarkan pola pengeluaran.
- Detail memakai format Rupiah bertitik dan tetap mengikuti rentang tujuh hari
  terakhir dari preview chart.
- Implementasi berada di `expense_flow_insight_entity.dart`,
  `calculate_expense_flow_insight_usecase.dart`, dan
  `expense_flow_overview_sheet.dart`.
- Preview chart kecil kemudian dihapus dari Dashboard untuk mengurangi duplikasi
  visual; chart lengkap hanya muncul setelah user membuka body Insight Card.
- Insight Card sekarang menjadi satu entry point yang ringkas menuju seluruh
  detail analitik.

### B3. Balance Trend Chart

- Status: `Selesai`
- Buat use case tren saldo kumulatif.
- Tampilkan line chart dengan tooltip tanggal dan saldo.
- Tampilkan insight tren naik, stabil, atau menurun.
- Implementasi tersedia di `features/analytics` dan menggunakan range yang sama
  dengan Cash Flow Chart.
- Test agregasi tren saldo tersedia di `test/calculate_balance_trend_usecase_test.dart`.

### B4. Analytics Page

- Status: `Ditunda`
- Buat halaman Analitik khusus setelah chart dasar stabil.
- Satukan cash flow, balance trend, category breakdown, dan top spending.
- Tentukan akses dari Dashboard terlebih dahulu sebelum menambah tab navigation.
- Akses halaman penuh ditunda agar Dashboard tidak memiliki terlalu banyak
  chart dan user memiliki satu entry point analitik melalui Insight Card.
- `AnalyticsPage` dan Balance Trend tetap tersedia sebagai fondasi lanjutan,
  tetapi belum ditampilkan pada navigation atau Dashboard.

## C. Savings Goals

### C1. Edit Target Tabungan

- Status: `Selesai`
- User dapat mengubah nama, nominal target, dan deadline.
- Current amount serta riwayat alokasi tidak berubah.
- Target baru boleh lebih kecil dari dana terkumpul dan otomatis selesai.
- Validasi nominal positif, judul wajib, dan deadline tidak boleh lewat.

### C2. Savings Polish

- Status: `Belum dimulai`
- Audit spacing goal card pada layar kecil.
- Perjelas state target selesai, deadline dekat, dan overdue.
- Tambahkan feedback loading/error yang konsisten.
- Pertimbangkan ringkasan total dana seluruh target.

### C2.1 Success Celebration

- Status: `Selesai`
- Alokasi terakhir yang memenuhi target menampilkan dialog perayaan sebelum
  sheet alokasi ditutup dan target berpindah ke tab Selesai.
- Dialog memakai trophy badge, animasi confetti 1,6 detik, dan tombol
  `Lanjutkan` yang dapat ditekan user.
- Implementasi berada di `goal_celebration_dialog.dart` dan memakai package
  `confetti`.
- Kontras SnackBar Settings diperbaiki dengan foreground/background eksplisit
  pada perubahan tema light/dark.
- Header card kategori pengeluaran kini memiliki aksi `Lihat detail` yang benar-
  benar dapat diketuk.

## D. Transaction History

### D1. History Polish

- Status: `Selesai sebagian`
- Header, search, filter, grouped daily card, dan transaction tile sudah dipoles.
- Filter siklus aktif tidak boleh menabrakkan icon refresh dan checkmark.
- Lakukan validasi visual pada Android kecil dan Windows.

### D1.1 Custom Date Range History

- Status: `Selesai`
- User dapat memilih rentang tanggal custom secara inklusif.
- Rentang maksimal 31 hari dan range yang lebih panjang ditolak.
- Filter tanggal dapat digabung dengan search, tipe, kategori, dan siklus aktif.
- Ditambahkan ringkasan jumlah hari dan label filter aktif.
- Regression test tersedia di `test/history_date_range_test.dart` dan
  `test/filter_transactions_usecase_test.dart`.

### D2. History Detail

- Status: `Belum dimulai`
- Pertimbangkan detail transaksi sebagai bottom sheet yang lebih informatif.
- Tambahkan shortcut edit dan hapus yang tetap aman untuk allocation transaction.
- Pertimbangkan export berdasarkan filter aktif.

### D1.2 Budget Overview to History

- Status: `Selesai`
- Budget Overview dapat mengirim intent navigasi ke tab History.
- Klik transaksi membuka History dengan filter siklus aktif.
- Klik kategori terbesar membuka History dengan filter kategori dan siklus aktif.
- Intent diterapkan satu kali setelah History siap dirender.

## E. Navigation dan Global UI

### E1. Floating Navigation

- Status: `Selesai`
- Floating pill dengan empat menu dan tombol aksi tengah sudah tersedia.
- Tombol aksi menyediakan Buat Catatan Baru dan Buat Target Tabungan Baru.
- `extendBody: true` sudah digunakan.

### E2. Page Transition

- Status: `Selesai`
- Perpindahan halaman memakai fade dan slide halus.
- Pastikan state form tidak hilang secara tidak sengaja saat berpindah tab.

### E3. Visual Foundation

- Status: `Berjalan`
- Tema emerald/teal tetap menjadi identitas utama.
- Font Inter digunakan dengan weight yang lebih mudah dibaca.
- Background harus tetap clean dan tidak memakai orb, circle, grid, atau dot pattern.
- Audit kontras dan ukuran teks kecil pada perangkat Android.
- SnackBar global kini memakai `inverseSurface` dan `onInverseSurface` agar
  teks tetap terbaca saat tema berpindah light/dark.
- Card kategori pengeluaran memiliki header yang benar-benar clickable untuk
  membuka detail kategori; affordance jari diganti label `Lihat detail`.
- Helper SnackBar Settings menetapkan foreground icon dan teks secara eksplisit
  untuk mode sukses maupun error.

## F. Reliability dan Sistem

### F1. Firestore Error State Audit

- Status: `Selesai sebagian`
- Audit seluruh stream/provider untuk loading, error, empty, dan retry.
- Pastikan pesan error tidak membocorkan data sensitif.
- Pastikan setiap operasi Firestore memakai try-catch.
- Error mapper terpusat tersedia di `core/errors/app_error_message.dart`.
- Action transaksi dan target sekarang menyimpan pesan user-friendly pada
  `AsyncError`, termasuk permission, koneksi, timeout, dan session error.
- Sheet transaksi, tambah/edit target, dan alokasi menampilkan pesan error
  hasil mapping, bukan detail exception internal.
- Stream error dan retry UI telah tersedia pada Dashboard, History, Savings,
  dan chart; audit lanjutan untuk seluruh Settings/Auth tetap diperlukan.

### F2. Windows Firestore Compatibility

- Status: `Berjalan`
- Windows memakai WriteBatch untuk allocation create/edit/delete karena bug native
  `runTransaction` pada cloud_firestore Windows 5.6.x.
- Android, iOS, dan Web tetap memakai Firestore transaction atomik.
- Validasi manual wajib dilakukan pada executable Windows hasil build terbaru.

### F3. Authentication dan Security

- Status: `Selesai sebagian`
- Anonymous auth dan user-scoped Firestore sudah diterapkan.
- Google Sign-In dan deployment rules masih memerlukan validasi Console/device.
- Deep link Email Link perlu validasi debug dan release Android.

## G. Testing dan Release

### G1. Automated Test

- Status: `Berjalan`
- Jalankan `flutter analyze` sebelum setiap commit.
- Jalankan `flutter test` sebelum setiap commit.
- Tambahkan test setiap kali use case atau alur utama baru dibuat.

### G2. Responsive Validation

- Status: `Belum dimulai`
- Validasi Android kecil, Android besar, Windows, dan Web.
- Cek text scaling, overflow, tap target, keyboard, dan bottom sheet.

### G3. Release Checklist

- Status: `Belum dimulai`
- Build Android debug/release.
- Build Windows debug.
- Build Web.
- Deploy Firestore rules dan Hosting.
- Validasi Auth, deep link, Firestore path, dan data isolation.

## Urutan Eksekusi yang Disarankan

1. Selesaikan A1 Balance Card Overview.
2. Selesaikan A2 Budget Overview Interaktif.
3. Selesaikan B1 konsistensi periode chart.
4. Buat B2 Cash Flow Chart.
5. Buat B3 Balance Trend Chart.
6. Buat B4 Analytics Page jika chart dasar sudah stabil.
7. Kerjakan C2 Savings Polish.
8. Kerjakan D2 History Detail.
9. Tutup F1, F3, G2, dan G3 sebelum release.

## Aturan Sesi

- Jangan membuat commit otomatis.
- Jangan menghapus perubahan lokal yang belum di-commit.
- Satu tahap harus diverifikasi dengan analyzer dan test sebelum pindah tahap.
- Setelah fitur selesai, update status dokumen ini.

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
- Implementasi: metric budget menampilkan dialog penjelasan saat diketuk.
- Catatan: integrasi deep-link filter langsung ke History menjadi tahap lanjutan.

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

- Status: `Belum dimulai`
- Buat use case agregasi pemasukan dan pengeluaran per hari/minggu.
- Tampilkan bar chart memakai `fl_chart`.
- Sediakan filter 7 hari, 30 hari, dan siklus aktif.
- Sediakan empty state saat data belum cukup.

### B3. Balance Trend Chart

- Status: `Belum dimulai`
- Buat use case tren saldo kumulatif.
- Tampilkan line chart dengan tooltip tanggal dan saldo.
- Tampilkan insight tren naik, stabil, atau menurun.

### B4. Analytics Page

- Status: `Belum dimulai`
- Buat halaman Analitik khusus setelah chart dasar stabil.
- Satukan cash flow, balance trend, category breakdown, dan top spending.
- Tentukan akses dari Dashboard terlebih dahulu sebelum menambah tab navigation.

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

## D. Transaction History

### D1. History Polish

- Status: `Selesai sebagian`
- Header, search, filter, grouped daily card, dan transaction tile sudah dipoles.
- Filter siklus aktif tidak boleh menabrakkan icon refresh dan checkmark.
- Lakukan validasi visual pada Android kecil dan Windows.

### D2. History Detail

- Status: `Belum dimulai`
- Pertimbangkan detail transaksi sebagai bottom sheet yang lebih informatif.
- Tambahkan shortcut edit dan hapus yang tetap aman untuk allocation transaction.
- Pertimbangkan export berdasarkan filter aktif.

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

## F. Reliability dan Sistem

### F1. Firestore Error State Audit

- Status: `Belum dimulai`
- Audit seluruh stream/provider untuk loading, error, empty, dan retry.
- Pastikan pesan error tidak membocorkan data sensitif.
- Pastikan setiap operasi Firestore memakai try-catch.

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

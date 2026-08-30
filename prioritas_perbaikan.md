# Prioritas Perbaikan MoneyTracker

Dokumen ini menjadi catatan lanjutan ketika sesi AI terputus, laptop di-refresh,
atau model AI berganti. Status mencerminkan kondisi implementasi terakhir.

## Status Prioritas 1-7

| No. | Prioritas | Status | Catatan |
| --- | --- | --- | --- |
| 1 | Firestore Transaction untuk operasi alokasi | Selesai | Tambah, edit, dan hapus alokasi kini membaca data terbaru di dalam `runTransaction`. |
| 2 | Hapus target dengan banyak riwayat alokasi | Selesai | Transaksi alokasi dihapus dalam chunk 450 dokumen, lalu target dihapus pada batch terpisah. |
| 3 | Test lengkap filter History dan ringkasan | Selesai | Step 14 dibuat dengan use case filter dan test kombinasi dasar. |
| 4 | Modularisasi halaman Settings | Selesai | Entry page dan komposisi content Settings sudah dipisah; section reusable sebelumnya juga berada di file widget terdedikasi. |
| 5 | Empty state Dashboard yang lebih informatif | Selesai | Hero onboarding, empty chart, dan empty insight sudah memiliki copy, visual, serta CTA/informasi yang jelas. |
| 6 | Status sinkronisasi yang lebih detail | Selesai | Loading, sukses, gagal, retry, dan waktu pembaruan terakhir sudah tersedia; offline queue bukan bagian scope saat ini. |
| 7 | Firebase Authentication dan isolasi data user | Selesai sebagian | Auth dan path `users/{uid}` sudah aktif; deployment Firebase, migrasi data lama, dan validasi lintas platform masih perlu diselesaikan. |

## Fitur yang Sudah Selesai Sebelumnya

- Fase PRD 1 sampai 4.
- Operasi alokasi atomik dengan Firestore Transaction.
- Profil Settings, tipe pengguna, dan detail profil.
- Filter kategori History searchable bottom sheet.
- Validasi edit alokasi agar saldo utama tidak negatif.
- Branding footer `Product by Andre Robert`.
- Status sinkronisasi dasar pada profil Settings.

## Step Terakhir

**Step 14: penguatan filter History dan ringkasan transaksi**

- Logika filter dipindahkan ke `FilterTransactionsUseCase`.
- UI History menampilkan ringkasan filter aktif dan tombol `Reset`.
- Test kategori + tipe, pencarian catatan, dan siklus aktif ditambahkan.

## Step Berikutnya

Prioritas aktif berikutnya adalah **validasi deployment Firebase, migrasi data lama, dan security rules**.

## Step 20

- Badge profil Settings menampilkan status loading, sukses, atau offline/gagal.
- Menampilkan waktu sinkronisasi terakhir seperti `Baru saja diperbarui` atau `5 menit lalu`.
- Waktu sinkronisasi terakhir disimpan di `SharedPreferences`.
- Status gagal menyediakan aksi retry.

## Step 21

- Menambahkan Firebase Anonymous Authentication.
- Menambahkan `authStateChangesProvider` dan `currentUserProvider` berbasis Riverpod.
- Menambahkan `AuthGate` sebelum aplikasi utama dijalankan.
- Memindahkan transaksi dan target ke path user-scoped:
  `users/{uid}/transactions` dan `users/{uid}/savings_goals`.
- Mengamankan tambah, edit, hapus alokasi, reset data, dan hapus target agar memakai user yang sedang terautentikasi.
- Status: implementasi kode selesai; deployment dan validasi manual masih diperlukan.
- Wajib: aktifkan Anonymous Auth di Firebase Console.
- Wajib: terapkan Firestore Security Rules berbasis `request.auth.uid`.
- Wajib: migrasikan data lama dari collection global jika ingin mempertahankannya.
- Rekomendasi: tambahkan account linking agar akun anonymous tidak hilang setelah uninstall.
- Tidak ada fallback collection global saat runtime; hal ini mencegah kebocoran data antar-user.

## Step 19

- Menambahkan hero empty state Dashboard untuk pengguna tanpa transaksi.
- Menampilkan greeting pengguna dan CTA `Catat transaksi`.
- Memperjelas empty state pie chart agar menjelaskan manfaat kategori pengeluaran.
- Menambahkan empty state financial insight agar tidak terlihat seperti data error atau palsu.
- Mempertahankan error state dan loading state sebagai kondisi yang berbeda.

## Step 17

- Memindahkan `SettingsSectionTitle` ke `widgets/settings_section_title.dart`.
- Memindahkan `DeveloperCard` ke `widgets/developer_card.dart`.
- Memindahkan `HelpCenterEntry` ke `widgets/help_center_entry.dart`.
- Memindahkan `HelpCenterSheet` beserta FAQ ke `widgets/help_center_sheet.dart`.
- Halaman utama Settings sekarang hanya mengorkestrasi section dan mempertahankan UI premium yang sama.

## Step 18

- Memindahkan entry point Settings ke `pages/settings_page.dart` yang ringan.
- Memindahkan komposisi seluruh content Settings ke `widgets/settings_content.dart`.
- Mempertahankan provider, dialog, feedback, dan visual premium yang sudah ada.
- Menghapus implementasi Settings duplikat dari file page.

## Verifikasi Terakhir

- Jalankan `flutter analyze`.
- Jalankan `flutter test`.
- Validasi manual di device Android untuk filter History dan layar kecil.

## Workflow

- Perubahan belum di-commit oleh AI.
- User melakukan commit manual setelah verifikasi device.

## Backlog Sistem dan UI

Dokumen ini juga menjadi backlog aktif. Perbarui status task setelah implementasi.

### P0.1 Firebase Email Link dan Android App Links

- Status: `Berjalan`
- Tujuan: link Gmail membuka aplikasi Android dan login otomatis tanpa paste.
- Cakupan: intent-filter `/finishSignIn` dan `/__/auth/action`, parsing
  `continueUrl`, initial link, runtime link, dan validasi fingerprint APK.
- Kriteria selesai: APK debug dan release dapat membuka aplikasi, menyelesaikan
  login, serta tetap memiliki fallback paste link.

### P0.2 Kendali Resend Email Link

- Status: `Berjalan`
- Tujuan: mengurangi risiko Firebase `too-many-requests`.
- Cakupan: cooldown 60 detik, tombol resend, dan pesan rate limit yang jelas.
- Kriteria selesai: tidak ada request berulang sebelum cooldown berakhir dan
  pengguna memahami kapan dapat mencoba kembali.

### P0.3 Validasi Data dan Error State

- Status: `Belum dimulai`
- Audit semua provider Firestore, loading/error/empty state, retry action, dan
  logging development yang tidak membocorkan data sensitif.

### P1.1 Sistem Theme dan Visual Identity

- Status: `Selesai`
- Color scheme emerald/teal, typography hierarchy, radius, elevation, spacing,
  serta style global Card, input, button, chip, snackbar, dialog, dan bottom
  sheet untuk light dan dark mode sudah dibuat di
  `lib/core/theme/money_tracker_theme.dart`.
- Tahap lanjutan: mengganti warna hard-coded pada feature widgets jika ditemukan
  saat redesign halaman.

### P1.2 Shared Page Background dan Layout Container

- Status: `Selesai`
- Wrapper `AppPageBackground` sudah dibuat di
  `lib/core/widgets/app_page_background.dart` dan dipasang pada root
  `AppShell`, sehingga halaman utama berbagi background surface dan dekorasi
  yang sama.
- Tahap lanjutan: menambahkan max-width dan page container spesifik saat
  redesign Dashboard, Savings, History, dan Settings.

### P1.3 Navigation dan Feedback Pattern

- Status: `Berjalan`
- NavigationBar, snackbar, dialog, dan bottom sheet sudah memiliki baseline
  style global dari theme.
- Tahap berikutnya: menerapkan surface, spacing, feedback, dan transisi secara
  konsisten pada setiap halaman dan action flow.

### P1.4 Redesign Dashboard

- Status: `Belum dimulai`
- Tambahkan header personal, balance hero card, income/expense tiles, budget
  progress visual, insight accent color, chart card, skeleton, dan empty state.
- Selesai jika saldo, arus uang, dan status budget mudah dipahami sekali lihat.

### P1.5 Redesign Savings

- Status: `Selesai`
- Goal card kini memakai warna semantik dari `ColorScheme` untuk status
  progress, target selesai, dan deadline agar konsisten pada light/dark mode.
- Ditambahkan overview target, skeleton loading, serta penyempurnaan tab,
  sorting, empty state, progress bar, dan deadline chip.
- Bottom sheet tambah dan alokasi tetap mempertahankan alur yang telah ada.

### P1.6 Redesign History

- Status: `Belum dimulai`
- Poles search, filter aktif, transaction tile, daily summary, empty/loading
  state, swipe action, dan dialog hapus.

### P1.7 Redesign Settings

- Status: `Belum dimulai`
- Kelompokkan profile, tampilan, budget, privacy, sinkronisasi, bantuan, dan
  manajemen data; pisahkan danger zone secara visual.

### P1.8 Polish Authentication UI

- Status: `Belum dimulai`
- Perjelas hierarchy Google, password, email link, guest, loading, success,
  error, rate limit, resend, fallback paste, dan layout responsif.

### P2.1 Accessibility dan Responsiveness

- Status: `Belum dimulai`
- Uji tap target, text scaling, semantics, focus state, kontras, overflow, serta
  Android kecil/besar, Windows, dan Web.

### P2.2 Motion dan Micro-interaction

- Status: `Belum dimulai`
- Tambahkan animasi singkat untuk saldo, progress, list/filter, bottom sheet, dan
  feedback transaksi tanpa menghambat aksi pengguna.

### P2.3 Test dan Release Checklist

- Status: `Belum dimulai`
- Tambahkan widget/golden test bila perlu, jalankan analyze/test, dan ulangi
  validasi Email Link pada debug serta release APK setelah deployment.

## Urutan Eksekusi Berikutnya

1. Selesaikan P0.1 dan P0.2, lalu validasi manual Email Link di Android.
2. Kerjakan P0.3 untuk menutup celah error dan state kosong.
3. Kerjakan P1.1, P1.2, dan P1.3 sebagai fondasi UI bersama.
4. Kerjakan P1.4 Dashboard terlebih dahulu.
5. Lanjutkan P1.5 Savings, P1.6 History, dan P1.7 Settings.
6. Tutup dengan P1.8 Authentication, P2.1, P2.2, dan P2.3.

## Log Perubahan Status

- 2026-08-29: Memperluas intent-filter App Links, menambahkan parsing link
  terbungkus, cooldown resend 60 detik, dan pesan rate limit Firebase.
- 2026-08-29: Menambahkan UI foundation global berupa theme light/dark,
  reusable page background, dan baseline style untuk komponen Material.

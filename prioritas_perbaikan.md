# Prioritas Perbaikan Savu

Dokumen ini menjadi catatan lanjutan ketika sesi AI terputus, laptop di-refresh,
atau model AI berganti. Status mencerminkan kondisi implementasi terakhir.

> **Update 2026-09-03:** dokumen ini disinkronkan dengan 30 commit terakhir branch
> `develop_dua`. Prioritas 8-12 ditambahkan untuk menampung pekerjaan rebrand,
> onboarding, avatar, dark theme, dan arsip target. Bagian "Log Perubahan Status"
> diperpanjang dengan entri September.

## Status Prioritas 1-7

| No. | Prioritas | Status | Catatan |
| --- | --- | --- | --- |
| 1 | Firestore Transaction untuk operasi alokasi | Selesai | Tambah, edit, dan hapus alokasi kini membaca data terbaru di dalam `runTransaction`. |
| 2 | Hapus target dengan banyak riwayat alokasi | Selesai | Transaksi alokasi dihapus dalam chunk 450 dokumen, lalu target dihapus pada batch terpisah. Target selesai kini memakai jalur khusus: hanya dokumen target yang dihapus, transaksi alokasi dipertahankan sebagai ledger. |
| 3 | Test lengkap filter History dan ringkasan | Selesai | Step 14 dibuat dengan use case filter dan test kombinasi dasar. Suite kini berisi 69 test. |
| 4 | Modularisasi halaman Settings | Selesai | Entry page dan komposisi content Settings sudah dipisah; section reusable sebelumnya juga berada di file widget terdedikasi. |
| 5 | Empty state Dashboard yang lebih informatif | Selesai | Hero onboarding, empty chart, dan empty insight sudah memiliki copy, visual, serta CTA/informasi yang jelas. |
| 6 | Status sinkronisasi yang lebih detail | Selesai | Loading, sukses, gagal, retry, dan waktu pembaruan terakhir sudah tersedia; offline queue bukan bagian scope saat ini. |
| 7 | Firebase Authentication dan isolasi data user | Selesai sebagian | Auth dan path `users/{uid}` sudah aktif; OAuth client Android sudah tersedia di `google-services.json`; deployment Firebase, SHA release, dan validasi lintas platform masih perlu diselesaikan. |

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

Prioritas aktif berikutnya adalah **membersihkan 5 info `flutter analyze`**, lalu
**validasi deployment Firebase, migrasi data lama, dan security rules**.

## Status Prioritas 8-12 (baru, dari commit 2026-09-02 s/d 2026-09-03)

| No. | Prioritas | Status | Catatan |
| --- | --- | --- | --- |
| 8 | Rebrand MoneyTracker menjadi Savu | Selesai | Package `com.example.savu`, launcher icon lintas platform, metadata web/desktop, dan seluruh judul aplikasi. |
| 9 | Onboarding page | Selesai | 3 slide dengan `PageController`, ilustrasi custom, dan flag `onboarding_completed` di SharedPreferences. Perlu validasi terhadap user lama. |
| 10 | Katalog avatar profil preset | Selesai | 30 avatar (15 general + 15 people), tersimpan di SharedPreferences, sheet picker responsif. Filter gender dihapus. |
| 11 | Rombak dark theme | Selesai | Palet charcoal `#121417` + surface solid `#1C2026` + aksen teal `#2DD4BF`, diterapkan ke 25 file. |
| 12 | Arsip target tabungan | Selesai | `isArchived`, mode toggle, provider terpisah, dan pemisahan perilaku hapus target selesai vs aktif. Fitur favorit dicabut dari UI. |

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

- Status: `Selesai`
- Tujuan: link Gmail membuka aplikasi Android dan login otomatis tanpa paste.
- Cakupan: intent-filter `/finishSignIn` dan `/__/auth/action`, parsing
  `continueUrl`, initial link, runtime link, dan validasi fingerprint APK.
- Kriteria selesai: APK debug dan release dapat membuka aplikasi, menyelesaikan
  login, serta tetap memiliki fallback paste link.
- Catatan 2026-09-03: OAuth client Android sudah tersedia di `google-services.json`
  dengan package `com.example.savu`. Yang tersisa: SHA-1/SHA-256 keystore release
  di Firebase Console dan `web/.well-known/assetlinks.json`.

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

### P0.4 Hutang Analyzer

- Status: `Berjalan`
- Tujuan: `flutter analyze` kembali ke 0 issue sebelum fitur baru dimulai.
- Cakupan: 5 info tersisa per 2026-09-03.
  - `lib/features/settings/presentation/widgets/settings_content.dart` baris
    1306, 1312, 1314 — `use_build_context_synchronously` (3 info).
  - `lib/features/dashboard/presentation/widgets/financial_insight_overview_sheet.dart`
    baris 499 — `curly_braces_in_flow_control_structures`.
  - `lib/features/auth/presentation/pages/auth_landing_page.dart` baris 604 —
    `unnecessary_brace_in_string_interps`.
- Kriteria selesai: `flutter analyze` melaporkan "No issues found". Terpenuhi pada 2026-09-04.

### P0.5 Validasi Onboarding Terhadap User Lama

- Status: `Belum dimulai`
- Tujuan: memastikan pengguna yang sudah memiliki data Firestore tidak terjebak atau
  kehilangan akses karena flag `onboarding_completed` belum pernah diset.
- Cakupan: urutan `_AuthGate`, persistensi flag, dan transisi `AnimatedSwitcher`.
- Kriteria selesai: user lama langsung masuk ke `AuthLandingPage` atau `SavuApp`
  sesuai status auth; onboarding hanya muncul untuk instalasi baru.

### P0.6 Regresi Kategori Alokasi Tabungan

- Status: `Belum dimulai`
- Tujuan: memastikan penggantian kategori default tidak merusak data lama.
- Cakupan: transaksi tersimpan dengan kategori "Alokasi Tabungan", chip pilihan
  kategori, agregasi pie chart, dan filter History.
- Kriteria selesai: transaksi lama tetap tampil, tidak bisa dipilih ulang sebagai
  kategori manual, dan alokasi otomatis tetap berfungsi.

### P1.1 Sistem Theme dan Visual Identity

- Status: `Selesai`
- Color scheme emerald/teal, typography hierarchy, radius, elevation, spacing,
  serta style global Card, input, button, chip, snackbar, dialog, dan bottom
  sheet untuk light dan dark mode sudah dibuat di
  `lib/core/theme/savu_theme.dart`.
- Tahap lanjutan: mengganti warna hard-coded pada feature widgets jika ditemukan
  saat redesign halaman.
- Penyempurnaan: typography global kini menggunakan Plus Jakarta Sans untuk
  hierarki teks yang lebih tegas dan profesional.

### P1.2 Shared Page Background dan Layout Container

- Status: `Selesai`
- Wrapper `AppPageBackground` sudah dibuat di
  `lib/core/widgets/app_page_background.dart` dan dipasang pada root
  `AppShell`, sehingga halaman utama berbagi background surface dan dekorasi
  yang sama.
- Tahap lanjutan: menambahkan max-width dan page container spesifik saat
  redesign Dashboard, Savings, History, dan Settings.
- Penyempurnaan: glow orb diganti dengan tonal mesh gradient dan tekstur grid
  diagonal yang halus agar tidak terlihat polos atau generik.

### P1.3 Navigation dan Feedback Pattern

- Status: `Berjalan`
- NavigationBar, snackbar, dialog, dan bottom sheet sudah memiliki baseline
  style global dari theme.
- Tahap berikutnya: menerapkan surface, spacing, feedback, dan transisi secara
  konsisten pada setiap halaman dan action flow.

### P1.4 Redesign Dashboard

- Status: `Berjalan`
- Tambahkan header personal, balance hero card, income/expense tiles, budget
  progress visual, insight accent color, chart card, skeleton, dan empty state.
- Selesai jika saldo, arus uang, dan status budget mudah dipahami sekali lihat.
- Sudah dikerjakan: header dan greeting tersinkron dengan nama Settings
  (`7b1dcf1`), sheet edukasi status anggaran (`02f16f5`), warna status anggaran
  eksplisit per tema (`7171105`), teks pengeluaran lebih terang (`c5e99e3`),
  chart insight responsif terhadap tap (`73a4f07`), dan navigasi floating action
  beranimasi (`33745eb`).
- Belum selesai: audit hierarchy/spacing menyeluruh dan skeleton loading.

### P1.5 Redesign Savings

- Status: `Selesai`
- Goal card kini memakai warna semantik dari `ColorScheme` untuk status
  progress, target selesai, dan deadline agar konsisten pada light/dark mode.
- Ditambahkan overview target, skeleton loading, serta penyempurnaan tab,
  sorting, empty state, progress bar, dan deadline chip.
- Bottom sheet tambah dan alokasi tetap mempertahankan alur yang telah ada.

### P1.6 Redesign History

- Status: `Selesai`
- Menambahkan header berhierarki jelas, search dan filter surface yang lebih
  terarah, serta penyelarasan grouped daily card dan transaction tile.
- Semua warna arus pemasukan/pengeluaran, swipe delete, dan ringkasan harian
  memakai semantic `ColorScheme`, sehingga konsisten pada light dan dark mode.

### P1.7 Redesign Settings

- Status: `Berjalan`
- Kelompokkan profile, tampilan, budget, privacy, sinkronisasi, bantuan, dan
  manajemen data; pisahkan danger zone secara visual.
- Sudah dikerjakan: avatar profil dapat diketuk dengan sheet picker 30 preset
  (`a992904`, `402f04c`, `70bf265`, `cb8dab4`), kontak founder membuka aplikasi
  native (`4a546bf`, `05de391`), aksi dialog diseragamkan dan overflow dicegah
  (`1ec64b1`, `d23212c`, `9cf2bd8`), serta sinkronisasi greeting dengan dialog
  edit profil (`7b1dcf1`).
- Belum selesai: pengelompokan ulang section dan pemisahan visual danger zone.

### P1.8 Polish Authentication UI

- Status: `Belum dimulai`
- Perjelas hierarchy Google, password, email link, guest, loading, success,
  error, rate limit, resend, fallback paste, dan layout responsif.
- Catatan: onboarding page kini menjadi lapisan pertama sebelum auth landing
  (`f7b773f`), sehingga hierarki perlu mempertimbangkan urutan
  Onboarding → Auth → Verifikasi → App.

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

1. **Kerjakan P0.4 (hutang analyzer) terlebih dahulu** agar baseline kode kembali
   bersih sebelum perubahan fitur.
2. Validasi P0.5 onboarding dan P0.6 regresi kategori — keduanya berpotensi
   merusak pengalaman user lama.
3. Selesaikan P0.1 dan P0.2, lalu validasi manual Email Link di Android.
4. Kerjakan P0.3 untuk menutup celah error dan state kosong.
5. Kerjakan P1.1, P1.2, dan P1.3 sebagai fondasi UI bersama.
6. Kerjakan P1.4 Dashboard terlebih dahulu.
7. Lanjutkan P1.5 Savings, P1.6 History, dan P1.7 Settings.
8. Tutup dengan P1.8 Authentication, P2.1, P2.2, dan P2.3.

## Log Perubahan Status

- 2026-08-29: Memperluas intent-filter App Links, menambahkan parsing link
  terbungkus, cooldown resend 60 detik, dan pesan rate limit Firebase.
- 2026-08-29: Menambahkan UI foundation global berupa theme light/dark,
  reusable page background, dan baseline style untuk komponen Material.
- 2026-08-30 s/d 2026-08-31: Membangun fondasi UI (background, dashboard,
  savings, history), menambahkan navigasi floating action beranimasi, target
  tabungan yang dapat diedit, cash flow chart, balance trend, expense flow
  overview, filter rentang tanggal custom, penyelarasan perhitungan dengan siklus
  anggaran, serta penanganan error Firestore terpusat.
- 2026-09-01: Memperbarui menu dan sistem pada menu goals — menambahkan
  `isArchived` dan `isFavorite` pada entity, mode arsip, serta pemisahan perilaku
  hapus target selesai dan aktif. Widget `savings_overview.dart` dihapus.
- 2026-09-02: Menambahkan Contact Us, sheet edukasi status anggaran, perbaikan
  interaksi chart mobile, dukungan foto profil custom, katalog avatar preset,
  tombol batal pada ganti akun, penyelarasan greeting, dan penyederhanaan
  Financial Insight Card.
- 2026-09-02: Rebrand MoneyTracker menjadi Savu beserta konfigurasi launcher
  icon lintas platform; menghapus logo ganda.
- 2026-09-03: Merombak seluruh warna dark theme menjadi palet charcoal dan teal
  solid; mengubah warna teks pengeluaran pada Financial Insight agar lebih terang;
  mengubah warna progres card target berdasarkan ambang 50% dan 100%; memperbaiki
  spacing form catatan baru; mengganti kategori default "Alokasi Tabungan"
  menjadi "Kesehatan & Perawatan"; menambahkan onboarding page; memperbesar tombol
  batal pada dialog hapus target dan menu riwayat; serta menambahkan widget foto
  pada avatar.
- 2026-09-03: Verifikasi ulang oleh AI — `flutter test` 69/69 lulus,
  `flutter analyze` menyisakan 5 info. Seluruh file md progres disinkronkan.

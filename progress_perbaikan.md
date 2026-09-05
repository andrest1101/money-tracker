# Roadmap Perbaikan Savu

Dokumen ini adalah sumber kebenaran untuk pekerjaan lanjutan Savu.
Perbarui status setiap kali sebuah tahap selesai agar sesi berikutnya dapat
langsung melanjutkan tanpa mengulang analisis.

Status yang digunakan: `Belum dimulai`, `Berjalan`, `Selesai`, `Ditunda`.

> **Update 2026-09-03:** dokumen ini disinkronkan dengan 30 commit terakhir branch
> `develop_dua` yang sebelumnya tidak tercatat. Lima area baru ditambahkan:
> Branding, Onboarding, Profil & Avatar, Savings Archive, dan Quality/Analyzer.

## Status Saat Ini

| Area | Tahap aktif | Status |
| --- | --- | --- |
| Dashboard | Balance Card Overview dan Budget Overview interaktif | Selesai |
| Analytics | Konsistensi periode chart | Selesai |
| Savings | Edit target tabungan | Selesai |
| History | Redesign dasar dan filter | Selesai |
| Navigation | Floating pill, center action, dan transisi | Selesai |
| Quality | Test suite dan Windows allocation workaround | Berjalan |
| Dark Theme | Rich navy surface system dan solid card audit | Selesai |
| Branding | Rebrand MoneyTracker → Savu dan aset lintas platform | Selesai |
| Onboarding | 3 slide pengantar dengan flag persistensi | Selesai |
| Profil & Avatar | Katalog 30 avatar preset dan foto profil | Selesai |
| Savings Archive | Mode arsip dan pemisahan hapus target | Selesai |
| Analyzer Debt | 5 info `flutter analyze` belum dituntaskan | Berjalan |

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

- Status: `Berjalan`
- Pastikan semua card memiliki hierarchy, spacing, dan hit target konsisten.
- Tambahkan feedback visual saat card dapat diketuk.
- Audit empty, loading, error, dan retry state setiap section.
- Sudah dikerjakan sebagian:
  - Sheet edukasi status anggaran ditambahkan (`02f16f5`) agar user memahami arti
    Aman / Perlu diperhatikan / Terlampaui.
  - Warna status anggaran dibuat eksplisit per tema (`7171105`): `#FBBF24` dark dan
    `#D97706` light menggantikan `cs.tertiary` yang sulit dibaca.
  - Warna teks pengeluaran dan rata-rata pada Financial Insight dibuat lebih terang
    (`c5e99e3`).
  - Chart pada Insight Card responsif terhadap tap (`73a4f07`).
- Belum selesai: audit menyeluruh empty/loading/error/retry pada setiap section.

### A4. Warna Semantik Lintas Tema

- Status: `Selesai`
- Warna peringatan anggaran tidak lagi memakai `ColorScheme.tertiary` yang tidak
  konsisten antara light dan dark.
- Konstanta eksplisit diterapkan di tiga tempat: `_BudgetAlertBody`,
  `_BudgetOverviewSheet`, dan `_BudgetInfoSheet` (menerima `warningColor`).
- Setiap level pada sheet edukasi kini memiliki warna sendiri:
  primary (Aman), warning (Perlu diperhatikan), error (Terlampaui).

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

- Status: `Berjalan`
- Audit spacing goal card pada layar kecil.
- Perjelas state target selesai, deadline dekat, dan overdue.
- Tambahkan feedback loading/error yang konsisten.
- Pertimbangkan ringkasan total dana seluruh target.
- Sudah dikerjakan:
  - Warna progres bertingkat (`bb468d0`): hijau terang saat 100%, biru terang saat
    ≥ 50%, dan `cs.primary` di bawah 50%. Border card juga menyesuaikan ketebalan
    dan opasitas mengikuti progres.
  - Dialog konfirmasi hapus diperbesar tombolnya (`e0803c1`) dan kini menjelaskan
    dampak berbeda antara target selesai dan target aktif.
- Belum selesai: audit spacing layar kecil dan ringkasan total dana.

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

### C3. Savings Archive and Goal Actions

- Status: `Selesai`
- Target menyimpan metadata `isArchived` dan `isFavorite` dengan default `false`
  agar dokumen Firestore lama tetap kompatibel.
- Provider memisahkan target normal dan target arsip berdasarkan status Aktif atau
  Selesai.
- Goal card memiliki menu tiga titik untuk edit, arsip/kembalikan, dan hapus, dengan
  SnackBar feedback untuk archive.
- Sorting target memakai tombol compact dengan bottom sheet pilihan urutan.
- Penghapusan target selesai hanya menghapus dokumen target; transaksi alokasi
  tetap dipertahankan sebagai ledger sehingga saldo utama tidak berubah.
- Bottom sheet Savings memakai satu drag handle dari `showDragHandle` tanpa handle
  manual ganda.
- **Mode arsip penuh (`9530cd5`, `2904310`):**
  - `archivedModeProvider` (`ArchivedModeController`) men-toggle tampilan arsip.
  - `archivedActiveGoalsProvider` dan `archivedCompletedGoalsProvider` memisahkan
    target terarsip berdasarkan status selesai.
  - `activeGoalsProvider`/`completedGoalsProvider` kini memfilter `!isArchived`.
  - `SavingsActionsController.setArchived()` menulis flag ke Firestore.
  - Halaman Savings menampilkan judul `Target Diarsipkan` saat mode arsip aktif,
    lengkap dengan empty state yang berbeda.
  - `deleteCompletedGoal()` dipisah dari `deleteGoalWithAllocations()`: target
    selesai hanya menghapus dokumen, transaksi alokasi tetap menjadi ledger.
- ⚠️ **Fitur favorit dicabut (`2904310`):** `_GoalAction.favorite`, `onFavorite`, dan
  `SavingsActionsController.setFavorite()` dihapus. Field `isFavorite` **masih ada di
  entity dan model** namun tidak terpakai. Rencanakan pembersihan atau pemulihan.
- ⚠️ **`savings_overview.dart` dihapus** pada `9530cd5`.
- Verifikasi saat arsip dibuat: `flutter test` 69/69 lulus; analyzer saat itu
  menyisakan 5 info. Kelima info tersebut sudah diperbaiki pada 2026-09-04;
  lihat bagian G4.

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
- **Dark theme dirombak total (`28f2ba1`, 25 file):** lihat bagian H1.

### E4. Profil dan Avatar

- Status: `Selesai`
- Avatar header Settings dapat diketuk untuk membuka `ProfileAvatarSheet`.
- 30 avatar preset tersedia dalam kategori `general` (15) dan `people` (13).
- Pilihan tersimpan di SharedPreferences melalui `profileAvatarProvider`
  (kunci `profile_avatar_id`, default `sunrise`).
- Grid responsif: 3 kolom di bawah lebar 360px, 4 kolom di atasnya.
- Transisi pergantian avatar memakai `AnimatedSwitcher` dengan fade dan scale.
- ⚠️ Filter gender (Laki-laki/Perempuan) **dihapus** pada `6340933`. Enum
  `PresetAvatarGender` masih ada sebagai metadata avatar, tetapi tidak dipakai UI.
- ⚠️ Nama preset avatar `people` memakai nama orang nyata (Andre, Chelsie, Melvin,
  Aidil, Zaki, Irvan, Faiz, Sultan, Alberd, Naya, Alya, Kirana, Caca, Luna, Mira).
  Ganti menjadi label generik jika aplikasi akan didistribusikan publik.

### E5. Kontak Founder

- Status: `Selesai`
- `ContactUsEntry` membuka aksi langsung, bukan sheet berbagi generik:
  - Email → intent Gmail/Android, fallback `url_launcher` (`mailto:`).
  - WhatsApp → `android_intent_plus` ke `62895338891504` (ditampilkan `0895338891504`).
  - GitHub → `https://github.com/andrest1101`.
- Import `share_plus` di file ini diganti `url_launcher` + `android_intent_plus`.
- Tombol kirim feedback diperkecil (`d23212c`) karena sebelumnya terlalu besar.

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
- **OAuth client Android sudah tersedia** di `google-services.json`
  (`client_type: 1`, package `com.example.savu`, certificate hash
  `a0738b4d528ff1a73edce30753974eb2862b24cb`), diperbarui pada `6dab288` mengikuti
  rebrand. Yang belum ada: **SHA-1/SHA-256 keystore release**.
- `firestore.rules` sudah membatasi akses pada `users/{userId}/{document=**}` dengan
  `request.auth.uid == userId`, dan menutup root collection legacy `transactions`
  serta `savings_goals` dengan `allow read, write: if false`.
- ⚠️ Rules belum di-deploy ke Firebase Console.

## G. Testing dan Release

### G1. Automated Test

- Status: `Berjalan`
- Jalankan `flutter analyze` sebelum setiap commit.
- Jalankan `flutter test` sebelum setiap commit.
- Tambahkan test setiap kali use case atau alur utama baru dibuat.
- **Baseline 2026-09-03:** `flutter test` **69/69 lulus** (21 file test).
  Catatan lama yang menyebut 52 test sudah usang.
- **Hutang analyzer:** selesai pada 2026-09-04; `flutter analyze` kini bersih.

### G2. Responsive Validation

- Status: `Belum dimulai`
- Validasi Android kecil, Android besar, Windows, dan Web.
- Cek text scaling, overflow, tap target, keyboard, dan bottom sheet.
- Perhatian khusus setelah perubahan terbaru: dark theme baru, avatar picker,
  onboarding page, dan warna progres target.

### G3. Release Checklist

- Status: `Belum dimulai`
- Build Android debug/release.
- Build Windows debug.
- Build Web.
- Deploy Firestore rules dan Hosting.
- Validasi Auth, deep link, Firestore path, dan data isolation.
- Daftarkan SHA-1/SHA-256 release ke Firebase Console dan `assetlinks.json`.
- Validasi onboarding tidak menghalangi user lama yang sudah punya data.

### G4. Analyzer Debt

- Status: `Selesai`
- 5 info tersisa per 2026-09-03:
  - `settings_content.dart` baris 1306, 1312, 1314 — `use_build_context_synchronously`
    (3 info). `BuildContext` dipakai setelah `await` dengan guard `mounted` yang
    tidak terkait langsung.
  - `financial_insight_overview_sheet.dart` baris 499 —
    `curly_braces_in_flow_control_structures`.
  - `auth_landing_page.dart` baris 604 — `unnecessary_brace_in_string_interps`.
- Verifikasi: `flutter analyze` -> **No issues found**; `flutter test` -> **69/69 lulus**.

## H. Branding dan Identitas

### H1. Rebrand MoneyTracker → Savu

- Status: `Selesai`
- `pubspec.yaml`: nama package `savu`, deskripsi aplikasi diperbarui.
- Package Android berpindah ke `com.example.savu` (`MainActivity.kt`,
  `AndroidManifest.xml`, `build.gradle.kts`, `google-services.json`).
- Launcher icon baru `assets/images/app_icon.png` dihasilkan untuk Android (mipmap
  semua density), iOS (`AppIcon.appiconset`), Web (`web/icons/*` + `favicon.png`),
  Windows (`app_icon.ico`), dan macOS.
- `flutter_launcher_icons` masuk `dev_dependencies` dan dikonfigurasi dengan
  warna tema `#0F766E`.
- Judul aplikasi di `main.dart` (dua `MaterialApp`), `web/manifest.json`,
  `web/index.html`, `windows/runner/Runner.rc`, `linux/runner/my_application.cc`,
  dan `macos/Runner/Configs/AppInfo.xcconfig` disesuaikan.
- Logo ganda dihapus (`34a7d21`).
- ⚠️ `assets/images/Savu_logo.png` **tidak ada di working tree** dan tidak terdaftar
  di `pubspec.yaml`. Jangan menambahkan referensi ke file tersebut.

### H2. Onboarding

- Status: `Selesai`
- Folder baru `lib/features/onboarding/`:
  - `presentation/pages/onboarding_page.dart` — `PageController` + indikator.
  - `presentation/widgets/onboarding_slide.dart` — data slide, ilustrasi custom
    (`OnboardingIllustrationKind`), dan highlight fitur.
- 3 slide: Pencatatan Kilat (`#2DD4BF`), Kontrol Anggaran (`#60A5FA`),
  Mode Selesai & Arsip.
- `SettingsService` menyimpan flag `onboarding_completed`; diekspos melalui
  `onboardingCompletedProvider` (`OnboardingCompleted extends Notifier<bool>`).
- `_AuthGate` di `main.dart` memilih `OnboardingPage` atau `_AuthContent` dengan
  `AnimatedSwitcher` (fade 420ms + slide).
- ⚠️ **Risiko:** user lama dengan data Firestore akan melihat onboarding satu kali
  karena flag belum pernah diset. Perlu validasi.

## I. Dark Theme System

### I1. Palet Charcoal dan Teal

- Status: `Selesai`
- `SavuTheme` dipecah: `_buildLight()` memakai `ColorScheme.fromSeed` (dipertahankan),
  sedangkan `_buildDark()` memakai palet manual penuh.
- Nilai kunci dark theme:
  - scaffold `#121417` (deep charcoal)
  - surface / surfaceHigh / surfaceLow `#1C2026` (solid slate, tidak transparan)
  - primary / secondary / tertiary `#2DD4BF` (teal terang), onPrimary `#121417`
  - error `#EF5350`, onSurface `#FFFFFF`, onSurfaceVariant `#9CA3AF`
  - outline `#3A414A`, outlineVariant `#2B3138`
  - inverseSurface `#F3F4F6`, onInverseSurface `#121417`, inversePrimary `#0F766E`
- Diterapkan ke 25 file: app_shell, app_page_background, analytics (3 widget),
  auth landing, dashboard (4 widget), savings (2), settings (6), history (3), theme.
- Kartu kini solid, bukan lagi permukaan transparan yang menumpuk.

## J. Kategori Transaksi

### J1. Penggantian Kategori Default

- Status: `Selesai`
- Kategori default "Alokasi Tabungan" diganti menjadi **"Kesehatan & Perawatan"**
  pada `_defaultExpenseCategories` di `dashboard_providers.dart:109` (`96a246a`).
- Ikon baru di `category_icon.dart`: `Icons.health_and_safety`, warna `#E84393`.
- ⚠️ **Implikasi data lama:**
  - Transaksi lama berkategori "Alokasi Tabungan" tetap tersimpan apa adanya dan
    masih punya gaya di `category_icon.dart:21`.
  - `quick_add_transaction_sheet.dart:78` membuang kategori itu dari chip pilihan user.
  - `savings_providers.dart:227` tetap memakai string `'Alokasi Tabungan'` untuk
    alokasi otomatis ke target. **Jangan diubah tanpa migrasi data Firestore.**
- Belum divalidasi: apakah transaksi lama masih muncul benar di pie chart dan filter.

## Urutan Eksekusi yang Disarankan

1. ~~Selesaikan A1 Balance Card Overview.~~ Selesai.
2. ~~Selesaikan A2 Budget Overview Interaktif.~~ Selesai.
3. ~~Selesaikan B1 konsistensi periode chart.~~ Selesai.
4. ~~Buat B2 Cash Flow Chart.~~ Selesai.
5. ~~Buat B3 Balance Trend Chart.~~ Selesai.
6. B4 Analytics Page jika chart dasar sudah stabil. (Ditunda)
7. Kerjakan sisa C2 Savings Polish: spacing layar kecil dan ringkasan total dana.
8. Kerjakan D2 History Detail.
9. **Tuntaskan G4 Analyzer Debt (5 info) — prioritas pertama saat ini.**
10. Validasi H2 onboarding terhadap user lama dan J1 regresi kategori.
11. Bersihkan field `isFavorite` yang tidak terpakai, atau pulihkan fiturnya.
12. Tutup F1, F3, G2, dan G3 sebelum release.

## Aturan Sesi

- Jangan membuat commit otomatis.
- Jangan menghapus perubahan lokal yang belum di-commit.
- Satu tahap harus diverifikasi dengan analyzer dan test sebelum pindah tahap.
- Setelah fitur selesai, update status dokumen ini.

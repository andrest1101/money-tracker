# UI Audit — Savu Refactor v2

> **Batch 0** dari PRD Fase 5 (UI/UX Refactor).
> Dokumen ini adalah inventaris kondisi kode **sebelum** perubahan UI. Tidak ada kode UI yang diubah pada batch ini.

- **Tanggal audit:** 2026-11-05
- **Branch:** `refactor/ui-v2`
- **Basis commit:** `98019c7` (`main`)
- **Scope:** layout, warna, tipografi, komponen, navigasi, empty state, motion, aksesibilitas, tema gelap.
- **Di luar scope:** Domain/Data layer, skema Firestore, logika kalkulasi, fitur baru.

---

## 1. Ringkasan Eksekutif

Savu secara fungsi sudah lengkap (Fase 1–4 tuntas), tetapi lapisan visualnya tumbuh organik:

- **42 referensi warna literal** (`Colors.*`, di luar `Colors.transparent`)
  tersebar di **14 file**.
- **11 gradient** dekoratif di layar utama, auth, onboarding, dan swipe action
  (10 tersisa setelah `AppPageBackground` dibersihkan di Batch 1).
- Hampir semua section dibungkus kartu dengan treatment yang sama, sehingga tidak ada hierarki.
- Navigasi pill melayang menutupi konten dan memotong label.
- Tema gelap memakai palet manual, tetapi masih banyak warna hardcoded yang tidak ikut tema.

Arah PRD v2 (satu permukaan dominan, hairline, tanpa gradient, warna semantik, angka tabular) **sesuai dengan masalah nyata di kode** dan layak dijadikan acuan.

---

## 2. Baseline Verifikasi

| Pemeriksaan | Hasil |
| --- | --- |
| `flutter analyze` | **No issues found** (75,2 detik) |
| `flutter test` | **73/73 lulus** (21 file test) |
| Jumlah file Dart | 98 |
| Jumlah file test | 21 |

Widget test yang paling mungkin terdampak refactor UI:

- `test/widget_test.dart` — smoke test AppShell + perpindahan tab.
- `test/dashboard_empty_state_test.dart` — copy/struktur empty state Beranda.

Test domain/use case **tidak boleh berubah** karena refactor ini tidak menyentuh logika.

---

## 3. Inventaris Layar

| Layar | File | Isi utama | Catatan UI |
| --- | --- | --- | --- |
| Onboarding | `features/onboarding/presentation/pages/onboarding_page.dart` | 3 slide, `PageController`, indikator | Memakai `RadialGradient` dekoratif |
| Auth Landing | `features/auth/presentation/pages/auth_landing_page.dart` | Google, email/password, email link, guest | Memakai `LinearGradient` |
| Email Verification | `features/auth/presentation/pages/email_verification_page.dart` | Status verifikasi, resend cooldown | Perlu disejajarkan dengan Auth |
| App Shell | `core/navigation/app_shell.dart` | Floating pill 4 tab + tombol `+` tengah + sheet opsi | Sumber masalah konten tertutup & label terpotong |
| Beranda | `features/dashboard/presentation/pages/dashboard_page.dart` | Header, hero saldo, budget, insight, pie chart, transaksi | Banyak kartu bersarang |
| Target | `features/savings/presentation/pages/savings_page.dart` | Tab Aktif/Selesai, sort chip, tombol arsip, goal card | Sort chip & tombol arsip terlalu dominan |
| Riwayat | `features/transactions/presentation/pages/history_page.dart` | Search, tanggal, kategori, siklus, chip tipe, grouped list | Filter berlapis & teks terpotong |
| Pengaturan | `features/settings/presentation/pages/settings_page.dart` + `settings_content.dart` | Profil, akun, tema, privasi, keuangan, data, bantuan, developer | Satu kartu per item |
| Analitik | `features/analytics/presentation/pages/analytics_page.dart` | Cash flow + balance trend | **Tidak terhubung ke navigasi mana pun** |

### Sheet & dialog yang ada

| Komponen | File |
| --- | --- |
| Quick Add / Edit Transaksi | `transactions/presentation/widgets/quick_add_transaction_sheet.dart` |
| Filter kategori | `transactions/presentation/widgets/category_filter_sheet.dart` |
| Kelola kategori | `transactions/presentation/widgets/manage_categories_sheet.dart` |
| Tambah target | `savings/presentation/widgets/add_goal_sheet.dart` |
| Alokasi dana | `savings/presentation/widgets/allocate_fund_sheet.dart` |
| Edit alokasi | `savings/presentation/widgets/edit_allocation_sheet.dart` |
| Edit target | `savings/presentation/widgets/edit_goal_sheet.dart` |
| Perayaan target | `savings/presentation/widgets/goal_celebration_dialog.dart` |
| Avatar picker | `settings/presentation/widgets/profile_avatar_sheet.dart` |
| Account security | `settings/presentation/widgets/account_security_sheet.dart` |
| Help center / FAQ | `settings/presentation/widgets/help_center_sheet.dart` |
| Insight keuangan | `dashboard/presentation/widgets/financial_insight_overview_sheet.dart` |
| Expense flow | `analytics/presentation/widgets/expense_flow_overview_sheet.dart` |

---

## 4. Fitur Aktual vs PRD Lama

Fitur berikut **sudah ada di aplikasi tetapi belum tercatat di PRD lama** dan wajib dipertahankan:

| Fitur | Lokasi | Dampak refactor UI |
| --- | --- | --- |
| Privacy mode (samarkan nominal) | `settings_providers.dart`, `balance_hero_card.dart` | Hero & kartu saldo harus tetap mendukung `Rp •••••••` |
| Siklus anggaran (tanggal 1–28) | `settings_financial_section.dart`, `budget_cycle_period_usecase.dart` | Label periode & filter Riwayat |
| Status sinkronisasi + retry + waktu sync | `settings_profile_section.dart`, `lastSuccessfulSyncProvider` | Harus tetap terlihat di Pengaturan |
| Arsip target | `SavingsGoalEntity.isArchived`, `archivedModeProvider` | Pindah ke menu overflow, bukan tombol lebar |
| Urutkan target (terbaru/terlama/progress) | `SavingsSortController` | Pindah ke bottom sheet |
| Target aktif/selesai + badge jumlah | `SavingsPage` | Dipertahankan |
| Riwayat alokasi di goal card | `goal_card.dart` (expandable) | Dipertahankan |
| Edit/hapus alokasi atomik | `quick_add_controller.dart`, `savings_providers.dart` | Tidak boleh berubah |
| Filter rentang tanggal maks. 31 hari | `history_providers.dart` | Dipindah ke `FilterSheet` |
| Pencarian transaksi | `history_page.dart` | Menjadi ikon cari di app bar |
| Ekspor CSV | `settings_data_section.dart` | Dipertahankan |
| Hapus semua data berlapis | `settings_data_section.dart` | Danger zone dipisah visual |
| 30 avatar preset | `profile_avatar_sheet.dart` | Dipertahankan |
| Kontak founder (Gmail/WA/GitHub) | `contact_us_entry.dart` | Dipertahankan |
| Help center FAQ | `help_center_sheet.dart` | Dipertahankan |
| Insight & expense flow | `financial_insight_*`, `expense_flow_*` | Restyle, bukan hapus |
| Cash flow & balance trend | `analytics/presentation/widgets/*` | Hanya terjangkau lewat `AnalyticsPage` yang belum terhubung |
| Kategori custom + sembunyikan kategori | `manage_categories_sheet.dart`, `hidden_*_categories` | Dipertahankan |
| Perayaan target (confetti) | `goal_celebration_dialog.dart` | Dipertahankan, opsional dipoles |
| Guest account & account linking | `auth_landing_page.dart`, `account_security_sheet.dart` | Dipertahankan |

---

## 5. Jawaban Pertanyaan Terbuka PRD

### 5.1 Di mana alur "Buat target" sekarang?

Saat ini **hanya** lewat tombol `+` tengah di `FloatingPillNavigation`:

```text
AppShell → _CreateOptionsSheet → AddGoalSheet
```

`SavingsPage` **tidak** punya FAB atau tombol tambah. Jadi saat navigasi diganti menjadi `NavigationBar`, alur ini akan hilang jika tidak diganti.

**Rekomendasi:** tambahkan `FloatingActionButton` kontekstual di tab Target ("Buat target"), dan pertahankan sheet opsi hanya jika tombol `+` tengah tetap dipertahankan.

### 5.2 Apa saja yang dilakukan ikon notifikasi di header?

`Icons.notifications_none_rounded` hanya menampilkan `SnackBar`:

```text
"Belum ada notifikasi baru"
```

Tidak ada model notifikasi, unread count, atau deep link. **Rekomendasi:** pertahankan perilaku sementara, atau sembunyikan ikon sampai fitur notifikasi benar-benar ada. Jangan membuat fitur baru di refactor ini.

### 5.3 Field tambahan apa yang ada di model?

**`TransactionEntity`**
- `id`, `amount`, `type`, `category`, `date`, `note`
- `goalId` (nullable) — penanda transaksi alokasi tabungan
- getter `isAllocation => goalId != null`

**`SavingsGoalEntity`**
- `id`, `title`, `targetAmount`, `currentAmount`, `deadline`
- `createdAt` — dipakai untuk sorting terbaru/terlama
- `isArchived` — arsip target

**SharedPreferences** (`SettingsService`) — 12 key:
`monthly_budget_limit`, `theme_mode`, `savings_sort_option`, `user_name`,
`user_profile_type`, `privacy_mode`, `budget_cycle_date`,
`last_successful_sync`, `profile_avatar_id`, `onboarding_completed`,
`hidden_expense_categories`, `hidden_income_categories`.

> Catatan: `isFavorite` **tidak lagi ada** di entity/model saat ini. Dokumentasi lama (`progress.md`, `task.md`) masih menyebut field tersebut, tetapi kode sudah bersih. Tidak ada pekerjaan yang diperlukan.

### 5.4 Apakah `fl_chart` dipakai di tempat lain?

Ya. `fl_chart` dipakai di **4 file**:

| File | Chart |
| --- | --- |
| `dashboard/presentation/widgets/category_expense_pie_card.dart` | `PieChart` (kategori pengeluaran) |
| `dashboard/presentation/widgets/financial_insight_overview_sheet.dart` | `BarChart` internal (cash flow 7 hari) |
| `analytics/presentation/widgets/cash_flow_chart_card.dart` | bar chart 7/30 hari/siklus |
| `analytics/presentation/widgets/balance_trend_chart_card.dart` | line chart tren saldo |

**Kesimpulan:** jangan lepas `fl_chart`. Penggantian PieChart menjadi stacked bar di Beranda hanya menghapus **satu** pemakaian; tiga pemakaian lain tetap dibutuhkan.

### 5.5 Berapa banyak warna literal dan gradient?

**Warna literal `Colors.*` (di luar `Colors.transparent`): 42 referensi di 14 file.**

Angka ini hasil scan case-sensitive dengan word boundary
(`Select-String -CaseSensitive -Pattern '\bColors\.'`). Scan tanpa
`-CaseSensitive` salah menghitung variabel `colors.` dan `AppColors.`
sehingga angkanya membengkak.

| Jumlah | File |
| ---: | --- |
| 8 | `settings/presentation/widgets/settings_data_section.dart` |
| 7 | `settings/presentation/widgets/settings_profile_section.dart` |
| 5 | `dashboard/presentation/widgets/budget_status_section.dart` |
| 4 | `savings/presentation/widgets/edit_allocation_sheet.dart` |
| 4 | `transactions/presentation/widgets/quick_add_transaction_sheet.dart` |
| 3 | `dashboard/presentation/widgets/category_expense_pie_card.dart` |
| 2 | `transactions/presentation/widgets/category_icon.dart` |
| 2 | `settings/presentation/widgets/settings_financial_section.dart` |
| 2 | `transactions/presentation/widgets/transaction_tile.dart` |
| 1 | `core/theme/app_theme.dart` (baru, `Colors.black54` untuk barrier) |
| 1 | `core/navigation/app_shell.dart` |
| 1 | `dashboard/presentation/pages/dashboard_page.dart` |
| 1 | `settings/presentation/widgets/profile_avatar_sheet.dart` |
| 1 | `onboarding/presentation/pages/onboarding_page.dart` |

**Gradient: 11 titik saat audit Batch 0.** `AppPageBackground` sudah
dibersihkan di Batch 1, jadi tersisa **10 titik** yang harus disapu per layar.

| File | Baris | Jenis |
| --- | ---: | --- |
| `core/widgets/app_page_background.dart` | 29 | `LinearGradient` |
| `features/auth/presentation/pages/auth_landing_page.dart` | 69 | `LinearGradient` |
| `features/dashboard/presentation/widgets/balance_hero_card.dart` | 50 | `LinearGradient` |
| `features/dashboard/presentation/widgets/budget_status_section.dart` | 525 | `LinearGradient` |
| `features/dashboard/presentation/widgets/category_expense_pie_card.dart` | 417 | `LinearGradient` |
| `features/dashboard/presentation/widgets/dashboard_empty_state.dart` | 30 | `LinearGradient` |
| `features/dashboard/presentation/widgets/financial_insight_card.dart` | 35 | `LinearGradient` |
| `features/onboarding/presentation/widgets/onboarding_slide.dart` | 248 | `RadialGradient` |
| `features/settings/presentation/widgets/help_center_entry.dart` | 28 | `LinearGradient` |
| `features/settings/presentation/widgets/help_center_sheet.dart` | 51 | `LinearGradient` |
| `features/transactions/presentation/widgets/transaction_tile.dart` | 31 | `LinearGradient` |

---

## 6. Audit Fondasi Visual Saat Ini

| Aspek | Kondisi sekarang | Masalah |
| --- | --- | --- |
| Font | `google_fonts` → Inter, diunduh runtime | Butuh internet saat pertama kali; tidak cocok untuk mode offline |
| Light theme | `ColorScheme.fromSeed(#0F766E)` + background `#F5F8F7` | Warna peran sulit dikontrol presisi |
| Dark theme | Palet manual `#121417` + surface `#1C2026` + teal `#2DD4BF` | `surfaceContainerLow/High` semuanya sama → hierarchy datar |
| Background | `AppPageBackground`: dark flat, light gradient tipis | Sumber kesan "polos" di dark |
| Card | Radius 24, elevation 1, border tipis | Semua section terlihat setara |
| Navigation | Floating pill 72px + FAB tengah translasi -15 | Menutupi konten, label terpotong |
| Spacing | Tidak ada token; angka 12/14/16/18/20/22/24/28 bercampur | Tidak konsisten |
| Radius | 12/14/16/18/20/24/28/30/38 bercampur | Tidak ada skala |
| Warna semantik | `income`/`expense` didefinisikan lokal di beberapa widget | Duplikasi & mudah melenceng |
| Chart | `fl_chart` 1.0.0 dipatok exact | Jangan upgrade tanpa uji kompatibilitas Flutter 3.32 |

### Catatan kompatibilitas

1. **Dua `MaterialApp`** di `main.dart` (`_AuthGate` dan `SavuApp`) sama-sama memakai `SavuTheme`. Setiap perubahan nama/API theme harus diperbarui di keduanya.
2. **Kategori sistem `'Alokasi Tabungan'`** masih ditulis oleh `savings_providers.dart` untuk transaksi alokasi. Jangan ubah string ini tanpa migrasi data.
3. **Privacy mode hanya berlaku di Beranda**, bukan Riwayat — sesuai keputusan user sebelumnya.
4. **Windows** memakai `WriteBatch` untuk alokasi karena bug `runTransaction` di `cloud_firestore` 5.6.x. Refactor UI tidak boleh menyentuh jalur ini.
5. **`AnalyticsPage` tidak terhubung** ke navigasi. Jangan hapus; bisa dijadikan target batch lanjutan.
6. **File generated platform** hanya berubah line-ending (CRLF) saat audit. Sudah direstore agar tidak ikut commit.

---

## 7. Rekomendasi Penyesuaian PRD

Tujuh koreksi berikut disetujui sebelum eksekusi:

1. **Gradient dihapus total** — termasuk hero, background, auth, onboarding, help center, dan swipe background. Kedalaman diganti tone permukaan + hairline. Ini membalik preferensi lama (progress.md mencatat gradient pernah diminta), jadi keputusan ini eksplisit.
2. **Navigasi:** `NavigationBar` 4 tab + `FloatingActionButton.extended` "Catat" di `endFloat`. Tidak memakai pill melayang lagi. Tombol tengah hanya dipertahankan jika user memintanya.
3. **Satu sumber kebenaran warna:** `ColorScheme` untuk warna peran; `AppColors` hanya untuk `income`, `danger`, `warning`, dan palet kategori. Jangan duplikasi `primary`.
4. **Layar tambahan masuk batch:** Auth Landing, Email Verification, Onboarding, Insight/Analytics sheet, sheet alokasi/edit target, dan celebration dialog.
5. **Desktop/Web:** bungkus konten dengan max-width 640–720dp agar tidak melar.
6. **String terpusat:** `AppStrings` hanya untuk label bersama (nav, aksi, empty state). Copy spesifik layar tetap di widget agar tidak scope creep.
7. **DoD:** audit `Colors.*` dan gradient di seluruh `lib/`, bukan hanya `features` + `shared`. Perintah `grep -P` diganti PowerShell/ripgrep yang tersedia di Windows.

---

## 8. Risiko dan Mitigasi

| Risiko | Mitigasi |
| --- | --- |
| Widget test lama gagal karena copy/struktur berubah | Update test bersama batch terkait, jangan tunda ke Batch 7 |
| Font asset belum tersedia | Unduh Plus Jakarta Sans (variable/4 weight) + lisensi OFL di Batch 1; hapus `google_fonts` setelah migrasi |
| APK bertambah karena font | Gunakan 3–4 weight saja; ukur `flutter build apk --release` |
| `lib/shared/` belum ada | Buat folder di Batch 2; migrasi `core/widgets` secara bertahap |
| Warna literal 42 titik | Sapu per batch sesuai layar; DoD mencegah regresi |
| Dua `MaterialApp` lupa diperbarui | Checklist Batch 1 |
| Fitur tidak sengaja hilang | Inventory Bagian 4 menjadi checklist regresi |
| Gradient removal mengubah karakter visual | Review screenshot light/dark setiap batch sebelum commit |

---

## 9. Rencana Batch

| Batch | Isi | Status |
| --- | --- | --- |
| 0 | Audit + branch + aturan git | **Selesai** |
| 1 | Fondasi tema: token, font bundled, `ThemeExtension`, palet kategori | **Selesai** |
| 2 | Komponen bersama + widget test light/dark | **Selesai** |
| 3 | Shell + Beranda | **Selesai** |
| 4 | Riwayat | **Selesai** |
| 5 | Target | **Selesai** |
| 6 | Form transaksi + Pengaturan + Auth/Onboarding + sheet | Belum |
| 7 | Polish: motion, aksesibilitas, dark sweep, dokumentasi | Belum |

### Gate setiap batch

```powershell
flutter analyze
flutter test
git status --short
```

### Catatan Batch 4 — Riwayat (2026-11-05)

- Pencarian inline di app bar, segmented control tipe, dan filter tambahan
  dalam bottom sheet telah diterapkan.
- Filter periode, kategori, dan siklus aktif tetap tersedia; chip aktif dapat
  dihapus satu per satu dan semua filter dapat di-reset.
- Daftar memakai grup tanggal tanpa kartu bertingkat, ringkasan net harian,
  serta overview harian. Tap baris membuka edit; swipe tetap meminta konfirmasi
  hapus.
- CSV tetap tersedia di Pengaturan. Empty state Beranda dan Riwayat tidak
  memiliki CTA tambahan dan mengarahkan pengguna ke FAB `+`.
- Validasi selesai: `flutter analyze` bersih, `flutter test` 116/116 lulus,
  `flutter build web` berhasil. Test Riwayat mencakup lebar 360dp dan text scale
  1.3.

### Catatan Batch 5 — Target dan header Beranda (2026-11-05)

- Header Beranda mempertahankan nama profil sebagai identitas utama dan tidak
  lagi menambahkan badge “Tamu” yang bertentangan dengan nama profil.
- Aksi arsip dan pengurutan Target tersedia pada menu overflow; pemilihan urutan
  dilakukan melalui bottom sheet. Tab Aktif/Selesai dan penghitung tetap ada.
- Empty state menggunakan widget bersama, halaman Target mengikuti max-width
  dan spacing token, serta label tenggat membatasi baris agar tidak overflow.
- Uji regresi khusus tersedia di `test/dashboard_header_test.dart` dan
  `test/savings_page_test.dart`.
- Validasi selesai: `flutter analyze` bersih, `flutter test` 119/119 lulus,
  `flutter build web` berhasil. Test Target memvalidasi layout 360dp dengan
  text scale 1.3.

### Audit DoD (dijalankan di seluruh `lib/`)

```powershell
# Gradient harus kosong
Select-String -Path (Get-ChildItem -Recurse lib -Filter *.dart).FullName `
  -Pattern 'LinearGradient|RadialGradient|SweepGradient'

# Warna literal harus kosong (kecuali Colors.transparent).
# -CaseSensitive wajib: tanpa itu variabel `colors.` dan `AppColors.` ikut terhitung.
Select-String -CaseSensitive `
  -Path (Get-ChildItem -Recurse lib -Filter *.dart).FullName `
  -Pattern '\bColors\.' |
  Where-Object { $_.Line -notmatch '\bColors\.transparent' }
```

---

### Catatan Batch 10 — Motion polish dan reduced motion (2026-11-06)

- **Root cause animasi seolah tidak berjalan** bukan di mode build (Run Run Without
  Debugging tetap debug JIT) melainkan pengaturan perangkat: pada `RR8X100CH5Z`,
  `animator_duration_scale`, `transition_animation_scale`, dan `window_animation_scale`
  semuanya `0.0`. Flutter membaca ini sebagai `AccessibilityFeatures.disableAnimations`,
  sehingga semua animasi melesat ke posisi akhir. Perbaikan di perangkat:

  ```powershell
  $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
  & $adb -s RR8X100CH5Z shell settings put global window_animation_scale 1
  & $adb -s RR8X100CH5Z shell settings put global transition_animation_scale 1
  & $adb -s RR8X100CH5Z shell settings put global animator_duration_scale 1
  ```

  lalu restart aplikasi. Atau manual: Settings → Developer options → Animator duration
  scale → 1x (plus Transition dan Window animation scale).
- **Kualitas animasi dinilai di mode profile/release**, bukan debug:
  `flutter run --profile -d RR8X100CH5Z` untuk menilai kehalusan, `--release` untuk hasil akhir.
- `AppMotion` (`lib/core/theme/app_motion.dart`) menjadi satu pintu reduced motion:
  `isReduced(context)`, `durationOf(context, base)` mengembalikan `Duration.zero` bila
  reduced motion aktif; `AppMotion.standard` = `Curves.easeOutCubic`.
- Widget baru `AppEntrance` (`lib/shared/widgets/app_entrance.dart`): fade + geser 8dp
  sekali saat dipasang, 280 ms, menghormati reduced motion, dan melepas `Opacity` saat
  selesai. Dipakai di keempat tab (Beranda, Target, Riwayat, Pengaturan).
- Semua durasi animasi yang tersisa memakai helper/`AppDuration`: transisi
  onboarding↔auth↔shell (420/280 ms), counter saldo (600 ms), progress bar anggaran dan
  target (400 ms), kartu target, ilustrasi onboarding, pemicu seleksi grafik, sheet
  avatar, animasi profil, dan confetti dialog (tidak diputar saat reduced motion).
- Pindah tab tetap memakai `IndexedStack` (state dan posisi scroll tetap terjaga) dan
  tidak diberi transisi tambahan. Indikator `NavigationBar` sudah animatif secara default.
- Dasar verifikasi: `flutter analyze` bersih, `flutter test` 134/134 lulus (2 test motion
  ditambahkan), `test/app_theme_test.dart` tetap hijau.
- _Device verification pending:_ A15 terputus saat eksekusi adb; perbaikan device ini wajib
  diverifikasi manual pada perangkat sebelum batch dianggap selesai. Test automatis tidak
  bisa mengecek Skala animator Samsung.

---

## 10. Keputusan yang Menunggu Konfirmasi User

1. Setuju menghapus **semua** gradient, termasuk swipe-to-delete?
2. Navigasi akhir: `NavigationBar` + FAB `endFloat`, atau tetap tombol tengah?
3. Apakah `AnalyticsPage` mau dihubungkan ke navigasi pada batch lanjutan, atau tetap tersembunyi?
4. Apakah ikon notifikasi dipertahankan sebagai placeholder atau disembunyikan?

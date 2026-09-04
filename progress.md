# 🔄 PROGRESS HANDOFF - Savu

> File ini dibuat untuk melanjutkan sesi di model AI lain tanpa kehilangan memori.
> **Cara pakai di sesi baru:** suruh AI `baca progress.md + task.md + AGENTS.md + PRD.md` lalu lanjutkan dari `NEXT TASK` di bawah.

---

## 🕐 Timestamp

- **Terakhir update:** 2026-09-03
- **Branch aktif:** `develop_dua` (sinkron dengan `origin/develop_dua`, 0 commit tertinggal)
- **Dibuat oleh:** Andre Robert

---

## 📍 Posisi Saat Ini

- **FASE 1 TUNTAS** (Task 1-6) → merge ke `main` via PR #3 `54724a4`
- **FASE 2 TUNTAS** (Task 7-9) → `83b13fe`, `81aa315`
- **FASE 3 TUNTAS** (Task 10-12)
- **FASE 4 TUNTAS** (Task 13 Settings Page & Premium UI)
- **Rebrand selesai:** aplikasi sekarang bernama **Savu** (`6dab288`), lengkap dengan launcher
  icon, nama package Android `com.example.savu`, dan metadata Windows/macOS/Linux.
- **Kesehatan kode terakhir (2026-09-04):**
  - `flutter test` → **69/69 lulus** (bukan 52 lagi; bertambah sejak penambahan
    use case budget cycle, cash flow, balance trend, expense flow, allocation summary,
    dan error message).
  - `flutter analyze` → **No issues found**. Lima info Tahap 30 sudah diperbaiki.
- **Working tree:** bersih (`git status` kosong). Semua perubahan sudah ter-commit.
- **NEXT:** lanjutkan Tahap 31: daftarkan SHA release, deploy/validasi Firebase
  Hosting dan Firestore Rules, lalu uji Google Sign-In serta deep link APK release.
  (lihat "BACKLOG 11 REKOMENDASI LANJUTAN" → "Tahap 22" dst).

### Git Status Saat Ini

```
Branch: develop_dua (tracking origin/develop_dua, ahead 0 / behind 0)
Last commits (2026-09-03):
   7171105 feat: change target progress card color when above 50% and when at 100%
   bb468d0 feat: mengubah warna progress card target ketika diatas 50% dan ketika sudah 100%
   c5e99e3 feat: Change the font color of expenses and averages in financial insights to be lighter
   96a246a fix: perbaikan spacing dan padding form catatan baru serta ganti kategori Alokasi Tabungan menjadi Kesehatan & Perawatan
   f7b773f feat: tambah onboarding page dengan animasi transisi dan pengingat pengguna baru
   e0803c1 feat: enlarge the cancel button on the delete target and history menu
   28f2ba1 feat: modify all colors in dark theme
   cb8dab4 feat: added a photo widget on the avatar to make it more visible and clickable
   34a7d21 fix: remove double logo
   a1ecb71 fix: configure Savu launcher icon and assets
   6dab288 refactor: rebrand application name from MoneyTracker to Savu

Uncommitted saat handoff: tidak ada (working tree clean)
```

> **Catatan penting:** `progress.md` ini terakhir disentuh commit `6dab288`, sehingga seluruh
> commit setelahnya tidak tercatat di sini. Bagian "PERUBAHAN PASCA-HANDOFF" di bawah
> direkonstruksi langsung dari `git log` + isi diff branch `develop_dua`.

---

## ✅ Apa yang Baru Selesai

1. **Fix Bug UI Android:** Memperbaiki teks nominal yang meluber (`history_page.dart` & `transaction_tile.dart`) dengan `ConstrainedBox` dan `Flexible`. Serta memperbaiki `SegmentedButton` tema yang wrap ke bawah dengan menggantinya menjadi desain `_ThemeChip` kustom.
2. **Task 13 (Premium Settings UI):** Merombak total halaman Pengaturan agar terlihat seperti aplikasi finansial modern. Menambahkan Avatar/Nama, status sinkronisasi, sakelar Mode Privasi (sensor saldo di beranda), pengaturan Siklus Anggaran, dan tombol _Danger Zone_ hapus data.
3. **History UI interaktif:** Nominal tidak lagi terpotong pada Android, header tanggal dapat ditekan, dan bottom sheet overview harian menampilkan total pemasukan, pengeluaran, selisih bersih, serta daftar transaksi.
4. **Pie chart interaktif:** Segmen dan legend dapat dipilih, kategori aktif di-highlight, informasi kategori muncul di tengah chart, dan tersedia bottom sheet detail kategori dengan total, persentase, rata-rata, transaksi terbesar, serta daftar transaksi.
5. **Status Anggaran interaktif:** Card membaca transaksi aktual dan tanggal siklus anggaran. Overview menampilkan status, progress, sisa/kelebihan, periode, jumlah transaksi, rata-rata harian, proyeksi akhir periode, dan tiga kategori terbesar.
6. **Domain budget overview:** Ditambahkan `BudgetOverviewEntity` dan `CalculateBudgetOverviewUseCase`, termasuk dukungan siklus yang melewati pergantian bulan.
7. **Testing:** Ditambahkan `calculate_budget_overview_usecase_test.dart`. Suite bertumbuh
   menjadi **69 test** setelah penambahan use case budget cycle, cash flow, balance trend,
   expense flow insight, allocation summary, dan pemetaan error terpusat.

---

## 🆕 PERUBAHAN PASCA-HANDOFF (belum pernah tercatat di file md manapun)

Bagian ini direkonstruksi dari `git log` branch `develop_dua` karena file md terakhir
diperbarui pada `6dab288`. Urutan dari yang terbaru.

### 1. Rebranding MoneyTracker → Savu (`6dab288`, `a1ecb71`, `34a7d21`)

- Nama package di `pubspec.yaml` menjadi `savu`, deskripsi aplikasi diperbarui.
- `MainActivity.kt` dipindah ke package `com.example.savu`.
- Launcher icon baru `assets/images/app_icon.png` dihasilkan untuk Android (mipmap
  semua density), iOS (`AppIcon.appiconset`), Web (`web/icons/*` + `favicon.png`),
  Windows (`app_icon.ico`), dan macOS.
- `flutter_launcher_icons` ditambahkan ke `dev_dependencies` dan dikonfigurasi di
  `pubspec.yaml` (minSdk 21, warna tema `#0F766E`).
- Judul aplikasi, `web/manifest.json`, `web/index.html`, `Runner.rc`, dan
  `AppInfo.xcconfig` disesuaikan ke nama Savu.
- Logo ganda dihapus (`34a7d21`), menyisakan satu aset `Savu_logo.png` di `assets/images/`
  (file ini TIDAK terdaftar di `pubspec.yaml`; hanya dipakai sebagai aset sumber icon).
- Seluruh judul PRD/README dan metadata platform mengikuti nama baru.

### 2. Penyempurnaan Profil & Avatar (`a992904`, `402f04c`, `70bf265`, `6340933`, `cb8dab4`)

- **Foto profil preset:** `SettingsService` menyimpan `profile_avatar_id` di
  SharedPreferences (default `'sunrise'`), diekspos melalui `profileAvatarProvider`.
- Katalog avatar di `profile_avatar_sheet.dart` berisi **30 preset** dalam 2 kategori:
  - `general` (15): sunrise, leaf, rocket, star, coffee, bolt, favorite, palette,
    sports, travel, diamond, security, lightbulb, pets, balance.
  - `people` (13): avatar wajah berlabel nama (`person_blue` = Andre, `person_pink` =
    Chelsie, `person_green`, `person_orange`, `person_purple`, `person_teal`,
    `person_red`, `person_cyan`, `person_indigo`, `person_lime`, `person_amber`,
    `person_violet`, `person_slate`, `person_rose`, `person_mint`).
- Avatar di header Settings sekarang **dapat diketuk** untuk membuka
  `ProfileAvatarSheet`, memakai `InkWell` + `AnimatedSwitcher` (fade + scale).
- **Filter gender dihapus** (`6340933`): `_GenderSelector` beserta `ChoiceChip`
  Laki-laki/Perempuan dibuang. Enum `PresetAvatarGender` masih ada sebagai metadata
  avatar, tapi tidak lagi dipakai untuk memfilter UI.
- Grid avatar responsif: 3 kolom di lebar < 360px, 4 kolom di atasnya.
- Widget foto pada avatar dibuat lebih terlihat dan clickable (`cb8dab4`).
- `main.dart` ikut disesuaikan (`70bf265`) untuk system navigation bar.

### 3. Kontak Founder & Feedback (`4a546bf`, `d23212c`, `05de391`)

- `ContactUsEntry` di Settings menggantikan sheet berbagi generik menjadi aksi langsung:
  - Email → intent Gmail/Android + fallback `url_launcher` (`mailto:`).
  - WhatsApp → `android_intent_plus` ke nomor `62895338891504` (tampil `0895338891504`).
  - GitHub → `https://github.com/andrest1101`.
- Import `share_plus` di `contact_us_entry.dart` diganti `url_launcher` +
  `android_intent_plus` + `dart:io`.
- Tombol "kirim feedback" yang terlalu besar diperkecil (`d23212c`).

### 4. Dialog & Greeting Konsisten (`1ec64b1`, `7b1dcf1`, `9cf2bd8`)

- Aksi dialog Settings diseragamkan dan overflow dicegah (`1ec64b1`); juga berlaku pada
  `quick_add_transaction_sheet.dart`.
- Greeting Dashboard dan dialog edit profil disinkronkan (`7b1dcf1`): nama yang
  tersimpan di SharedPreferences kini **diutamakan** di atas `displayName` Google atau
  potongan email; fallback hanya dipakai saat nama tersimpan kosong.
- Tombol batal pada menu ganti akun diperbesar (`9cf2bd8`).

### 5. Onboarding Page (`f7b773f`) — ⚠️ PERUBAHAN BESAR PADA ALUR BOOTSTRAP

- Fitur baru di `lib/features/onboarding/`:
  - `presentation/pages/onboarding_page.dart` (288 baris) — `PageController` + indikator halaman.
  - `presentation/widgets/onboarding_slide.dart` (775 baris) — data slide, ilustrasi
    custom (`OnboardingIllustrationKind`: transactions, budget, savings, ...), dan
    highlight fitur.
- Slide yang tersedia:
  1. **Pencatatan Kilat** — "Catat Transaksi Dalam Hitungan Detik", aksen `#2DD4BF`.
  2. **Kontrol Anggaran** — "Pantau Anggaran, Cegah Boncos", alert 3 tingkat + siklus gajian 1-28, aksen `#60A5FA`.
  3. **Mode Selesai & Arsip** — target tabungan, alokasi atomik, arsip.
- **Alur bootstrap berubah** di `main.dart`:
  - `SettingsService` mendapat `getOnboardingCompleted()` dan `setOnboardingCompleted()`.
  - Provider baru `onboardingCompletedProvider` (`OnboardingCompleted extends Notifier<bool>`).
  - `_AuthGate.build()` sekarang memilih: onboarding belum selesai → `OnboardingPage`;
    sudah selesai → `_AuthContent` (AuthLanding / EmailVerification / SavuApp).
  - Transisi memakai `AnimatedSwitcher` (420ms fade + slide).
- ⚠️ **Dampak yang perlu diuji:** user lama yang sudah punya data akan melihat onboarding
  satu kali karena flag `onboarding_completed` belum pernah diset.

### 6. Kategori & Form Transaksi (`96a246a`)

- Kategori default pengeluaran **"Alokasi Tabungan" diganti menjadi
  "Kesehatan & Perawatan"** di `_defaultExpenseCategories`
  (`dashboard_providers.dart:109`).
- Ikon kategori baru ditambahkan di `category_icon.dart`:
  `'Kesehatan & Perawatan'` → `Icons.health_and_safety`, warna `#E84393`.
- ⚠️ **Catatan migrasi data:** transaksi lama yang tersimpan dengan kategori
  "Alokasi Tabungan" **tetap memakai kategori tersebut** (tetap ada di
  `category_icon.dart:21`), dan `quick_add_transaction_sheet.dart:78` secara eksplisit
  membuang kategori itu dari daftar chip (`all.where((c) => c != 'Alokasi Tabungan')`).
  Alokasi otomatis ke target tetap memakai string `'Alokasi Tabungan'` di
  `savings_providers.dart:227` — **jangan diubah** tanpa migrasi data Firestore.
- Spacing dan padding form catatan baru diperbaiki.

### 7. Warna & Tema (`28f2ba1`, `c5e99e3`, `bb468d0`, `7171105`)

- **Dark theme dirombak total** (`28f2ba1`, 25 file): `SavuTheme` dipecah menjadi
  `_buildLight()` (masih `ColorScheme.fromSeed`) dan `_buildDark()` (palet manual penuh):
  - scaffold `#121417` (deep charcoal), surface/surfaceHigh/surfaceLow `#1C2026` (solid slate).
  - aksen teal terang `#2DD4BF` untuk primary/secondary/tertiary + `onPrimary` `#121417`.
  - error `#EF5350`, onSurface putih penuh `#FFFFFF`, onSurfaceVariant `#9CA3AF`.
  - outline `#3A414A`, outlineVariant `#2B3138`, inverseSurface `#F3F4F6`.
- Penerapan ke seluruh widget: app_shell, app_page_background, analytics
  (cash flow/balance trend/expense flow), auth landing, dashboard (pie card, empty state,
  financial insight + overview), savings, settings (account security, contact us,
  help center, profile avatar, settings content), history (category filter sheet,
  quick add sheet, transaction tile).
- Warna teks pengeluaran dan rata-rata pada Financial Insight dibuat lebih terang
  (`c5e99e3`) di `financial_insight_card.dart`, `financial_insight_overview_sheet.dart`,
  dan `expense_flow_overview_sheet.dart`.
- **Warna progress card target** (`bb468d0`) — aturan baru di `goal_card.dart`:
  - `progress >= 1.0` (selesai) → hijau terang: `#4ADE80` dark / `#10B981` light.
  - `progress >= 0.5` → biru terang: `#38BDF8` dark / `#2563EB` light.
  - `progress < 0.5` → `cs.primary`.
  - Border card mengikuti: selesai → `progressColor` alpha .4 lebar 1.5;
    ≥ 50% → `progressColor` alpha .3 lebar 1.2; < 50% → `outlineVariant` alpha .3 lebar 1.
- **Warna peringatan budget** (`7171105`) diganti dari `cs.tertiary` menjadi konstanta
  eksplisit `#FBBF24` (dark) / `#D97706` (light), diterapkan di `_BudgetAlertBody`,
  `_BudgetOverviewSheet`, dan sheet edukasi `_BudgetInfoSheet` (kini menerima
  `warningColor` dan tiap level punya warna sendiri: primary / warning / error).

### 8. Target Tabungan — Menu & Arsip (`9530cd5`, `2904310`, `e0803c1`, `9791712`)

- `SavingsGoalEntity` mendapat field **`isArchived`** dan **`isFavorite`** (default
  `false` agar dokumen Firestore lama tetap kompatibel), lengkap dengan `copyWith`,
  `==`, dan `hashCode`.
- Provider baru di `savings_providers.dart`:
  - `archivedModeProvider` (`ArchivedModeController`) — toggle mode arsip.
  - `archivedActiveGoalsProvider` — target terarsip yang belum selesai.
  - `archivedCompletedGoalsProvider` — target terarsip yang sudah selesai.
  - `activeGoalsProvider`/`completedGoalsProvider` kini memfilter `!isArchived`.
- `SavingsActionsController.setArchived()` dan `.setFavorite()` ditambahkan.
- **Penghapusan target selesai dipisah:** `deleteCompletedGoal()` hanya menghapus
  dokumen target dan **mempertahankan transaksi alokasi sebagai ledger** agar saldo
  utama tidak berubah; target aktif tetap memakai `deleteGoalWithAllocations()`.
- ⚠️ **Favorit dihapus dari UI** (`2904310`): `_GoalAction.favorite` beserta
  `onFavorite` dibuang dari `goal_card.dart`, dan `SavingsActionsController.setFavorite()`
  dihapus. Field `isFavorite` **masih ada di entity/model** namun tidak terpakai —
  kandidat pembersihan berikutnya.
- Widget `savings_overview.dart` **dihapus** pada `9530cd5`.
- Tombol batal pada dialog hapus target dan menu riwayat diperbesar (`e0803c1`) menjadi
  `OutlinedButton` berdampingan dengan `FilledButton`, masing-masing
  `minimumSize: Size.fromHeight(48)`.
- Dialog konfirmasi hapus kini menjelaskan perbedaan dampak: target selesai →
  "Riwayat alokasi tetap dicatat sebagai transaksi historis agar saldo tidak berubah";
  target aktif → "Dana yang sudah dialokasikan (Rp X) akan dikembalikan ke saldo utama".

### 9. Dashboard & Chart (`02f16f5`, `6895191`, `73a4f07`, `620d6c9`, `33745eb`)

- Sheet edukasi status anggaran ditambahkan (`02f16f5`, +148 baris di
  `dashboard_page.dart`) — menjelaskan 3 tingkat status ke user.
- Interaksi chart mobile diperbaiki (`6895191`) pada `cash_flow_chart_card.dart` dan
  `balance_trend_chart_card.dart`.
- Chart Financial Insight responsif terhadap tap (`73a4f07`).
- Budget overview terhubung ke History berfilter (`620d6c9`) melalui
  `historyNavigationIntentProvider` yang dipantau `AppShell` untuk pindah tab otomatis.
- Navigasi floating action beranimasi (`33745eb`).

---

## 📋 NEXT TASK YANG TERTUNDA

Karena FASE 1-4 sudah selesai semua secara fundamental, langkah selanjutnya adalah:

1. **Tahap 30 selesai:** lima info `flutter analyze` sudah diperbaiki tanpa perubahan
   perilaku fitur.
2. **Validasi alur onboarding:** pastikan user lama (sudah punya data Firestore) tidak
   terjebak di onboarding, dan bahwa `onboarding_completed` tersimpan benar.
3. **Uji regresi kategori "Kesehatan & Perawatan":** cek transaksi lama berkategori
   "Alokasi Tabungan" tidak hilang dari pie chart dan filter.
4. **Validasi di device Android:** cek dark theme baru, warna progress target, warna
   peringatan budget, avatar picker, dan kontak founder (WA/Gmail intent).
5. **Penyempurnaan Opsional:**
   - Melengkapi fitur Ekspor CSV. (sudah selesai)
   - Melengkapi fitur Hapus Data Massal (Danger Zone). (sudah selesai)
   - Halaman FAQ / Pusat Bantuan. (sudah selesai)

## 🧭 BACKLOG 11 REKOMENDASI LANJUTAN

Pengerjaan dilakukan satu langkah pada satu waktu, setelah mendapat persetujuan user:

1. Validasi Android dan perbaikan layout responsif, terutama overflow pada layar kecil.
2. Perbaikan error handling Settings dengan feedback `SnackBar` saat penyimpanan gagal.
3. Melengkapi FAQ / Pusat Bantuan dan menghapus placeholder fitur.
4. Ekspor transaksi ke CSV melalui system share sheet.
5. Hapus semua data dengan dialog konfirmasi berlapis dan proses batch yang aman.
6. Memisahkan target tabungan menjadi tab Aktif dan Selesai.
7. Menambahkan status visual target, termasuk target selesai dan deadline yang semakin dekat.
8. Menyempurnakan riwayat alokasi pada setiap target tabungan.
9. Menambahkan filter riwayat transaksi berdasarkan kategori.
10. Menambahkan filter riwayat berdasarkan siklus anggaran aktif.
11. Menambahkan insight keuangan mingguan atau bulanan.

### Status Backlog

- [x] Tahap 1: validasi layout Android dan perbaikan overflow header profil Settings.
- [x] Tahap 2: feedback `SnackBar` untuk keberhasilan atau kegagalan penyimpanan Settings.
- [x] Tahap 3: FAQ / Pusat Bantuan dengan UI bottom sheet profesional dan FAQ expandable.
- [x] Tahap ekspor CSV: transaksi dapat dibagikan melalui system share sheet.
- [x] Tahap hapus semua data: transaksi dan target dihapus dengan batch aman serta konfirmasi berlapis.
- [x] Tahap target Aktif/Selesai: tab dan badge status sudah tersedia.
- [x] Tahap status visual target: progress, target tercapai, tenggat dekat, dan tenggat terlewat.
- [x] Step 8: riwayat alokasi memiliki ringkasan total, jumlah aktivitas, dan alokasi terakhir.
- [x] Step 9: riwayat transaksi memiliki filter kategori dinamis.
- [x] Step 10: riwayat transaksi memiliki filter siklus anggaran aktif lintas bulan.
- [x] Step 11: Dashboard memiliki insight keuangan berbasis siklus anggaran dan tren periode sebelumnya.
- [x] Step 12: Filter kategori History dipindahkan ke searchable bottom sheet dengan icon, jumlah transaksi, dan reset kategori.
- [x] Step 13: Status sinkronisasi profil membaca stream Firestore, edit alokasi memvalidasi saldo bulan berjalan, dan branding footer menjadi Product by Andre Robert.
- [x] Step 15: Operasi tambah, edit, dan hapus alokasi memakai Firestore Transaction untuk mencegah race condition.
- [x] Step 16: Penghapusan target dengan banyak riwayat alokasi memakai chunked batch 450 dokumen dan batch terpisah untuk target.
- [x] Step 17: Modularisasi awal Settings: section title, Help Center, FAQ sheet, dan branding dipindahkan ke widget terpisah tanpa mengubah UI premium.
- [x] Step 18: Entry page Settings dipisahkan dari komposisi content; `settings_page.dart` kini ringan dan implementasi tetap modular di folder widgets.
- [x] Step 19: Empty state Dashboard dibuat informatif untuk transaksi, pie chart, dan financial insight dengan visual premium serta CTA.
- [x] Step 20: Status sinkronisasi Settings menampilkan loading, sukses, offline/gagal, retry, dan waktu pembaruan terakhir.
- [x] Step 21: Firebase Anonymous Authentication dan path user-scoped untuk transaksi serta target sudah diterapkan.
- [x] Security hardening: AuthGate menampilkan error + retry saat Anonymous Auth gagal; repository tidak lagi memakai fallback collection global.
- [x] Security rules: `firestore.rules` hanya mengizinkan user membaca/menulis `users/{uid}/...` miliknya sendiri dan menutup root collection lama.
- [x] Account security UI: guest dapat mengamankan akun dengan Google atau email/password melalui account linking tanpa memindahkan UID/data.
- [x] Auth landing page: user baru dapat memilih Google, email/password, email link, atau Guest sejak pertama membuka aplikasi.
- [x] Email authentication: login, daftar, reset password, dan verifikasi email link tersedia melalui bottom sheet responsif.
- [x] Auth feedback/session controls: status sukses kirim link, login, dan daftar tetap terlihat; Settings memiliki kartu akun dengan logout/ganti akun dan peringatan khusus guest.
- [x] Email-link hosting handler: action link diarahkan ke Firebase Hosting Flutter Web, mendeteksi link Firebase pada URL, dan menyelesaikan login tanpa memindahkan UID guest.
- [x] Email-link UX: email tujuan dibawa pada `continueUrl` dan form verifikasi otomatis mengisinya saat link dibuka.
- [x] Email verification: register dan linking email mengirim verification email; akun password yang belum verified ditahan di halaman verifikasi dengan resend cooldown dan pengecekan ulang status.
- [x] Google Sign-In Android: OAuth client **sudah tersedia** di `google-services.json`
  (`client_type: 1`, package `com.example.savu`, `certificate_hash`
  `a0738b4d528ff1a73edce30753974eb2862b24cb`). Diperbarui pada `6dab288` mengikuti
  rebrand. ⚠️ Yang masih kurang: **SHA-1/SHA-256 keystore release** belum terdaftar.
- [x] Build compatibility: Android Kotlin/NDK disesuaikan untuk Firebase Auth dan dependency Firebase web dikunci kompatibel dengan Flutter 3.32/Dart 3.8; APK dan Web berhasil di-build.
- [x] Windows build: policy CMake Firebase dan direktori install diperbaiki sehingga `flutter build windows --debug` berhasil tanpa hak administrator.
- [x] Tahap 22: Dark theme dirombak menjadi palet charcoal + teal manual dengan surface solid; diterapkan ke 25 file.
- [x] Tahap 23: Avatar profil preset (30 avatar, 2 kategori) dengan penyimpanan SharedPreferences dan sheet picker responsif; filter gender dihapus.
- [x] Tahap 24: Kontak founder membuka Gmail/WhatsApp/GitHub secara langsung melalui intent native dengan fallback `url_launcher`.
- [x] Tahap 25: Onboarding page 3 slide dengan `PageController`, ilustrasi custom, flag
  `onboarding_completed` di SharedPreferences, dan `AnimatedSwitcher` pada `_AuthGate`.
- [x] Tahap 26: Warna progres target bertingkat (hijau 100%, biru ≥50%, primary <50%) dan warna peringatan budget eksplisit per tema.
- [x] Tahap 27: Arsip target tabungan (`isArchived`) dengan mode toggle, provider terpisah, dan pemisahan perilaku hapus target selesai vs aktif.
- [x] Tahap 28: Rebrand menyeluruh ke Savu — package name, launcher icon lintas platform, dan metadata web/desktop.
- [x] Tahap 29: Kategori pengeluaran "Alokasi Tabungan" diganti menjadi "Kesehatan & Perawatan" pada daftar default, lengkap dengan ikon dan warna baru.
- [x] Tahap 30: bersihkan 5 info `flutter analyze` (3× `use_build_context_synchronously`
   di `settings_content.dart`, 1× `curly_braces_in_flow_control_structures` di
  `financial_insight_overview_sheet.dart`, 1× `unnecessary_brace_in_string_interps`
  di `auth_landing_page.dart`).
- [ ] Tahap 31: daftarkan SHA-1/SHA-256 keystore release ke Firebase Console dan
  `web/.well-known/assetlinks.json`, lalu validasi Google Sign-In + deep link pada
  APK release.
- [ ] Tahap 32: bersihkan field `isFavorite` yang sudah tidak terpakai di
  `SavingsGoalEntity`/model, atau pulihkan fitur favorit di UI.
- [ ] Tahap 33: validasi regresi data lama — transaksi berkategori "Alokasi Tabungan"
  pasca penggantian default kategori.
- [ ] Tahap 34: konfigurasi Google Sign-In iOS (butuh Mac/Xcode +
  `GoogleService-Info.plist` + `REVERSED_CLIENT_ID`).

---

## 🔧 Aturan Main (dari AGENTS.md + PRD.md)

1. Clean Architecture: Domain → Data → Presentation. Jangan campur UI dengan business logic.
2. Riverpod `Notifier`/`AsyncNotifier`/`ConsumerWidget` only. No GetX/Bloc.
3. Semua Firestore request try-catch, gagal → SnackBar.
4. SharedPreferences hanya untuk Dark Mode & Budget Limit (sekarang juga untuk sorting pref).
5. No dummy code / TODO. `flutter analyze` harus bersih sebelum commit.
6. 1 task = 1 commit. Commit manual oleh user, AI hanya kasih deskripsi.
7. Penjelasan pakai analogi sederhana untuk user pemula.
8. Sebelum eksekusi task, jelaskan rencana file apa + kenapa, minta persetujuan.

---

## 📂 Struktur Penting (update 2026-09-03)

```
lib/
├── main.dart
│   ├── _AuthLinkHandler   → app_links (initial link + runtime stream) untuk email link
│   ├── _AuthGate          → pilih OnboardingPage vs _AuthContent (AnimatedSwitcher 420ms)
│   └── SavuApp            → MaterialApp + SystemUiOverlayStyle → AppShell
├── core/
│   ├── errors/app_error_message.dart        (pemetaan error Firestore terpusat)
│   ├── firebase/auth_providers.dart         (authStateChangesProvider, authControllerProvider)
│   ├── local_storage/
│   │   ├── settings_service.dart            (+ getProfileAvatarId/setProfileAvatarId,
│   │   │                                      getOnboardingCompleted/setOnboardingCompleted)
│   │   └── settings_providers.dart          (budgetLimit, appThemeMode, userName,
│   │                                         userProfileType, profileAvatar, privacyMode,
│   │                                         budgetCycleDate, lastSuccessfulSync,
│   │                                         savingsSort, onboardingCompleted)
│   ├── navigation/app_shell.dart            (FloatingPillNavigation + create options sheet)
│   ├── theme/savu_theme.dart                (_buildLight via fromSeed, _buildDark palet manual)
│   ├── utils/                               (rupiah_formatter, date_formatter, input formatter)
│   └── widgets/app_page_background.dart     (background bersama seluruh halaman)
├── features/
│   ├── analytics/       (cash flow, balance trend, expense flow insight + overview sheet)
│   ├── auth/            (auth_landing_page, email_verification_page)
│   ├── dashboard/       (summary, budget overview, category pie, financial insight, empty state)
│   ├── onboarding/      (onboarding_page, onboarding_slide) ← BARU
│   ├── savings/         (goal, alokasi, arsip, celebration, edit goal/allocation)
│   ├── settings/        (settings_page ringan + widgets/* modular)
│   └── transactions/    (history, quick add, filter, CSV export, category icon)
└── firebase_options.dart
```

### Titik Penting yang Sering Terlupakan

- **`main.dart` memiliki dua `MaterialApp`**: `_AuthGate` (untuk fase auth/onboarding) dan
  `SavuApp` (untuk aplikasi utama). Keduanya mengamankan `appThemeModeProvider` dan
  memakai `SavuTheme.light()`/`SavuTheme.dark()`. Perubahan tema global harus dicek di
  kedua tempat.
- **`historyNavigationIntentProvider`** di `history_providers.dart` dipantau `AppShell`
  lewat `ref.listen` untuk memindahkan tab ke Riwayat secara otomatis dari budget overview.
- **`Alokasi Tabungan` adalah kategori sistem**: dipakai `savings_providers.dart:227` saat
  alokasi otomatis, disembunyikan dari chip pilihan user. Jangan dihapus.
- **`isFavorite` mati suri**: ada di entity dan model, tapi tidak dipakai UI mana pun.
- **ASET `assets/images/Savu_logo.png` tidak ada di working tree** (dihapus `34a7d21`)
  meski masih direferensikan riwayat git. Hanya `assets/images/app_icon.png` yang
  terdaftar di `pubspec.yaml`.

---

## 🚀 Cara Resume di Model Baru

1. Baca `progress.md` ini + `task.md` + `AGENTS.md` + `PRD.md`.
2. Cek `git status --short --branch` dan `git log --oneline -10`.
3. Jangan menghapus perubahan lokal.
4. Jalankan `flutter analyze` dan `flutter test` sebelum commit bila ada perubahan lanjutan.
    Baseline saat ini: **69 test lulus**, **No issues found** dari analyzer.
5. Validasi manual di device Android untuk memastikan layout responsif, terutama nominal
   panjang, dark theme baru, dan interaksi chart/card.
6. Mulai dari Tahap 31 pada backlog di atas. Tahap 30 sudah selesai.

---

## ❓ Jawaban untuk Pertanyaan Model Switch

- **Apakah ganti model di 9router reset memori?** Tergantung provider. Jika kamu ganti model via dropdown 9router dan tetap di **thread/session yang sama**, konteks chat (memory) biasanya **tetap kebawa** (karena history ada di client). Tapi jika kamu **buka chat baru / new session** atau 9router membuat session baru untuk model lain (misal Muse → DeepSeek butuh routing ulang), **memori bisa hilang**. Paling aman: pakai file handoff seperti `progress.md` ini.
- **Dengan `progress.md`:** Kamu cukup prompt di sesi baru: `"baca progress.md, task.md, AGENTS.md, PRD.md lalu lanjutkan Task 12.5 (fix sorting + tab selesai) sesuai rencana. Jangan tanya ulang, langsung eksekusi setelah konfirmasi."` → AI baru bisa lanjut tanpa reset.

---

## 📝 Catatan Tambahan

- User prefer commit manual, jangan auto `git add/commit`.
- User ingin UI tidak polos, seperti app profesional (gradient, card elevation, icon, empty state ilustratif).
- Sorting bug perlu investigasi data dulu sebelum coding.
- Fitur arsip: user setuju rekomendasi Tab Aktif/Selesai, bukan auto-delete. Card selesai tetap bisa dilihat tapi terpisah.

- **Sesi 2026-08-28:** user memilih privacy mode tidak menyembunyikan nominal pada History; privacy mode tetap untuk Dashboard.
- **Sesi 2026-08-28:** user meminta commit manual; AI tidak melakukan `git add`, `git commit`, atau push.
- **Sesi lanjutan:** tahap 2 dan 3 selesai. Penyimpanan Settings sekarang menampilkan feedback floating `SnackBar`; FAQ placeholder diganti Pusat Bantuan interaktif. `flutter analyze` bersih dan 52/52 test lulus.
- **Sesi 2026-09-02 s/d 2026-09-03 (branch `develop_dua`):** 30 commit tidak tercatat di
  file md. Isinya: rebrand Savu, launcher icon lintas platform, onboarding page, katalog
  avatar preset (filter gender dihapus), kontak founder via intent native, arsip target,
  rombak total dark theme, warna progres target bertingkat, warna peringatan budget
  eksplisit, serta penggantian kategori default "Alokasi Tabungan" →
  "Kesehatan & Perawatan". Rincian ada di bagian "PERUBAHAN PASCA-HANDOFF".
- **Sesi 2026-09-03 (verifikasi ulang oleh AI):** `flutter test` menghasilkan **69/69
  lulus** dan `flutter analyze` menghasilkan **5 info**. Angka 52/52 pada catatan lama
  sudah usang.
- **Sesi 2026-09-04 (Tahap 30):** lima info analyzer diperbaiki pada tiga file.
  `flutter analyze` menghasilkan **No issues found** dan `flutter test` tetap
  **69/69 lulus**.

## 🧾 Commit Manual Sesi 2026-08-28

```text
feat: add interactive budget overview

- Add budget overview entity and cycle-aware calculations
- Show budget status, remaining balance, and spending projection
- Add interactive budget detail bottom sheet
- Display top spending categories for active budget cycle
- Add unit tests for budget overview calculations
```

## 🧾 Commit Suggestion Sesi Berikutnya (Tahap 30)

```text
chore: resolve analyzer infos before next feature work

- Guard BuildContext usage after async gaps in settings_content.dart
- Wrap conditional statement in a block in financial_insight_overview_sheet.dart
- Remove redundant braces in string interpolation in auth_landing_page.dart
```

---

## HANDOFF SESI TERBARU - AUTHENTICATION

### Status Testing

- Login email/password: berhasil.
- Daftar email/password: akun dibuat dan email verification wajib sebelum Dashboard dapat dibuka.
- Email link: berhasil dikirim dan diverifikasi; biasanya masuk Spam karena memakai sender/domain Firebase gratis.
- Reset password: berhasil.
- Logout/ganti akun di Settings: berhasil.
- Google Sign-In Android: berhasil setelah OAuth client dan SHA dikonfigurasi.
- Google Sign-In Web: kode menggunakan Firebase popup dan perlu validasi manual di Chrome/Edge.
- Google Sign-In iOS: belum divalidasi; membutuhkan Mac/Xcode, `GoogleService-Info.plist`, dan URL scheme.

### Catatan Email Verification

Firebase hanya memvalidasi format email saat register. Email seperti `abc123@gmail.com` dapat diterima walaupun inbox belum tentu ada. Aplikasi sekarang memakai klik link verification sebagai bukti kepemilikan email.

- Guest tetap boleh langsung masuk tanpa verifikasi.
- Akun email/password harus memverifikasi email.
- Setelah register, email verification dikirim otomatis.
- Halaman verifikasi email profesional sudah tersedia.
- Status dicek ulang dengan `user.reload()` dan `emailVerified`.
- Resend verification memakai cooldown 60 detik.
- Aksi ganti akun tersedia melalui logout.

### Validasi Berikutnya

1. Uji email valid, typo, email palsu, dan resend pada Firebase Console aktif.
2. Validasi Google Web di Chrome dan Edge.
3. Siapkan konfigurasi Google iOS.
4. Validasi deep link email di Android.
5. Jalankan analyzer, test, build Web, dan build Android secara berkala.
6. Deploy Hosting dan Firestore rules setelah konfigurasi Console siap.

### File Rencana

```text
lib/core/firebase/auth_providers.dart
lib/features/auth/presentation/pages/auth_landing_page.dart
lib/features/auth/presentation/pages/email_verification_page.dart
lib/features/auth/presentation/widgets/auth_success_state.dart
progress.md
progress_auth_user_scoped.md
```

### Prompt Resume

```text
Baca progress.md, progress_auth_user_scoped.md, AGENTS.md, dan PRD.md.
Lanjutkan dari HANDOFF SESI TERBARU - AUTHENTICATION.
Tambahkan email verification wajib setelah register, halaman verifikasi profesional,
resend dengan cooldown, proteksi Dashboard untuk akun belum verified, uji Google Web,
siapkan konfigurasi Google iOS, lalu jalankan analyzer, test, dan build.
```

---

## 🧭 PROMPT RESUME TERKINI (2026-09-04)

Bagian authentication di atas **sudah selesai**. Untuk melanjutkan pekerjaan sekarang,
pakai prompt ini:

```text
Baca progress.md, progress_perbaikan.md, prioritas_perbaikan.md, task.md,
AGENTS.md, dan PRD.md.

Kondisi saat ini (branch develop_dua, working tree clean):
- flutter test: 69/69 lulus
- flutter analyze: No issues found
- FASE PRD 1-4 tuntas. Rebrand ke Savu tuntas.

Tahap 30 sudah selesai. Mulai dari Tahap 31 pada backlog progress.md:
daftarkan SHA release, deploy/validasi Firebase, lalu uji Google Sign-In dan
deep link pada APK release.

Setelah itu lanjut berturut-turut ke Tahap 31 sampai 34.
Jelaskan rencana per file sebelum mengubah apa pun, lalu minta persetujuan.
Commit dilakukan manual oleh user; AI hanya memberi deskripsi commit.
```

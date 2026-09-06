# PROGRESS - Savu

> File ini adalah sumber kebenaran tunggal untuk semua progress proyek Savu.
> **Cara pakai di sesi baru:** suruh AI `baca progress.md + task.md + AGENTS.md + PRD.md` lalu lanjutkan dari `NEXT TASK` di bawah.

---

## Timestamp

- **Terakhir update:** 2026-09-05
- **Branch aktif:** `develop_dua` (tracking `origin/develop_dua`)
- **Dibuat oleh:** Andre Robert

---

## Posisi Saat Ini

- **FASE 1 TUNTAS** (Task 1-6) — merge ke `main` via PR #3 `54724a4`
- **FASE 2 TUNTAS** (Task 7-9) — `83b13fe`, `81aa315`
- **FASE 3 TUNTAS** (Task 10-12)
- **FASE 4 TUNTAS** (Task 13 Settings Page & Premium UI)
- **Rebrand selesai:** aplikasi bernama **Savu** (`6dab288`)
- **Kesehatan kode (2026-09-05):**
  - `flutter test` → **73/73 lulus**
  - `flutter analyze` → **No issues found**
  - File split: `dashboard_page.dart` dan `settings_content.dart` sudah dipecah ke file kecil
- **Working tree:** bersih (semua perubahan sudah ter-commit)

---

## Git Status

```
Branch: develop_dua (tracking origin/develop_dua)
Recent commits:
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
```

---

## Roadmap Detail

Status yang digunakan: `Selesai`, `Berjalan`, `Belum dimulai`, `Ditunda`.

### A. Dashboard dan Interaksi Detail

#### A1. Balance Card Overview — `Selesai`
- Balance Card dapat diketuk → `_BalanceOverviewSheet` di `dashboard_page.dart`.
- Tampilkan pemasukan, pengeluaran, saldo bersih, jumlah transaksi, dan periode.
- Kategori pengeluaran terbesar ditampilkan jika tersedia.
- Hormati Privacy Mode untuk seluruh nominal di overview.

#### A2. Budget Overview Interaktif — `Selesai`
- Metric transaksi membuka History dengan filter siklus aktif.
- Detail rata-rata pengeluaran harian dan proyeksi akhir periode.
- Kategori terbesar membuka History berdasarkan kategori.
- Header Status Anggaran statis; hanya body yang menjadi interaction surface.

#### A3. Dashboard Polish — `Berjalan`
- Card memiliki hierarchy, spacing, dan hit target konsisten.
- Feedback visual saat card dapat diketuk.
- Sheet edukasi status anggaran (`02f16f5`).
- Warna status anggaran eksplisit per tema (`7171105`): `#FBBF24` dark / `#D97706` light.
- Warna teks pengeluaran dan rata-rata Financial Insight dibuat lebih terang (`c5e99e3`).
- Chart pada Insight Card responsif terhadap tap (`73a4f07`).
- **Belum selesai:** audit menyeluruh empty/loading/error/retry pada setiap section.

#### A4. Warna Semantik Lintas Tema — `Selesai`
- Warna peringatan anggaran pakai konstanta eksplisit bukan `ColorScheme.tertiary`.
- Diterapkan di `_BudgetAlertBody`, `_BudgetOverviewSheet`, `_BudgetInfoSheet`.
- Setiap level sheet edukasi punya warna sendiri: primary (Aman), warning (Perlu diperhatikan), error (Terlampaui).

### B. Analytics dan Chart Keuangan

#### B1. Konsistensi Periode Chart — `Selesai`
- Pie chart mengikuti budget cycle aktif.
- Siklus lintas bulan tidak menghasilkan angka berbeda.
- Test regression tersedia di `test/calculate_cycle_summary_usecase_test.dart`.

#### B2. Cash Flow Chart — `Selesai`
- Bar chart memakai `fl_chart`, filter 7 hari / 30 hari / siklus aktif.
- Tooltip format Rupiah bertitik.
- Preview arus kas menjadi bagian dari Financial Insight Card.

#### B2.1 Financial Insight Overview — `Selesai`
- Card Insight dapat diketuk → overview detail.
- Tampilkan pemasukan, pengeluaran, saldo bersih, perbandingan periode sebelumnya, chart 7 hari, top kategori, rata-rata harian, jumlah transaksi.
- Implementasi: `financial_insight_overview_sheet.dart`.

#### B2.2 Expense Flow Chart Overview — `Selesai`
- Klik chart → overview: total pengeluaran, rata-rata harian, hari aktif, puncak pengeluaran, rincian, rekomendasi finansial.
- Implementasi: `expense_flow_insight_entity.dart`, `calculate_expense_flow_insight_usecase.dart`, `expense_flow_overview_sheet.dart`.

#### B3. Balance Trend Chart — `Selesai`
- Line chart tren saldo kumulatif dengan tooltip tanggal dan saldo.
- Test: `test/calculate_balance_trend_usecase_test.dart`.

#### B4. Analytics Page — `Ditunda`
- Halaman Analitik khusus ditunda agar Dashboard tidak memiliki terlalu banyak chart.
- `AnalyticsPage` tersedia sebagai fondasi lanjutan.

### C. Savings Goals

#### C1. Edit Target Tabungan — `Selesai`
- User dapat mengubah nama, nominal target, dan deadline.
- Current amount serta riwayat alokasi tidak berubah.
- Validasi nominal positif, judul wajib, deadline tidak boleh lewat.

#### C2. Savings Polish — `Berjalan`
- Warna progres bertingkat (`bb468d0`): hijau 100%, biru >=50%, primary <50%.
- Dialog konfirmasi hapus menjelaskan dampak berbeda antara target selesai dan aktif.
- **Belum selesai:** audit spacing layar kecil dan ringkasan total dana.

#### C2.1 Success Celebration — `Selesai`
- Alokasi terakhir yang memenuhi target → dialog perayaan.
- Trophy badge, animasi confetti 1.6 detik, tombol `Lanjutkan`.
- Implementasi: `goal_celebration_dialog.dart` (package `confetti`).

#### C3. Savings Archive and Goal Actions — `Selesai`
- `SavingsGoalEntity` punya field `isArchived` dan `isFavorite` (default `false`).
- Provider: `archivedModeProvider`, `archivedActiveGoalsProvider`, `archivedCompletedGoalsProvider`.
- `activeGoalsProvider`/`completedGoalsProvider` memfilter `!isArchived`.
- `deleteCompletedGoal()` hanya hapus dokumen target; transaksi alokasi tetap sebagai ledger.
- `deleteGoalWithAllocations()` untuk target aktif.
- **Fitur favorit dicabut dari UI** (`2904310`): field `isFavorite` masih ada di entity/model tapi tidak terpakai.

### D. Transaction History

#### D1. History Polish — `Selesai sebagian`
- Header, search, filter, grouped daily card, transaction tile sudah dipoles.
- **Belum selesai:** validasi visual pada Android kecil dan Windows.

#### D1.1 Custom Date Range History — `Selesai`
- Rentang tanggal custom inklusif, maksimal 31 hari.
- Test: `test/history_date_range_test.dart`, `test/filter_transactions_usecase_test.dart`.

#### D1.2 Budget Overview to History — `Selesai`
- Budget Overview mengirim intent navigasi ke tab History.
- Klik transaksi → History filter siklus aktif. Klik kategori → History filter kategori + siklus.

#### D2. History Detail — `Belum dimulai`
- Detail transaksi sebagai bottom sheet yang lebih informatif.
- Shortcut edit dan hapus yang aman untuk allocation transaction.

### E. Navigation dan Global UI

#### E1. Floating Navigation — `Selesai`
- Floating pill dengan empat menu dan tombol aksi tengah.
- Tombol aksi: Buat Catatan Baru / Buat Target Tabungan Baru.

#### E2. Page Transition — `Selesai`
- Fade dan slide halus. State form tidak hilang saat berpindah tab.

#### E3. Visual Foundation — `Berjalan`
- Tema emerald/teal tetap identitas utama. Font Inter.
- Background clean tanpa orb, circle, grid, atau dot pattern.
- SnackBar global memakai `inverseSurface` dan `onInverseSurface`.
- Dark theme dirombak total (`28f2ba1`, 25 file).

#### E4. Profil dan Avatar — `Selesai`
- Avatar header Settings dapat diketuk → `ProfileAvatarSheet`.
- 30 avatar preset: `general` (15) + `people` (13).
- Tersimpan di SharedPreferences via `profileAvatarProvider` (default `sunrise`).
- Grid responsif: 3 kolom < 360px, 4 kolom di atasnya.
- Filter gender dihapus (`6340933`).

#### E5. Kontak Founder — `Selesai`
- `ContactUsEntry` membuka aksi langsung:
  - Email → intent Gmail/Android + fallback `url_launcher`.
  - WhatsApp → `android_intent_plus` ke `62895338891504`.
  - GitHub → `https://github.com/andrest1101`.

### F. Reliability dan Sistem

#### F1. Firestore Error State Audit — `Selesai sebagian`
- Error mapper terpusat: `core/errors/app_error_message.dart`.
- Action transaksi dan target menyimpan pesan user-friendly pada `AsyncError`.
- Sheet transaksi, tambah/edit target, alokasi menampilkan pesan error hasil mapping.
- **Belum selesai:** audit lanjutan untuk seluruh Settings/Auth.

#### F2. Windows Firestore Compatibility — `Berjalan`
- Windows memakai WriteBatch untuk allocation (bug native `runTransaction` pada cloud_firestore Windows 5.6.x).
- Android, iOS, Web tetap memakai Firestore transaction atomik.

#### F3. Authentication dan Security — `Selesai sebagian`
- Anonymous auth dan user-scoped Firestore sudah diterapkan.
- `firestore.rules` membatasi akses `users/{userId}/{document=**}` dengan `request.auth.uid == userId`.
- Root collection legacy ditutup dengan `allow read, write: if false`.
- Rules belum di-deploy ke Firebase Console.
- OAuth client Android sudah tersedia di `google-services.json`.
- **Belum ada:** SHA-1/SHA-256 keystore release.

### G. Testing dan Release

#### G1. Automated Test — `Berjalan`
- **Baseline:** `flutter test` **73/73 lulus** (21 file test).
- `flutter analyze` → **No issues found**.

#### G2. Responsive Validation — `Belum dimulai`
- Validasi Android kecil, Android besar, Windows, Web.
- Cek text scaling, overflow, tap target, keyboard, bottom sheet.

#### G3. Release Checklist — `Belum dimulai`
- Build Android debug/release, Windows debug, Web.
- Deploy Firestore rules dan Hosting.
- Validasi Auth, deep link, Firestore path, data isolation.
- Daftarkan SHA-1/SHA-256 release ke Firebase Console dan `assetlinks.json`.

#### G4. Analyzer Debt — `Selesai`
- 5 info Tahap 30 sudah diperbaiki. `flutter analyze` kini bersih.

### H. Branding dan Identitas

#### H1. Rebrand MoneyTracker → Savu — `Selesai`
- `pubspec.yaml`: nama package `savu`, deskripsi diperbarui.
- Package Android: `com.example.savu`.
- Launcher icon baru lintas platform.
- `flutter_launcher_icons` dikonfigurasi (minSdk 21, warna tema `#0F766E`).
- Logo ganda dihapus (`34a7d21`).

#### H2. Onboarding — `Selesai`
- Folder: `lib/features/onboarding/`.
- 3 slide: Pencatatan Kilat (`#2DD4BF`), Kontrol Anggaran (`#60A5FA`), Mode Selesai & Arsip.
- `SettingsService` menyimpan flag `onboarding_completed`.
- `_AuthGate` memilih `OnboardingPage` atau `_AuthContent` dengan `AnimatedSwitcher` (420ms).
- **Risiko:** user lama akan melihat onboarding satu kali karena flag belum pernah diset.

### I. Dark Theme System

#### I1. Palet Charcoal dan Teal — `Selesai`
- `_buildLight()` memakai `ColorScheme.fromSeed`.
- `_buildDark()` memakai palet manual penuh:
  - scaffold `#121417`, surface `#1C2026`, primary/secondary/tertiary `#2DD4BF`
  - error `#EF5350`, onSurface `#FFFFFF`, onSurfaceVariant `#9CA3AF`
  - outline `#3A414A`, outlineVariant `#2B3138`
- Diterapkan ke 25 file.

### J. Kategori Transaksi

#### J1. Penggantian Kategori Default — `Selesai`
- "Alokasi Tabungan" → **"Kesehatan & Perawatan"** di `dashboard_providers.dart:109`.
- Ikon baru: `Icons.health_and_safety`, warna `#E84393`.
- **Implikasi data lama:**
  - Transaksi lama berkategori "Alokasi Tabungan" tetap ada di `category_icon.dart:21`.
  - `quick_add_transaction_sheet.dart:78` membuang kategori itu dari chip user.
  - `savings_providers.dart:227` tetap pakai string `'Alokasi Tabungan'` untuk alokasi otomatis. **Jangan diubah tanpa migrasi data Firestore.**

---

## Ringkasan Perubahan Selesai

### 1. Fix Bug UI Android
- Teks nominal meluber diperbaiki dengan `ConstrainedBox` dan `Flexible` di `history_page.dart` & `transaction_tile.dart`.
- `SegmentedButton` tema diganti `_ThemeChip` kustom.

### 2. Premium Settings UI (Task 13)
- Avatar/Nama, status sinkronisasi, sakelar Mode Privasi, pengaturan Siklus Anggaran, tombol Danger Zone.

### 3. History UI Interaktif
- Nominal tidak terpotong, header tanggal dapat ditekan, bottom sheet overview harian.

### 4. Pie Chart Interaktif
- Segmen dan legend dapat dipilih, kategori aktif di-highlight, bottom sheet detail kategori.

### 5. Status Anggaran Interaktif
- Card membaca transaksi aktual dan tanggal siklus. Overview: status, progress, sisa/kelebihan, periode, rata-rata harian, proyeksi, 3 kategori terbesar.

### 6. Domain Budget Overview
- `BudgetOverviewEntity` dan `CalculateBudgetOverviewUseCase` dengan dukungan siklus lintas bulan.

### 7. Testing
- Suite bertumbuh menjadi 73 test.

### 8. Rebranding → Savu (`6dab288`)
- Package name, launcher icon lintas platform, metadata web/desktop.

### 9. Profil & Avatar (`a992904`, `402f04c`, `70bf265`, `6340933`, `cb8dab4`)
- Foto profil preset, 30 avatar, grid responsif, filter gender dihapus.

### 10. Kontak Founder (`4a546bf`, `d23212c`, `05de391`)
- Email → Gmail intent, WhatsApp → intent native, GitHub → browser.

### 11. Dialog & Greeting Konsisten (`1ec64b1`, `7b1dcf1`, `9cf2bd8`)
- Aksi dialog diseragamkan, nama diutamakan di atas displayName Google.

### 12. Onboarding Page (`f7b773f`)
- 3 slide, `PageController`, ilustrasi custom, flag `onboarding_completed`.

### 13. Kategori & Form Transaksi (`96a246a`)
- "Alokasi Tabungan" → "Kesehatan & Perawatan", spacing form diperbaiki.

### 14. Warna & Tema (`28f2ba1`, `c5e99e3`, `bb468d0`, `7171105`)
- Dark theme palet charcoal + teal, progress card bertingkat, peringatan budget eksplisit.

### 15. Target Tabungan — Menu & Arsip (`9530cd5`, `2904310`, `e0803c1`)
- `isArchived` dan `isFavorite`, mode arsip, pemisahan hapus target selesai vs aktif.

### 16. Dashboard & Chart (`02f16f5`, `6895191`, `73a4f07`, `620d6c9`, `33745eb`)
- Sheet edukasi budget, chart interaktif, navigasi budget → history.

### 17. File Split Refactoring
- `dashboard_page.dart` (1677 → 229 baris) dipecah ke: `balance_hero_card.dart`, `budget_status_section.dart`, `dashboard_skeleton.dart`, `dashboard_error_view.dart`.
- `settings_content.dart` (1568 → 58 baris) dipecah ke: `settings_profile_section.dart`, `settings_display_section.dart`, `settings_financial_section.dart`, `settings_data_section.dart`, `settings_snack_bar.dart`.

---

## Authentication & Security

### Status Testing

| Fitur | Status |
|-------|--------|
| Login email/password | Berhasil |
| Daftar email/password | Berhasil (email verification wajib) |
| Email link | Berhasil (masuk Spam karena sender Firebase gratis) |
| Reset password | Berhasil |
| Logout/ganti akun | Berhasil |
| Google Sign-In Android | Berhasil setelah OAuth/SHA dikonfigurasi |
| Google Sign-In Web | Perlu validasi manual di Chrome/Edge |
| Google Sign-In iOS | Belum divalidasi (butuh Mac/Xcode) |

### Email Verification

- Firebase hanya validasi format email saat register.
- Email `abc123@gmail.com` diterima walaupun inbox tidak ada.
- Aplikasi pakai klik link verification sebagai bukti kepemilikan.
- Guest tetap boleh masuk tanpa verifikasi.
- Akun email/password wajib verifikasi.
- Register otomatis kirim email verifikasi.
- Halaman verifikasi profesional tersedia.
- Status dicek ulang dengan `user.reload()` dan `emailVerified`.
- Resend verification pakai cooldown 60 detik.

### Google Sign-In Android

- OAuth client sudah tersedia di `google-services.json`:
  - `client_type: 1`, package `com.example.savu`, `certificate_hash` `a0738b4d528ff1a73edce30753974eb2862b24cb`.
- Diperbarui pada `6dab288` mengikuti rebrand.
- **Yang masih kurang:** SHA-1/SHA-256 keystore release belum terdaftar.

### Firestore Security Rules

```
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
match /transactions/{transactionId} { allow read, write: if false; }
match /savings_goals/{goalId}       { allow read, write: if false; }
```

Status: **file sudah benar, tetapi belum di-deploy.** Jalankan `firebase deploy --only firestore:rules` setelah konfigurasi Console siap.

### Bootstrap Flow (post-onboarding)

```
main()
  +- _AuthLinkHandler   (app_links: initial link + runtime stream)
       +- _AuthGate
            +- onboarding belum selesai ? OnboardingPage
            +- onboarding selesai ? _AuthContent
                 +- loading  ? CircularProgressIndicator
                 +- error    ? AuthLandingPage
                 +- data(user)
                      +- user == null                    ? AuthLandingPage
                      +- butuh verifikasi email          ? EmailVerificationPage
                      +- selain itu                      ? SavuApp
```

### Perubahan Keamanan

- Auth failure menampilkan halaman error dengan retry, tidak membuka data tanpa identitas.
- Data memakai path user-scoped. Fallback global runtime dihapus.
- Data lama harus dimigrasikan secara administratif ke `users/{uid}` sebelum rules production.

---

## Settings & Profile

### Status Sync Profil

- Status `Tersinkronisasi` tidak lagi statis, mengikuti stream transaksi Firestore:
  - Menyiapkan sinkronisasi
  - Tersinkronisasi
  - Sinkronisasi gagal (dapat diketuk untuk retry)

### Avatar Preset

- `SettingsService` menyimpan `profile_avatar_id` di SharedPreferences (default `sunrise`).
- 30 avatar preset dalam 2 kategori:
  - `general` (15): sunrise, leaf, rocket, star, coffee, bolt, favorite, palette, sports, travel, diamond, security, lightbulb, pets, balance.
  - `people` (13): avatar wajah berlabel nama (Andre, Chelsie, dll).
- Avatar dapat diketuk → `ProfileAvatarSheet` (InkWell + AnimatedSwitcher).
- Grid responsif: 3 kolom < 360px, 4 kolom di atasnya.
- ⚠️ Filter gender (Laki-laki/Perempuan) dihapus. Enum `PresetAvatarGender` masih ada sebagai metadata.
- ⚠️ Nama preset avatar `people` memakai nama orang nyata. Ganti menjadi label generik jika didistribusikan publik.

### Validasi Alokasi

- Edit alokasi menghitung saldo: `saldo tersedia = saldo bulan berjalan + alokasi lama`.
- Nominal baru ditolak jika melebihi saldo tersedia.
- Konfirmasi hapus target membedakan pesan antara target selesai dan aktif.
- Tombol dialog memenuhi lebar: `OutlinedButton` (Batal) + `FilledButton` (Aksi).

### Onboarding Flag

- `SettingsService` menambahkan `getOnboardingCompleted()` dan `setOnboardingCompleted()`.
- Provider: `onboardingCompletedProvider` (`Notifier<bool>`).

---

## NEXT TASK

1. **Tahap 31:** daftarkan SHA-1/SHA-256 keystore release ke Firebase Console dan `web/.well-known/assetlinks.json`, lalu validasi Google Sign-In + deep link pada APK release.
2. **Validasi alur onboarding:** pastikan user lama tidak terjebak di onboarding.
3. **Uji regresi kategori "Kesehatan & Perawatan":** cek transaksi lama berkategori "Alokasi Tabungan" tidak hilang dari pie chart dan filter.
4. **Validasi di device Android:** dark theme baru, warna progress target, warna peringatan budget, avatar picker, kontak founder.
5. **Tahap 32:** bersihkan field `isFavorite` yang sudah tidak terpakai, atau pulihkan fitur favorit.
6. **Tahap 33:** validasi regresi data lama pasca penggantian default kategori.
7. **Tahap 34:** konfigurasi Google Sign-In iOS (butuh Mac/Xcode + `GoogleService-Info.plist` + `REVERSED_CLIENT_ID`).

---

## Backlog

### Selesai

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
- [x] Step 17: Modularisasi awal Settings: section title, Help Center, FAQ sheet, dan branding dipindahkan ke widget terpisah.
- [x] Step 18: Entry page Settings dipisahkan dari komposisi content.
- [x] Step 19: Empty state Dashboard dibuat informatif untuk transaksi, pie chart, dan financial insight.
- [x] Step 20: Status sinkronisasi Settings menampilkan loading, sukses, offline/gagal, retry, dan waktu pembaruan terakhir.
- [x] Step 21: Firebase Anonymous Authentication dan path user-scoped untuk transaksi serta target.
- [x] Security hardening: AuthGate error + retry saat Anonymous Auth gagal.
- [x] Security rules: `firestore.rules` membatasi akses `users/{uid}/...`.
- [x] Account security UI: guest dapat mengamankan akun dengan Google atau email/password.
- [x] Auth landing page: user baru dapat memilih Google, email/password, email link, atau Guest.
- [x] Email authentication: login, daftar, reset password, dan verifikasi email link.
- [x] Auth feedback/session controls: status sukses, login, dan daftar; Settings punya kartu akun dengan logout/ganti akun.
- [x] Email-link hosting handler: action link diarahkan ke Firebase Hosting Flutter Web.
- [x] Email-link UX: email tujuan dibawa pada `continueUrl`.
- [x] Email verification: register dan linking email mengirim verification email.
- [x] Google Sign-In Android: OAuth client sudah tersedia.
- [x] Build compatibility: Android Kotlin/NDK disesuaikan untuk Firebase Auth; APK dan Web berhasil di-build.
- [x] Windows build: policy CMake Firebase dan direktori install diperbaiki.
- [x] Tahap 22: Dark theme dirombak menjadi palet charcoal + teal manual.
- [x] Tahap 23: Avatar profil preset (30 avatar, 2 kategori) dengan sheet picker responsif.
- [x] Tahap 24: Kontak founder membuka Gmail/WhatsApp/GitHub secara langsung.
- [x] Tahap 25: Onboarding page 3 slide dengan flag persistensi.
- [x] Tahap 26: Warna progres target bertingkat dan warna peringatan budget eksplisit.
- [x] Tahap 27: Arsip target tabungan dengan mode toggle dan pemisahan hapus.
- [x] Tahap 28: Rebrand menyeluruh ke Savu.
- [x] Tahap 29: Kategori pengeluaran "Alokasi Tabungan" → "Kesehatan & Perawatan".
- [x] Tahap 30: Bersihkan 5 info `flutter analyze`.

### Terbuka

- [ ] Tahap 31: daftarkan SHA-1/SHA-256 keystore release ke Firebase Console.
- [ ] Tahap 32: bersihkan field `isFavorite` yang sudah tidak terpakai.
- [ ] Tahap 33: validasi regresi data lama pasca penggantian default kategori.
- [ ] Tahap 34: konfigurasi Google Sign-In iOS.

### Ditunda

- B4: Analytics Page khusus (Dashboard sudah punya entry point analitik melalui Insight Card).
- D2: History Detail sebagai bottom sheet informatif.
- C2 Savings Polish: audit spacing layar kecil dan ringkasan total dana.

---

## Aturan Main

1. Clean Architecture: Domain → Data → Presentation. Jangan campur UI dengan business logic.
2. Riverpod `Notifier`/`AsyncNotifier`/`ConsumerWidget` only. No GetX/Bloc.
3. Semua Firestore request try-catch, gagal → SnackBar.
4. SharedPreferences hanya untuk Dark Mode & Budget Limit.
5. No dummy code / TODO. `flutter analyze` harus bersih sebelum commit.
6. 1 task = 1 commit. Commit manual oleh user, AI hanya kasih deskripsi.
7. Penjelasan pakai analogi sederhana untuk user pemula.
8. Sebelum eksekusi task, jelaskan rencana file apa + kenapa, minta persetujuan.
9. Jangan membuat commit otomatis.
10. Jangan menghapus perubahan lokal yang belum di-commit.
11. Satu tahap harus diverifikasi dengan analyzer dan test sebelum pindah tahap.

---

## Struktur Proyek

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
│   ├── dashboard/       (page + widgets/*: balance_hero_card, budget_status_section,
│   │                     dashboard_skeleton, dashboard_error_view, pie, insight, empty state)
│   ├── onboarding/      (onboarding_page, onboarding_slide)
│   ├── savings/         (goal, alokasi, arsip, celebration, edit goal/allocation)
│   ├── settings/        (settings_page ringan + widgets/*: profile, display, financial,
│   │                     data, snackbar, developer, contact, help center, avatar)
│   └── transactions/    (history, quick add, filter, CSV export, category icon)
└── firebase_options.dart
```

### Titik Penting

- **`main.dart` memiliki dua `MaterialApp`**: `_AuthGate` dan `SavuApp`. Keduanya mengamankan `appThemeModeProvider` dan memakai `SavuTheme.light()`/`SavuTheme.dark()`.
- **`historyNavigationIntentProvider`** dipantau `AppShell` lewat `ref.listen` untuk memindahkan tab ke Riwayat dari budget overview.
- **`Alokasi Tabungan` adalah kategori sistem**: dipakai `savings_providers.dart:227` untuk alokasi otomatis, disembunyikan dari chip user. Jangan dihapus.
- **`isFavorite` mati suri**: ada di entity dan model, tapi tidak dipakai UI mana pun.
- **ASET `assets/images/Savu_logo.png` tidak ada di working tree**. Hanya `assets/images/app_icon.png` yang terdaftar di `pubspec.yaml`.

---

## Verifikasi Terakhir

- `flutter analyze`: **No issues found**
- `flutter test`: **73/73 lulus** (21 file test)
- `flutter build web`: berhasil
- `flutter build apk --debug`: berhasil
- `flutter build windows --debug`: berhasil
- Flutter 3.32.8 / Dart 3.8.1 (stable)

---

## Cara Resume di Model Baru

1. Baca `progress.md` ini + `task.md` + `AGENTS.md` + `PRD.md`.
2. Cek `git status --short --branch` dan `git log --oneline -10`.
3. Jangan menghapus perubahan lokal.
4. Jalankan `flutter analyze` dan `flutter test` sebelum commit bila ada perubahan.
5. Mulai dari Tahap 31 pada backlog di atas.

Contoh prompt resume:

```
Baca progress.md, task.md, AGENTS.md, dan PRD.md.
Kondisi saat ini (branch develop_dua, working tree clean):
- flutter test: 73/73 lulus
- flutter analyze: No issues found
- FASE PRD 1-4 tuntas. Rebrand ke Savu tuntas.

Mulai dari Tahap 31 pada backlog progress.md.
Jelaskan rencana per file sebelum mengubah apa pun, lalu minta persetujuan.
Commit dilakukan manual oleh user; AI hanya memberi deskripsi commit.
```

---

## Catatan Tambahan

- User prefer commit manual, jangan auto `git add/commit`.
- User ingin UI tidak polos, seperti app profesional (gradient, card elevation, icon, empty state ilustratif).
- User memilih privacy mode tidak menyembunyikan nominal pada History; privacy mode tetap untuk Dashboard.
- Fitur arsip: user setuju rekomendasi Tab Aktif/Selesai, bukan auto-delete.

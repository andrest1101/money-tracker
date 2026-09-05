# 📋 TASK TRACKER - MONEYTRACKER APP

> **🔄 PROTOKOL RESUME (untuk AI agent di sesi baru):**
> Saat user membuka sesi baru di project ini, LAKUKAN:
> 1. Baca file ini + `AGENTS.md` + `PRD.md` secara lengkap.
> 2. Cari task `[ ]` pertama yang belum dicentang — itu posisi progres sekarang.
> 3. Cek `git log --oneline` + `git branch` untuk verifikasi commit terakhir & branch aktif.
> 4. Sampaikan ringkasan posisi progres ke user, lalu **minta konfirmasi** sebelum mengerjakan apa pun.
>
> **⚠️ GAYA KERJA YANG DIINGINKAN USER:**
> - 1 task kecil = 1 commit. JANGAN kerjakan banyak task sekaligus.
> - Sebelum eksekusi task, jelaskan dulu rencananya (file apa, isi apa, kenapa) dalam bahasa Indonesia yang mudah dipahami pemula, lalu MINTA PERSSETUJUAN.
> - Setelah eksekusi, jelaskan poin-poin pembelajaran dari kode yang dibuat (user sedang belajar).
> - **Commit & push DILAKUKAN MANUAL OLEH USER** — AI hanya memberikan deskripsi commit yang disarankan.
> - Gunakan analogi sederhana saat menjelaskan konsep (contoh: model = penerjemah, repo = dapur/teller bank).

---

## 📍 POSISI SAAT INI (update terakhir: 2026-09-03)

- Branch aktif: **`develop_dua`** (tracking `origin/develop_dua`, ahead 0 / behind 0, working tree bersih)
- **FASE 1 TUNTAS** — semua Task 1–6 ter-merge ke `main` via PR #3 + commit `54724a4`
- Bonus terselamatkan: fix minSdk 23 untuk Firestore (`feeac7e`)
- Pre-Task 7 ter-merge: `a3f265c` (bugfix overflow legenda + formatter titik ribuan)
- Kode sehat terakhir (2026-09-04): `flutter test` **69/69 lulus**, `flutter analyze` **No issues found**
- **Task 7 SELESAI** — SettingsService persisten + tema tersambung (dibuat ulang, lihat log insiden)
- **Task 8 SELESAI** — Overspending Alert 3 tingkat; Task 7+8 ter-push sebagai commit gabungan `83b13fe`
- **Task 9 SELESAI — FASE 2 TUNTAS! 🎉** Halaman Target + alokasi dana atomik (WriteBatch) + form target baru
- **Task 10 SELESAI** — Riwayat transaksi grouped per tanggal + warna saldo merah/hijau + bugfix over-allocation
- **Task 11 SELESAI** — Edit Transaksi: dual mode form (tambah/edit) + UI polished + edit alokasi dari 2 tempat (History & Savings page)
- **Enhancement Task 11** — Edit alokasi ke 0 (auto-delete with confirmation) + Sorting Target Tabungan (newest/oldest/progress) + field `createdAt`
- **Task 12 SELESAI — FASE 3 TUNTAS! 🎉** Hapus Transaksi: Dismissible swipe + button + dialog konfirmasi + handle delete alokasi atomik
- **Task 13 SELESAI — FASE 4 TUNTAS! 🎉** Halaman Pengaturan (Tema, Batas Anggaran) + **Redesign Premium UI** (Profil, Privacy Mode, Siklus Anggaran, Ekspor/Hapus Data).
- **Enhancement UI selesai:** History interaktif, pie chart kategori interaktif, dan overview Status Anggaran berbasis siklus
- **Rebrand TUNTAS:** aplikasi bernama **Savu** sejak `6dab288`. Package Android
  `com.example.savu`, launcher icon lintas platform, metadata web/desktop.
- **NEXT:** Step 30 selesai. Lanjutkan Step 31: SHA release, deployment Firebase,
  validasi Google Sign-In, dan deep link APK release. Lalu validasi onboarding terhadap
  user lama dan regresi kategori "Alokasi Tabungan".

⚠️ **Catatan sinkronisasi:** file `task.md` ini terakhir disentuh commit `6dab288`.
Tiga puluh commit terakhir tidak tercatat di sini. Rincian lengkap ada di
`progress.md` bagian "PERUBAHAN PASCA-HANDOFF".

### Step 18 — Modularisasi Settings

- [x] Entry page Settings dipisahkan dari komposisi content.
- [x] Section title, Help Center, FAQ sheet, dan developer branding memakai widget terpisah.
- [x] Provider, dialog, feedback, dan tampilan premium tetap dipertahankan.
- [ ] Pemecahan lanjutan komponen kompleks Settings menjadi file khusus jika ada kebutuhan perubahan fitur per section.

### Step 22-29 — Pekerjaan Pasca-Handoff (2026-09-02 s/d 2026-09-03)

- [x] **Step 22** — Rombak dark theme: `SavuTheme` dipecah menjadi `_buildLight()`
      (fromSeed) dan `_buildDark()` (palet charcoal `#121417` + surface solid
      `#1C2026` + aksen teal `#2DD4BF`). Diterapkan ke 25 file. (`28f2ba1`)
- [x] **Step 23** — Avatar profil preset: 30 avatar (15 general + 15 people),
      tersimpan di SharedPreferences, sheet picker responsif 3/4 kolom.
      Filter gender dihapus. (`a992904`, `402f04c`, `70bf265`, `6340933`, `cb8dab4`)
- [x] **Step 24** — Kontak founder: Gmail/WhatsApp/GitHub dibuka melalui intent
      native dengan fallback `url_launcher`. (`4a546bf`, `d23212c`, `05de391`)
- [x] **Step 25** — Onboarding page: 3 slide, `PageController`, ilustrasi custom,
      flag `onboarding_completed`, `AnimatedSwitcher` pada `_AuthGate`. (`f7b773f`)
- [x] **Step 26** — Warna progres target bertingkat (hijau 100%, biru >=50%,
      primary <50%) dan warna peringatan budget eksplisit per tema
      (`#FBBF24` dark / `#D97706` light). (`bb468d0`, `7171105`, `c5e99e3`)
- [x] **Step 27** — Arsip target tabungan: field `isArchived`, mode toggle,
      provider terpisah, pemisahan `deleteCompletedGoal()` dan
      `deleteGoalWithAllocations()`. Fitur favorit dicabut dari UI.
      (`9530cd5`, `2904310`, `e0803c1`)
- [x] **Step 28** — Rebrand menyeluruh ke Savu: package name, launcher icon lintas
      platform, judul aplikasi, dan metadata web/desktop.
      (`6dab288`, `a1ecb71`, `34a7d21`)
- [x] **Step 29** — Kategori default "Alokasi Tabungan" diganti menjadi
      "Kesehatan & Perawatan" lengkap dengan ikon dan warna baru. (`96a246a`)

### Step 30-34 — Pekerjaan Berikutnya

- [x] **Step 30** — Bersihkan 5 info `flutter analyze`: `settings_content.dart`
      (baris 1306, 1312, 1314), `financial_insight_overview_sheet.dart` (baris 499),
      `auth_landing_page.dart` (baris 604). Verifikasi 2026-09-04: `flutter analyze`
      No issues found, `flutter test` 69/69 lulus.
- [ ] **Step 31** — Daftarkan SHA-1/SHA-256 keystore release ke Firebase Console dan
      `web/.well-known/assetlinks.json`; validasi Google Sign-In dan deep link pada
      APK release.
- [ ] **Step 32** — Bersihkan field `isFavorite` yang tidak terpakai di
      `SavingsGoalEntity` dan model, atau pulihkan fitur favorit di UI.
- [ ] **Step 33** — Validasi regresi: pastikan transaksi lama berkategori
      "Alokasi Tabungan" tetap tampil benar pada pie chart dan filter History.
- [ ] **Step 34** — Konfigurasi Google Sign-In iOS (butuh Mac/Xcode,
      `GoogleService-Info.plist`, dan `REVERSED_CLIENT_ID`).

---

## 🎯 Aturan Main (ringkasan dari PRD & AGENTS.md)

1. Clean Architecture ketat: Domain (entitas, interface, use case) → Data (model, repo impl, provider) → Presentation (UI, Notifier).
2. State management WAJIB Riverpod (`Provider`, `Notifier`, `AsyncNotifier`, `ConsumerWidget`).
3. Semua request Firestore dibungkus try-catch; gagal → SnackBar.
4. SharedPreferences hanya untuk Dark Mode & Batas Anggaran Bulanan.
5. Tanpa dummy code / TODO. Setiap task selesai wajib lolos `flutter analyze` lalu commit konvensional (`feat: ...`).

---

## ✅ Keputusan Desain yang Sudah Disepakati

| Hal | Keputusan |
|-----|-----------|
| Navigasi utama | `NavigationBar` Material 3 (bottom nav: Dashboard / Target / Riwayat / Settings) |
| Quick Add Form | **Bottom sheet modal** (sesuai visi input super cepat) |
| Firebase project | `money-tracker-e22c0` (sudah terkonfigurasi penuh) |
| Pola data layer | Entity (domain) → Model extends Entity (`toMap`/`fromMap`) → FirestoreRepoImpl → Provider DI |
| Error pattern | Repo melempar custom Exception berbahasa Indonesia → Notifier menampilkan SnackBar |
| Git workflow | **Commit & push manual oleh user** (AI hanya memberi deskripsi commit). Branch per fase: `feature/fase1-dashboard` (Task 3–6) → merge ke `main` saat fase tuntas, dst. |
| Kategori transaksi | General, bukan contoh PRD: expense = Makanan/Transportasi/Bensin/Pulsa & Kuota/Hiburan/Kos & Tagihan/Belanja/Lainnya; income = Uang Kiriman/Beasiswa/Gaji Part-time. Chip "Baru" untuk custom + kategori dari transaksi lama otomatis jadi chip |
| Dependensi chart | `fl_chart` dipatok exact `1.0.0` — v1.1.x butuh vector_math baru yang tidak kompatibel dengan Flutter 3.32.x |
| Android minSdk | Hardcoded `23` di `android/app/build.gradle.kts` (syarat cloud_firestore 6.x) |
| ID transaksi | `DateTime.now().microsecondsSinceEpoch.toString()` — tanpa dependensi uuid |
| Progress bar anggaran | Disembunyikan (hint teks) sampai batas diatur; `budgetLimitProvider` (Notifier) menunggu SharedPreferences di Task 7-8 |

⚠️ **Prasyarat:** Cloud Firestore harus sudah aktif di Firebase Console + security rules mengizinkan read/write.

---

## 📝 Daftar Task (1 task = 1 commit)

### FASE 1 — Core Dashboard & Input Transaksi

- [x] **Task 1 — Data layer Transaksi**
  File: `lib/core/firebase/firebase_providers.dart`, `transactions/data/models/transaction_model.dart`, `transactions/data/repositories/firestore_transaction_repository.dart`, `transactions/data/providers/transaction_repository_provider.dart`
  Commit: `637e390`

- [x] **Task 2 — Data layer Savings**
  File: `savings/data/models/savings_goal_model.dart`, `savings/data/repositories/firestore_savings_goal_repository.dart`, `savings/data/providers/savings_goal_repository_provider.dart`
  Koleksi Firestore: `savings_goals`, stream diurutkan per `deadline` (terdekat dulu).

- [x] **Task 3 — App shell**
  Rewrite `main.dart`: `ProviderScope`, `SavuApp` (ConsumerWidget) tema M3 hijau + darkTheme. Baru: `lib/core/navigation/app_shell.dart` — NavigationBar 4 tab (Beranda/Target/Riwayat/Pengaturan) + IndexedStack. Test diperbarui: smoke test nav bar + pindah tab. Branch: `feature/fase1-dashboard`.

- [x] **Task 4 — Dashboard bagian 1: Card Saldo + Status Anggaran**
  Use case kalkulasi saldo (income − expense bulan berjalan) dari stream transaksi. UI: Card Saldo Utama + status anggaran (bar tersembunyi sampai batas diatur di Task 7). File: `dashboard/domain/entities/monthly_summary_entity.dart`, `dashboard/domain/usecases/calculate_monthly_summary_usecase.dart`, `dashboard/presentation/providers/dashboard_providers.dart`, `dashboard/presentation/pages/dashboard_page.dart`, plus helper `core/utils/rupiah_formatter.dart`.

- [x] **Task 5 — Dashboard bagian 2: PieChart kategori**
  Donat chart (tanpa label irisan) + legenda warna (nama kategori, nominal, persen), palet 8 warna round-robin, empty state teks ramah. File: `dashboard/domain/entities/category_expense_entity.dart`, `dashboard/domain/usecases/calculate_category_expenses_usecase.dart`, provider `categoryExpensesProvider`, widget modular `dashboard/presentation/widgets/category_expense_pie_card.dart`. ⚠️ `fl_chart` diturunkan & dipatok exact `1.0.0` (v1.1.0 butuh vector_math baru yang tak kompatibel dgn Flutter 3.32.x).

- [x] **Task 6 — Quick Add Form (bottom sheet)**
  Form nominal, SegmentedButton tipe, chips kategori dinamis (default general bukan PRD: Makanan/Transportasi/Bensin/Pulsa & Kuota/Hiburan/Kos & Tagihan/Belanja/Lainnya utk expense; Uang Kiriman/Beasiswa/Gaji Part-time utk income; chip "Baru" utk custom; kategori dari transaksi lama otomatis jadi chip), tanggal default hari ini, catatan opsional. Validasi inline, simpan via QuickAddController → repo, SnackBar sukses/gagal, auto-pop. FAB "Catat" di Dashboard. ID = microsecond epoch. File: `transactions/presentation/providers/quick_add_controller.dart`, `transactions/presentation/widgets/quick_add_transaction_sheet.dart`. **FASE 1 TUNTAS** ✅

### FASE 2 — Anggaran & Tabungan

- [x] **Task 7 — SettingsService (SharedPreferences)**
  Service + provider simpan/baca batas anggaran bulanan & dark mode. File: `core/local_storage/settings_service.dart` (SettingsService + SettingsServiceException), `core/local_storage/settings_providers.dart` (sharedPreferencesProvider wajib di-override di main, settingsServiceProvider, budgetLimitProvider pindah dari dashboard_providers, appThemeModeProvider ThemeMode 3-state system/light/dark). main.dart: preload prefs → `overrideWithValue`; MaterialApp watch `appThemeModeProvider`. Keputusan user: tema 3 pilihan (default system), wiring tema sekalian di Task 7. Test: 5 unit via mock. ⚠️ Pernah hilang dari disk karena belum di-commit — dibuat ulang utuh (lihat log insiden).

- [x] **Task 8 — Overspending Alert**
  Bar status anggaran berubah MERAH saat pengeluaran ≥80% batas. File: `dashboard/domain/entities/budget_status_entity.dart` (enum BudgetLevel safe/warning/exceeded + spentRatio), `dashboard/domain/usecases/check_budget_status_usecase.dart` (threshold const 0.8; limit ≤0 → aman rasio 0), refactor `_BudgetStatusSection` → ekstrak `_BudgetAlertContent` (terima `double` non-null agar null-promotion jalan): bar merah + ikon warning + pesan beda utk siaga/lewat + persen di teks. Keputusan user: 1A (3 tingkat) & 2A (ikon+teks, aksesibilitas). Test: 5 unit threshold → total 21 passed.

- [x] **Task 9 — Halaman Target Tabungan**
  List goals + indikator progres + dialog "Alokasikan Dana" + form target baru (keputusan user: 1A/2A/3A). File: `savings/domain/usecases/allocate_to_goal_usecase.dart` (+InvalidAllocationException), interface repo + `allocateToGoal` dengan **WriteBatch** atomik (update goal + set transaksi 'Alokasi Tabungan' sekaligus; nama koleksi transaksi kini publik di FirestoreTransactionRepository.collectionName), `presentation/providers/savings_providers.dart` (savingsGoalsStreamProvider + SavingsActionsController: addGoal & allocateToGoal), UI: `pages/savings_page.dart`, `widgets/goal_card.dart`, `widgets/allocate_fund_sheet.dart` (validasi inline pakai use case, formatter titik ribuan), `widgets/add_goal_sheet.dart`. app_shell: placeholder Target → SavingsPage. Baru juga `core/utils/date_formatter.dart` (formatDateShort). Test: 4 unit use case → total 25 passed. Keputusan desain penting: alokasi = transaksi expense kategori 'Alokasi Tabungan' agar saldo utama turun otomatis (tidak dobel hitung) dan ikut pie chart/batas anggaran.

### FASE 3 — Riwayat

- [x] **Task 10 — Riwayat Transaksi**
  Daftar grouped per tanggal, urut descending (data sudah descending dari Task 1). File: `transactions/domain/usecases/group_transactions_by_date_usecase.dart` (format bulan Indonesia), `presentation/providers/history_providers.dart` (groupedTransactionsProvider + filter/search + dailySummary), `presentation/pages/history_page.dart` (Card-based grouped list + filter chips + search bar + ringkasan harian + empty state), `presentation/widgets/transaction_tile.dart` (Card design + waktu + ikon dinamis + tap aksi), `presentation/widgets/category_icon.dart` (ikon dinamis per kategori dengan warna). Bonus: warna saldo di dashboard merah (minus) / hijau (plus). Bugfix: alokasi > sisa target ditolak (hard cap).

- [x] **Task 11 — Edit Transaksi**
  Buka form Task 6 dengan data terisi, update ke Firestore via `updateTransaction`. File: `quick_add_controller.dart` (+updateTransaction method + `_updateAllocationTransaction` dengan fetch langsung dari Firestore), `quick_add_transaction_sheet.dart` (dual mode: tambah/edit, pre-fill form, judul/tombol dinamis, UI polished, validasi allow 0 untuk alokasi + dialog konfirmasi withdraw), `history_page.dart` (koneksi edit ke form), `goal_card.dart` (expandable riwayat alokasi + edit langsung dari card). Bugfix: `getTransactionById()` + `getGoalById()` langsung dari Firestore (bukan stream). Enhancement: Edit alokasi ke 0 auto-delete transaksi dengan konfirmasi user. Dual edit option: History page & Savings page (expandable card). Field baru: `goalId` di TransactionEntity untuk link ke target tabungan, `createdAt` di SavingsGoalEntity untuk sorting. Sorting target tabungan: newest/oldest/progress (dropdown di AppBar, saved to SharedPreferences). Test: 32/32 passed.

- [x] **Task 12 — Hapus Transaksi**
  Dismissible widget (swipe kiri/kanan) + button hapus di bottom sheet + dialog konfirmasi sebelum `deleteTransaction`. File: `quick_add_controller.dart` (+deleteTransaction method dengan logic handle alokasi vs non-alokasi), `savings_goal_repository.dart` (+deleteAllocation interface), `firestore_savings_goal_repository.dart` (implement deleteAllocation dengan WriteBatch atomik: delete transaction + update goal), `history_page.dart` (update _confirmDelete dengan async logic + call controller + pesan berbeda untuk alokasi), `transaction_tile.dart` (wrap dengan Dismissible, background gradient merah dengan ikon delete_sweep + label "Hapus", confirmDismiss untuk trigger dialog). Dual delete option: swipe gesture (cepat) atau button di bottom sheet (lebih hati-hati). Dialog message berbeda untuk transaksi alokasi: "Alokasi sebesar [amount] untuk [goal title] akan dihapus dan uang kembali ke saldo utama." SnackBar sukses hijau, error merah. Test: 32/32 passed. **FASE 3 TUNTAS 🎉**

### FASE 4 — Personalisasi

- [x] **Task 13 — Settings Page & Premium UI Redesign**
  Halaman pengaturan yang komprehensif dan profesional layaknya aplikasi FinTech modern. File: `settings_page.dart` (dirombak total menjadi modular card), `settings_service.dart` & `settings_providers.dart` (tambah state: nama pengguna, mode privasi, siklus anggaran bulanan). Fitur:
  - Profil Pengguna: Avatar inisial, nama yang bisa diubah, status sinkronisasi cloud.
  - Privasi & Tampilan: Tema (Sistem/Terang/Gelap) menggunakan `_ThemeChip` yang responsif, dan Toggle **Mode Privasi** (Sembunyikan Saldo) yang terhubung ke Dashboard.
  - Keuangan: Dialog Atur Batas Anggaran (dengan ribuan formatter) & Siklus Anggaran (Tanggal gajian 1-28).
   - Manajemen Data: Ekspor CSV dan Hapus Semua Data (lengkap dengan dialog konfirmasi *Danger Zone*).
  - Info Dev: Versi aplikasi & kredit pembuat (Andre).
   **FASE 4 TUNTAS 🎉**

### ENHANCEMENT — Interactive Finance Insights

- [x] **History Card & Daily Overview**
  Nominal pada ringkasan tanggal dan transaction tile dibuat adaptif agar tidak menjadi `...` pada Android. Header tanggal sekarang interaktif dan membuka bottom sheet overview berisi total pemasukan, pengeluaran, selisih bersih, jumlah transaksi, dan daftar transaksi. Privacy mode Dashboard tidak diterapkan ke History sesuai keputusan user.

- [x] **Interactive Category Expense Chart**
  Segmen pie chart dan legend dapat dipilih. Segmen aktif membesar, segmen lain diredupkan, dan bagian tengah chart menampilkan kategori, nominal, serta persentase. Bottom sheet detail kategori menampilkan total, persentase terhadap total pengeluaran, jumlah transaksi, rata-rata, transaksi terbesar, dan daftar transaksi.

- [x] **Interactive Budget Overview**
  File baru: `dashboard/domain/entities/budget_overview_entity.dart` dan `dashboard/domain/usecases/calculate_budget_overview_usecase.dart`. Card Status Anggaran sekarang menampilkan status, progress, sisa/kelebihan, dan periode aktif; tap membuka overview dengan statistik transaksi, rata-rata harian, proyeksi akhir periode, dan tiga kategori pengeluaran terbesar. Perhitungan mengikuti `budgetCycleDateProvider`, termasuk periode lintas bulan.

- [x] **Budget Overview Tests**
  File: `test/calculate_budget_overview_usecase_test.dart`. Menguji siklus aktif, transaksi di luar periode, sisa anggaran, status terlampaui, kategori terbesar, dan proyeksi. Total suite terakhir: 34 test passed.

---

## 🗂️ Struktur Folder Saat Ini (update 2026-09-03)

Pohon di bawah sudah mencakup seluruh fitur yang ditambahkan setelah Task 13.

```
lib/
├── main.dart                      _AuthLinkHandler → _AuthGate → SavuApp
├── firebase_options.dart          config Firebase (generated)
├── core/
│   ├── errors/app_error_message.dart      pemetaan error Firestore terpusat
│   ├── firebase/
│   │   ├── firebase_providers.dart
│   │   └── auth_providers.dart            authStateChangesProvider, authControllerProvider
│   ├── local_storage/
│   │   ├── settings_service.dart          budget limit, tema, nama, tipe profil, avatar,
│   │   │                                  privacy, siklus anggaran, sorting, last sync, onboarding
│   │   └── settings_providers.dart        10 Notifier: budgetLimit, appThemeMode, userName,
│   │                                      userProfileType, profileAvatar, privacyMode,
│   │                                      budgetCycleDate, lastSuccessfulSync,
│   │                                      savingsSort, onboardingCompleted
│   ├── navigation/app_shell.dart          FloatingPillNavigation + create options sheet
│   ├── theme/savu_theme.dart              _buildLight (fromSeed) + _buildDark (palet manual)
│   ├── utils/                             rupiah_formatter, date_formatter,
│   │                                      thousands_separator_input_formatter
│   └── widgets/app_page_background.dart   background bersama seluruh halaman
├── features/
│   ├── analytics/                 cash flow, balance trend, expense flow insight + overview
│   ├── auth/                      auth_landing_page, email_verification_page
│   ├── dashboard/                 summary, budget overview, pie chart, financial insight,
│   │                              empty state
│   ├── onboarding/                onboarding_page, onboarding_slide   ← BARU (f7b773f)
│   ├── savings/                   goal, alokasi atomik, arsip, celebration,
│   │                              edit goal, edit alokasi
│   ├── settings/                  settings_page (ringan) + 10 widget modular
│   └── transactions/              history, quick add, filter, CSV export, category icon
└── firebase_options.dart
```

### Hal yang Sering Terlupakan saat Mengubah Kode

- **`main.dart` punya dua `MaterialApp`** — `_AuthGate` dan `SavuApp`. Keduanya
  mengamankan `appThemeModeProvider` dan memakai `SavuTheme`. Perubahan tema atau
  judul aplikasi harus dicek di kedua tempat.
- **`historyNavigationIntentProvider`** dipantau `AppShell` lewat `ref.listen` untuk
  memindahkan tab ke Riwayat otomatis dari budget overview.
- **`Alokasi Tabungan` adalah kategori sistem.** Dipakai `savings_providers.dart:227`
  saat alokasi otomatis, disembunyikan dari chip di
  `quick_add_transaction_sheet.dart:78`, tetapi masih punya gaya di
  `category_icon.dart:21`. Jangan dihapus tanpa migrasi data.
- **`isFavorite` mati suri** — ada di entity dan model, tidak dipakai UI mana pun.
- **`Savu_logo.png` tidak ada di working tree** meski masih ada di riwayat git.
  Hanya `assets/images/app_icon.png` yang terdaftar di `pubspec.yaml`.

---

## 📌 Log Perubahan Singkat

| Tanggal | Task | Catatan |
|---------|------|---------|
| 2026-08-25 | Task 1 | Data layer transaksi selesai, analyze bersih, commit `637e390` |
| 2026-08-25 | Task 2 | Data layer savings selesai, analyze bersih. Konsep saldo (income−expense) vs batas anggaran (SharedPreferences) sudah dikonfirmasi ke user |
| 2026-08-25 | Task 3 | App shell selesai di branch `feature/fase1-dashboard`. Analyze + test bersih (2 smoke test). Pelajaran: IndexedStack memasang semua child di tree → finder perlu `find.descendant` |
| 2026-08-25 | Task 4 | Dashboard bagian 1 selesai. Analyze + test bersih. Keputusan: progress bar disembunyikan (hint teks) sampai batas anggaran tersimpan (Task 7). `budgetLimitProvider` pakai `Notifier` (Riverpod 3, bukan StateProvider). Format Rupiah manual di `core/utils/rupiah_formatter.dart` karena tanpa dependensi `intl` |
| 2026-08-25 | Task 5 | PieChart kategori selesai (donat + legenda). Analyze + test bersih. Pelajaran penting: fl_chart 1.1.0 gagal compile saat test karena butuh `Matrix4.translateByDouble` (vector_math ≥2.2) sedangkan Flutter 3.32.x bawa vector_math 2.1.4 → solusi: pin exact `fl_chart: 1.0.0`. Pelajaran Dart lain: static const antar-kelas tidak bisa diakses bare-name → jadikan top-level const |
| 2026-08-25 | Task 6 | Quick Add Form selesai — **FASE 1 TUNTAS** 🎉. Keputusan: kategori general (bukan contoh PRD), chips beda utk income/expense, chip "Baru" utk custom, kategori belajar dari data Firestore. Test bertambah jadi 3 (validasi nominal tanpa Firebase). Analyze + test bersih. **NEXT: PR `feature/fase1-dashboard` → `main`, lalu buat branch `feature/fase2-anggaran-tabungan`** |
| 2026-08-26 | Git cleanup | PR #3 merge ✓ → main sinkron. Audit seluruh branch: fase1-dashboard terhapus (sudah ter-merge), init-clean-architecture dihapus SETELAH diselamatkan fix minSdk 23 utk Firestore (`feeac7e` di main), master & agents/* terbukti 0 commit unik vs main. Branch aktif: `feature/fase2-anggaran-tabungan`. Pelajaran: sebelum hapus branch, cek `git branch --merged main` + `git log main..branch` |
| 2026-08-26 | Bugfix | Overflow legenda pie chart ("RIGHT OVERFLOWED BY 20 PIXELS") saat nominal besar (contoh Rp 1.300.000). Akar masalah: `FittedBox` dalam `Row` tak menerima batasan lebar → tidak pernah men-scale-down. Fix: `LayoutBuilder` + `ConstrainedBox(maxWidth: 50% lebar legenda)`; bonus pie chart 168→144 (hole 36 / ring 30). Pelajaran: FittedBox hanya bekerja kalau constraints-nya bounded |
| 2026-08-26 | Enhancement | Input nominal live format titik ribuan: `core/utils/thousands_separator_input_formatter.dart` (`ThousandsSeparatorInputFormatter`, kursor dipertahankan, membuang non-digit), dipasang di Quick Add sheet (hint `25.000`, parsing `replaceAll('.')` sebelum `double.tryParse`). 8 test formatter baru → total 11 passed, analyze bersih. Formatter reusable utk Task 11 (edit) & Task 13 (batas anggaran). Pelajaran dari test gagal: `replaceAll('.', '')` tidak cukup — wajib filter code unit digit 0x30–0x39 |
| 2026-08-26 | Task 7 | SettingsService selesai. Pola: prefs dimuat SEKALI di main() lalu inject via `sharedPreferencesProvider.overrideWithValue` → semua provider settings tetap SINKRON (tanpa loading state). `budgetLimitProvider` pindah ke core/local_storage (API sama), dashboard tak berubah logika. Tema = ThemeMode 3-state (system/light/dark default system), tersambung ke MaterialApp. Widget test perlu helper `buildApp()` dgn mock prefs. Pelajaran: provider yang melempar UnimplementedError = kontrak "wajib dioverride" |
| 2026-08-26 | ⚠️ Insiden | Seluruh perubahan Task 7 yang BELUM di-commit hilang dari disk saat sesi Task 8 (main.dart & dashboard_providers.dart revert, core/local_storage/, test settings & widget hilang — diduga buffer/undo editor menimpa file). Penanganan: audit `git status --short` + `git log`, lalu buat ulang semuanya. **Pelajaran: commit segera saat task hijau; jangan tumpuk banyak perubahan belum-commit; hati-hati undo/buffer editor pada file yang sedang diedit AI** |
| 2026-08-26 | Task 8 | Overspending Alert selesai (3 tingkat: aman / siaga ≥80% / lewat ≥100%). Logika di domain (`BudgetStatusEntity`, `CheckBudgetStatusUseCase` threshold const 0.8, limit ≤0 aman); UI hanya merender. Ekstraksi widget `_BudgetAlertContent` (terima double non-null) memecahkan error null-promotion. Bar merah + ikon warning + pesan siaga/lewat + persen. Test threshold 5 unit → total **21 passed**, analyze bersih. Catatan teknis: edit paralel ke file yang sama bisa saling menimpa → edit same-file harus berurutan |
| 2026-08-26 | Task 9 | Halaman Target Tabungan selesai — **FASE 2 TUNTAS 🎉**. Pelajaran 1: **WriteBatch** = dua operasi Firestore (update goal + buat transaksi) dalam satu paket atomik, mencegah kondisi "uang keluar tapi goal tidak naik" bila salah satu gagal. Pelajaran 2: alokasi dianalogikan transaksi expense khusus → saldo, pie chart & alert otomatis konsisten tanpa logika baru (satu sumber kebenaran). Pelajaran 3: kegagalan test "pindah tab" membongkar bug edit-ku sendiri — SavingsPage masuk tapi placeholder Target lupa dihapus → 5 halaman utk 4 tab; test widget terbukti penjaga yang efektif. Validasi alokasi inline di sheet memakai use case yang sama dgn controller (aturan tidak diduplikasi) |
| 2026-08-26 | Task 10 | Riwayat transaksi selesai (grouped per tanggal + empty state + transaction_tile reusable). Bonus: warna saldo dashboard merah/hijau sesuai tipe (standar UX finance app). Bugfix over-allocation: alokasi > sisa target ditolak (hard cap) via AllocateToGoalUseCase + 2 test baru → total **32/32 test passed**. Pelajaran: import path relatif di subfolder presentation perlu naik ke features/ dulu (`../../../` bukan `../`), dan widget test harus di-update saat placeholder diganti widget asli |
| 2026-08-26 | UI History | Redesign halaman Riwayat: Card-based per tanggal dengan ringkasan harian (total +/- per hari), filter chips (Semua/Pemasukan/Pengeluaran), search bar minimalis, transaction tile baru dengan ikon dinamis per kategori (12 warna), waktu transaksi, dan tap aksi (edit/hapus placeholder). Provider baru: filter + search + dailySummary. Catatan: `StateProvider` dihapus di Riverpod 3.x → pakai `Notifier` pattern |
| 2026-08-26 | Task 11 | Edit Transaksi selesai — dual mode form (tambah/edit). `QuickAddTransactionSheet` terima `TransactionEntity?` → pre-fill form saat edit, judul "Edit Transaksi", tombol "Perbarui", ID dipertahankan. `QuickAddController` +`updateTransaction()` method. UI polished: warna dinamis mengikuti tipe (merah expense/hijau income), border bulat, section headers, icon di judul. Koneksi dari history tap → edit → form → update Firestore → stream refresh. **32/32 test passed** |
| 2026-08-26 | Bugfix alokasi | Fix bug: edit transaksi alokasi tabungan tidak update `currentAmount` goal. Akar masalah: tidak ada field `goalId` di `TransactionEntity`. Fix: tambah `goalId` (nullable) ke entity + model, set `goalId: goal.id` saat alokasi, tambah `updateAllocation()` di repository (WriteBatch atomik: update transaksi + goal), update `QuickAddController._updateAllocationTransaction()` (hitung selisih, apply ke goal). Backward compatible: transaksi lama `goalId: null` tetap bisa di-edit normal. **32/32 test passed** |
| 2026-08-26 | Bugfix alokasi edit | Fix bug: edit transaksi alokasi tabungan gagal ("Target tabungan tidak ditemukan"). Akar masalah: `_updateAllocationTransaction()` baca `savingsGoalsStreamProvider.value` — stream bisa masih loading → null → list kosong → `firstWhere` throw. Fix: tambah `getGoalById(String id)` di `SavingsGoalRepository` interface + impl Firestore (fetch langsung dari doc), refactor `_updateAllocationTransaction()` pakai `getGoalById()` alih-alih stream. Hapus import `savings_providers.dart` yang tidak terpakai. **32/32 test passed** |
| 2026-08-27 | Enhancement Task 11 | **Dual edit allocation**: GoalCard jadi expandable dengan riwayat alokasi (tap item → edit). Edit alokasi sekarang bisa dari History page ATAU Savings page. **Edit to 0 with auto-delete**: Validasi allow 0 dengan warning message, dialog konfirmasi "Withdraw Semua Alokasi?", auto-delete transaction + restore goal amount (logic di `_updateAllocationTransaction`). **Sorting target tabungan**: Tambah field `createdAt` di SavingsGoalEntity & Model, `SavingsSortController` (Notifier dengan SharedPreferences), `sortedSavingsGoalsProvider` (newest/oldest/progress), dropdown di AppBar SavingsPage. Fix: tambah `getTransactionById()` di TransactionRepository untuk fetch old transaction langsung dari Firestore (bukan stream). **32/32 test passed**. Pelajaran: stream provider bisa null saat loading → jangan andalkan untuk data kritis; pakai direct fetch via `getById()`. Expandable UI pattern: `ConsumerStatefulWidget` + `bool _isExpanded` + conditional rendering |
| 2026-08-27 | Task 12 | Hapus Transaksi selesai — **FASE 3 TUNTAS 🎉**. **Dual delete options**: Dismissible swipe gesture (cepat) ATAU button di bottom sheet (hati-hati). **Dismissible background**: Gradient merah dengan ikon `delete_sweep_rounded` + label "Hapus" (Column layout untuk visual yang lebih menarik). **Delete logic**: `QuickAddController.deleteTransaction()` dengan conditional: jika alokasi → `deleteAllocation()` (WriteBatch atomik: delete transaction + restore goal currentAmount); jika non-alokasi → direct delete. **Dialog konfirmasi**: Async fetch goal title untuk transaksi alokasi, pesan berbeda: "Alokasi sebesar [amount] untuk [goal] akan dihapus dan uang kembali ke saldo utama" vs "Transaksi [kategori] sebesar [amount] akan dihapus permanen". **SnackBar feedback**: Hijau untuk sukses, merah untuk error, pesan berbeda untuk alokasi vs non-alokasi. **confirmDismiss**: Return false agar tidak auto-dismiss, dialog yang handle manual. **32/32 test passed**. Pelajaran: Dismissible + dialog konfirmasi = UX terbaik (gesture cepat tapi tetap aman). WriteBatch untuk delete alokasi mencegah inconsistency (transaction hilang tapi goal tidak update) |
| 2026-08-27 | Bugfix UI | Fix UI overflow pada Android: 1. `history_page.dart` & `transaction_tile.dart` (Teks nominal meluber ke kanan jika panjang -> dibungkus `ConstrainedBox` & `Flexible`). 2. `settings_page.dart` (`SegmentedButton` tema meluber ke bawah karena padding bawaan -> diganti dengan custom `_ThemeChip` berbaris `Expanded` yang sangat responsif). |
| 2026-08-27 | Task 13 | Settings Page redesign kelas Premium — **FASE 4 TUNTAS 🎉**. UI pengaturan dirombak agar tidak polos. Tambah fitur: Nama pengguna, status sinkronisasi, **Mode Privasi** (sembunyikan saldo di dashboard), dan siklus anggaran. Layer Data diperbarui di `settings_service.dart`. **32/32 test passed**. Pelajaran: UI Settings yang baik di aplikasi finance harus membangkitkan rasa aman & personalisasi (identitas, privasi, danger zone jelas). |
| 2026-08-28 s/d 2026-08-31 | Enhancement | Serangkaian peningkatan: filter History searchable, ekspor CSV, hapus data massal, modularisasi Settings, empty state informatif, status sinkronisasi detail, Firebase Auth + path user-scoped, cash flow chart, balance trend, expense flow overview, filter rentang tanggal custom, dan penanganan error Firestore terpusat. Suite bertumbuh dari 32 menjadi 52 test |
| 2026-09-01 | Step 27 (awal) | Menu dan sistem pada menu goals: `isArchived` + `isFavorite` pada `SavingsGoalEntity`, `archivedModeProvider`, `archivedActiveGoalsProvider`, `archivedCompletedGoalsProvider`, serta `deleteCompletedGoal()` terpisah dari `deleteGoalWithAllocations()`. Widget `savings_overview.dart` dihapus. **Catatan:** fitur favorit kemudian dicabut pada `2904310`; field `isFavorite` kini tidak terpakai |
| 2026-09-02 | Rebrand | **MoneyTracker menjadi Savu** (`6dab288`). Package `com.example.savu`, `MainActivity.kt` dipindah, launcher icon baru untuk Android/iOS/Web/Windows/macOS, `flutter_launcher_icons` masuk dev_dependencies. `google-services.json` diperbarui: OAuth client sudah tersedia. Logo ganda dihapus (`34a7d21`). **Pelajaran:** rebrand aplikasi Flutter menyentuh lebih dari pubspec — AndroidManifest, Runner.rc, AppInfo.xcconfig, manifest.json, dan index.html ikut menyimpan nama aplikasi |
| 2026-09-02 | Step 23-24 | Avatar profil preset dan kontak founder. 30 avatar (15 general + 15 people) tersimpan di SharedPreferences dengan sheet picker responsif; filter gender dihapus karena memperumit UI. Kontak founder membuka Gmail/WhatsApp secara langsung memakai `android_intent_plus` dengan fallback `url_launcher`, menggantikan sheet berbagi generik memakai `share_plus`. **Pelajaran:** `share_plus` cocok untuk berbagi konten, bukan untuk membuka aplikasi tertentu — pakai intent atau `url_launcher` untuk itu |
| 2026-09-03 | Step 22 | Rombak total dark theme (`28f2ba1`, 25 file). `SavuTheme` dipecah menjadi `_buildLight()` (tetap `ColorScheme.fromSeed`) dan `_buildDark()` (palet manual). Dark theme lama memakai permukaan transparan yang menumpuk sehingga terlihat kotor; palet baru memakai surface solid `#1C2026` di atas scaffold `#121417` dengan aksen teal terang `#2DD4BF`. **Pelajaran:** skema warna hasil `fromSeed` sulit dikontrol presisi untuk dark mode — palet manual lebih mudah diaudit kontrasnya |
| 2026-09-03 | Step 25 | Onboarding page (`f7b773f`). Folder baru `features/onboarding/` dengan 3 slide, ilustrasi custom, dan flag `onboarding_completed` di SharedPreferences. `_AuthGate` di `main.dart` kini memilih antara `OnboardingPage` dan `_AuthContent` memakai `AnimatedSwitcher`. **Pelajaran:** menambahkan lapisan sebelum auth mengubah urutan bootstrap — user lama yang flag-nya belum pernah diset akan melihat onboarding sekali, jadi selalu siapkan nilai default yang aman |
| 2026-09-03 | Step 26 | Warna progres target dan peringatan budget. Progres target kini bertingkat: hijau terang saat 100%, biru terang saat >=50%, `cs.primary` di bawahnya. Warna peringatan budget diganti dari `cs.tertiary` menjadi konstanta eksplisit per tema karena `tertiary` sulit dibaca di dark mode. **Pelajaran:** mengandalkan peran warna ColorScheme bisa menghasilkan kontras buruk di satu tema; konstanta eksplisit per brightness lebih aman untuk warna semantik penting |
| 2026-09-03 | Step 29 | Kategori default "Alokasi Tabungan" diganti menjadi "Kesehatan & Perawatan" (`96a246a`). ⚠️ Alokasi otomatis ke target **tetap** menulis kategori `'Alokasi Tabungan'` dan chip pilihan user tetap membuangnya, jadi ketiga tempat ini harus dijaga konsisten. **Pelajaran:** mengganti nilai enum/string yang sudah tersimpan di database butuh strategi migrasi, bukan sekadar mengganti daftar default |
| 2026-09-03 | Verifikasi ulang | AI melakukan verifikasi mandiri: `flutter test` **69/69 lulus** (21 file), `flutter analyze` **5 info** (3× `use_build_context_synchronously`, 1× `curly_braces_in_flow_control_structures`, 1× `unnecessary_brace_in_string_interps`). Seluruh file md progres disinkronkan dengan 30 commit terakhir yang sebelumnya tidak tercatat. **Pelajaran:** dokumentasi yang tidak diperbarui bersama commit akan menyesatkan sesi berikutnya — lebih baik tidak ada angka daripada angka yang usang |
| 2026-09-04 | Step 30 | Lima info analyzer diperbaiki tanpa perubahan perilaku fitur: `context.mounted` untuk callback async Settings, braces pada callback chart, dan interpolasi string Auth. Verifikasi: `flutter analyze` **No issues found**, `flutter test` **69/69 lulus**. |

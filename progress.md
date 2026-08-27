# 🔄 PROGRESS HANDOFF - MoneyTracker

> File ini dibuat untuk melanjutkan sesi di model AI lain tanpa kehilangan memori.
> **Cara pakai di sesi baru:** suruh AI `baca progress.md + task.md + AGENTS.md + PRD.md` lalu lanjutkan dari `NEXT TASK` di bawah.

---

## 🕐 Timestamp
- **Terakhir update:** 2026-08-27
- **Branch aktif:** `feature/fase2-anggaran-tabungan`
- **Dibuat oleh:** Muse Spark (muse-spark-1.2-contributor-free) sebelum ganti model

---

## 📍 Posisi Saat Ini (sinkron dengan task.md:19-33)
- **FASE 1 TUNTAS** (Task 1-6) → merge ke `main` via PR #3 `54724a4`
- **FASE 2 TUNTAS** (Task 7-9) → `83b13fe`, `81aa315`
- **FASE 3 TUNTAS** (Task 10-12) → Task 12 baru selesai di working directory, **BELUM DI-COMMIT**
- **Kesehatan kode saat Task 11 enhancement:** `flutter analyze` bersih, 32/32 test passed
- **NEXT:** Task 13 Settings Page → FASE 4 TUNTAS → PR `feature/fase2-anggaran-tabungan` → `main`

### Git Status Saat Ini
```
Branch: feature/fase2-anggaran-tabungan
Last commits:
  28812ff feat: add edit allocation to zero with auto deleted and savings sorting
  99206bb feat: add transactionedit w  (Task 11 dual edit)
  5b3a316 feat: update history ui
  2354e4d fix: prevent over allocation...
  42aecb5 feat: add transaction history...
  81aa315 feat: add savings goals page...
  83b13fe feat: add settings persistence...

Uncommitted (Task 12, 6 files, +186 -18):
  M lib/features/savings/data/repositories/firestore_savings_goal_repository.dart  (+ deleteAllocation WriteBatch)
  M lib/features/savings/domain/repositories/savings_goal_repository.dart (+ deleteAllocation interface)
  M lib/features/transactions/presentation/pages/history_page.dart (+ _confirmDelete async + goal fetch)
  M lib/features/transactions/presentation/providers/quick_add_controller.dart (+ deleteTransaction)
  M lib/features/transactions/presentation/widgets/transaction_tile.dart (+ Dismissible)
  M task.md (tandai Task 12 selesai)
```

---

## ✅ Apa yang Baru Selesai (Task 12)

**Fitur:** Hapus Transaksi - Dismissible swipe kiri/kanan + dialog konfirmasi + handle alokasi atomik.

**File diubah:**
1. `lib/features/transactions/presentation/providers/quick_add_controller.dart:27-40` - `deleteTransaction()` cek `isAllocation` → panggil `savingsRepo.deleteAllocation()` (restore `currentAmount`) else direct delete. Sudah handle `newGoalAmount < 0`.
2. `lib/features/savings/domain/repositories/savings_goal_repository.dart:22-27` - tambah `deleteAllocation({goalId, newGoalAmount, transactionId})`
3. `lib/features/savings/data/repositories/firestore_savings_goal_repository.dart:148-176` - implement `deleteAllocation` dengan `WriteBatch` (update goal + delete transaction atomik)
4. `lib/features/transactions/presentation/pages/history_page.dart:101-167` - `_confirmDelete` jadi async: fetch goal title jika alokasi, dialog confirm bool, panggil controller, SnackBar hijau/merah beda pesan alokasi vs biasa
5. `lib/features/transactions/presentation/widgets/transaction_tile.dart:17-95` - tambah `onDismissed`, `_buildDismissBackground()` gradient merah `delete_sweep_rounded` + label Hapus, wrap dengan `Dismissible` (confirmDismiss return false, trigger dialog manual)
6. `task.md` - tandai Task 12 selesai + log

**Verifikasi:** `flutter analyze` No issues, `flutter test` 32/32 (sebelum Task 12, perlu re-run setelah commit).

**Belum di-commit:** User melakukan commit manual. Commit message disarankan ada di chat sebelumnya (feat: add delete transaction...). Jangan auto-commit.

---

## 🐛 Bug + Feature Request Aktif (BELUM DIKERJAKAN, prioritas berikutnya)

### 1. Sorting Target Tabungan Bug
**Laporan user (2026-08-27):**
- Dropdown sorting di `savings_page.dart:52-69` (Terbaru/Terlama/Progress Tinggi)
- **Hanya `Progress Tinggi` yang berfungsi**, `Terbaru` dan `Terlama` tidak mengubah urutan card.

**Analisis awal:**
- `savings_providers.dart:10-14` `watchGoals()` sekarang `orderBy('createdAt', descending:true)` (sudah di-fix dari `orderBy('deadline')` di commit 28812ff)
- `savings_providers.dart:55-77` `sortedSavingsGoalsProvider` melakukan client-side sort:
  ```dart
  newest: b.createdAt.compareTo(a.createdAt)
  oldest: a.createdAt.compareTo(b.createdAt)
  progress: b.progress.compareTo(a.progress)
  ```
- `savings_page.dart:42` sudah pakai `sortedSavingsGoalsProvider` (bukan stream langsung) → seharusnya bekerja.
- **Hipotesis bug:**
  1. Data lama di Firestore (`kabel`, `laptop Tuf` 4000) dibuat **sebelum field `createdAt` ada** → `SavingsGoalModel.fromMap` di `savings_goal_model.dart:31` pakai `_parseDate(map['createdAt'])` → jika null → `return DateTime.now()` → semua goal lama dapat `createdAt` hampir identik (saat dibaca sekarang, bukan saat dibuat) → sort tidak terlihat.
  2. Atau `createdAt` tersimpan tapi microsecond sama (buat berurutan cepat) → perbedaan tidak terlihat.
  3. Perlu cek Firestore Console: apakah `createdAt` field ada dan berbeda? Jika tidak, perlu data migration / fallback pakai `id` (microsecondsSinceEpoch) atau `deadline`.

**Rencana fix (disetujui user, belum eksekusi):**
- Opsi A (dipilih): tetap `orderBy('createdAt', desc)` di server, client handle oldest/progress. Untuk data lama tanpa `createdAt`, fallback sort pakai `id` atau `deadline` jika `createdAt` null/identik.
- Alternatif: Jika bug bukan data, cek apakah `SavingsSortController` persist ke SharedPreferences (`settings_service.dart:30-47` sudah ada `getSavingsSortOption/setSavingsSortOption`) bekerja, dan dropdown `onChanged` trigger rebuild.

### 2. Fitur Arsip / Tab Selesai untuk Target Tabungan
**Request user:**
- Card yang sudah selesai (contoh `kabel` 4000/4000) mengganggu list aktif. Jika banyak card, jadi semak.
- Ingin **otomatis masuk ke menu selesai / arsip** yang terpisah dari ongoing.
- User bisa bedakan arsip vs tidak, lebih mudah.
- UI jangan polos, harus seperti app profesional.

**Rekomendasi yang DISETUJUI user:**
- **Opsi 1 Tab System:** `SavingsPage` pakai `TabBar` dengan 2 tab: `Aktif` (progress < 1.0) vs `Selesai` (progress >= 1.0). Default tab `Aktif`. Tampilkan count badge `Aktif (3)` `Selesai (2)`.
- **Field:** Tidak tambah field baru, pakai computed `isCompleted => progress >= 1.0` (single source of truth, backward compatible). Jika nanti butuh arsip manual, baru tambah `isArchived`.
- **Sorting:** Fix dulu dengan `createdAt` desc sebagai default. Sorting preference disimpan per-device via SharedPreferences (sudah ada).
- **Visual:** Completed cards opacity 0.7 + checkmark / badge "Selesai" + warna berbeda, bukan hilang total.

**File yang akan diubah untuk fitur ini (belum dikerjakan):**
- `lib/features/savings/domain/entities/savings_goal_entity.dart` - tambah getter `isCompleted`
- `lib/features/savings/presentation/providers/savings_providers.dart` - tambah `activeSavingsGoalsProvider` dan `completedSavingsGoalsProvider` (filter dari `sortedSavingsGoalsProvider`), atau filter langsung dari `savingsGoalsStreamProvider`
- `lib/features/savings/presentation/pages/savings_page.dart` - ganti `Scaffold` body jadi `DefaultTabController` + `TabBar` + `TabBarView`, AppBar tetap ada dropdown sorting, FAB tetap. Empty state per tab berbeda. Butuh UI professional: TabBar dengan indicator rounded, card count, animasi.
- `lib/features/savings/presentation/widgets/goal_card.dart` - update visual untuk completed: opacity, badge, disable tombol Alokasikan Dana (sudah ada `isReached` logic).
- `lib/features/savings/data/repositories/firestore_savings_goal_repository.dart` - tidak perlu ubah query, cukup client filter. Jika mau auto-archive, nanti tambah `isArchived` field.
- `lib/core/local_storage/settings_service.dart` - sudah ada sorting pref, tidak perlu.

**Urutan eksekusi yang disepakati:**
1. Fix sorting bug dulu (HIGH PRIORITY) - investigasi data `createdAt`
2. Implement Tab Aktif/Selesai (MEDIUM)
3. Polish UI professional (MEDIUM)

---

## 📋 NEXT TASK YANG TERTUNDA

### Task 13 - Settings Page (dari PRD Fase 4)
- Toggle Dark Mode (SharedPreferences) - sebagian sudah di Task 7 (`settings_service.dart`, `settings_providers.dart`, `appThemeModeProvider`), tinggal buat UI halaman.
- Input Batas Anggaran Bulanan - `budgetLimitProvider` sudah ada, tinggal buat UI form + validasi + SnackBar.
- File target: `lib/features/settings/presentation/pages/settings_page.dart` (belum ada), route di `app_shell.dart`.

**Tapi sebelum Task 13, selesaikan dulu:**
1. Commit Task 12 (manual oleh user)
2. Fix sorting bug + Implement Tab Selesai/Arsip (sesuai request terbaru, dianggap enhancement Task 12 / Task 12.5)

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

## 📂 Struktur Penting (update terakhir)
```
lib/
├── core/local_storage/
│   ├── settings_service.dart (+ getSavingsSortOption/setSavingsSortOption)
│   └── settings_providers.dart (budgetLimitProvider, appThemeModeProvider, savingsSortControllerProvider)
├── features/
│   ├── transactions/
│   │   ├── domain/entities/transaction_entity.dart (isAllocation, goalId nullable)
│   │   ├── data/models/transaction_model.dart (goalId)
│   │   ├── data/repositories/firestore_transaction_repository.dart (getTransactionById, deleteTransaction)
│   │   └── presentation/
│   │       ├── pages/history_page.dart (Card grouped + filter + Dismissible integration)
│   │       └── widgets/transaction_tile.dart (Dismissible + gradient background)
│   ├── savings/
│   │   ├── domain/entities/savings_goal_entity.dart (createdAt required)
│   │   ├── data/models/savings_goal_model.dart (createdAt Timestamp)
│   │   ├── data/repositories/firestore_savings_goal_repository.dart (watchGoals orderBy createdAt desc, deleteAllocation)
│   │   └── presentation/
│   │       ├── pages/savings_page.dart (sortedSavingsGoalsProvider + Dropdown sorting)
│   │       ├── providers/savings_providers.dart (SavingsSortController, sortedSavingsGoalsProvider, allocationTransactionsProvider)
│   │       └── widgets/goal_card.dart (expandable riwayat alokasi)
│   └── dashboard/ ...
```

---

## 🚀 Cara Resume di Model Baru

1. Baca `progress.md` ini + `task.md` + `AGENTS.md` + `PRD.md`
2. Cek `git status --short` dan `git log --oneline -10` (sudah ada di atas, tapi verifikasi lagi)
3. Jika Task 12 belum di-commit, commit dulu dengan message:
   ```
   feat: add delete transaction with dismissible swipe and allocation handling
   ... (lihat detail di chat history atau task.md log)
   ```
4. Lanjut ke **Fix Sorting Bug**: cek Firestore data `createdAt` untuk goal `kabel` dan `laptop Tuf`, lalu perbaiki `savings_goal_model.dart` fallback atau `savings_providers.dart` sorting.
5. Lanjut ke **Tab Aktif/Selesai**: implementasi sesuai rencana di atas, UI professional (jangan polos).
6. Baru lanjut **Task 13 Settings Page**.

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


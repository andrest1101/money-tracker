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
  Rewrite `main.dart`: `ProviderScope`, `MoneyTrackerApp` (ConsumerWidget) tema M3 hijau + darkTheme. Baru: `lib/core/navigation/app_shell.dart` — NavigationBar 4 tab (Beranda/Target/Riwayat/Pengaturan) + IndexedStack, isi tab masih placeholder. Test diperbarui: smoke test nav bar + pindah tab. Branch: `feature/fase1-dashboard`.

- [x] **Task 4 — Dashboard bagian 1: Card Saldo + Status Anggaran**
  Use case kalkulasi saldo (income − expense bulan berjalan) dari stream transaksi. UI: Card Saldo Utama + status anggaran (bar tersembunyi sampai batas diatur di Task 7). File: `dashboard/domain/entities/monthly_summary_entity.dart`, `dashboard/domain/usecases/calculate_monthly_summary_usecase.dart`, `dashboard/presentation/providers/dashboard_providers.dart`, `dashboard/presentation/pages/dashboard_page.dart`, plus helper `core/utils/rupiah_formatter.dart`.

- [x] **Task 5 — Dashboard bagian 2: PieChart kategori**
  Donat chart (tanpa label irisan) + legenda warna (nama kategori, nominal, persen), palet 8 warna round-robin, empty state teks ramah. File: `dashboard/domain/entities/category_expense_entity.dart`, `dashboard/domain/usecases/calculate_category_expenses_usecase.dart`, provider `categoryExpensesProvider`, widget modular `dashboard/presentation/widgets/category_expense_pie_card.dart`. ⚠️ `fl_chart` diturunkan & dipatok exact `1.0.0` (v1.1.0 butuh vector_math baru yang tak kompatibel dgn Flutter 3.32.x).

- [x] **Task 6 — Quick Add Form (bottom sheet)**
  Form nominal, SegmentedButton tipe, chips kategori dinamis (default general bukan PRD: Makanan/Transportasi/Bensin/Pulsa & Kuota/Hiburan/Kos & Tagihan/Belanja/Lainnya utk expense; Uang Kiriman/Beasiswa/Gaji Part-time utk income; chip "Baru" utk custom; kategori dari transaksi lama otomatis jadi chip), tanggal default hari ini, catatan opsional. Validasi inline, simpan via QuickAddController → repo, SnackBar sukses/gagal, auto-pop. FAB "Catat" di Dashboard. ID = microsecond epoch. File: `transactions/presentation/providers/quick_add_controller.dart`, `transactions/presentation/widgets/quick_add_transaction_sheet.dart`. **FASE 1 TUNTAS** ✅

### FASE 2 — Anggaran & Tabungan

- [ ] **Task 7 — SettingsService (SharedPreferences)**
  Service + provider untuk simpan/baca batas anggaran bulanan & dark mode. Dibuat lebih awal karena Task 8 membutuhkannya.

- [ ] **Task 8 — Overspending Alert**
  Progress bar dashboard berubah **MERAH** jika pengeluaran ≥ 80% batas anggaran (dari SharedPreferences).

- [ ] **Task 9 — Halaman Target Tabungan**
  List goals + indikator progres + dialog "Alokasikan Dana" (pindah saldo utama → `currentAmount`). Validasi saldo cukup.

### FASE 3 — Riwayat

- [ ] **Task 10 — Riwayat Transaksi**
  Daftar grouped per tanggal, urut descending (data sudah descending dari Task 1).

- [ ] **Task 11 — Edit Transaksi**
  Buka form Task 6 dengan data terisi, update ke Firestore via `updateTransaction`.

- [ ] **Task 12 — Hapus Transaksi**
  `Dismissible` (swipe kiri/kanan) + dialog konfirmasi sebelum `deleteTransaction`.

### FASE 4 — Personalisasi

- [ ] **Task 13 — Settings Page**
  Toggle Dark Mode (SharedPreferences) + input Batas Anggaran Bulanan.

---

## 🗂️ Struktur Folder Saat Ini (yang relevan)

```
lib/
├── main.dart                        ✅ rewritten (Task 3): ProviderScope + tema M3 hijau
├── firebase_options.dart            ← config Firebase (generated)
├── core/
│   ├── firebase/firebase_providers.dart
│   └── navigation/app_shell.dart    ✅ NavigationBar 4 tab + IndexedStack
```
└── features/
    ├── transactions/
    │   ├── domain/
    │   │   ├── entities/transaction_entity.dart          ✅
    │   │   └── repositories/transaction_repository.dart  ✅ (interface CRUD + watch)
    │   └── data/
    │       ├── models/transaction_model.dart             ✅
    │       ├── repositories/firestore_transaction_repository.dart ✅
    │       └── providers/transaction_repository_provider.dart     ✅
    ├── presentation/  ← (di bawah features/transactions)
    │   ├── providers/quick_add_controller.dart           ✅ (Task 6)
    │   └── widgets/quick_add_transaction_sheet.dart      ✅ (Task 6)
    ├── savings/
    │   ├── domain/
    │   │   ├── entities/savings_goal_entity.dart         ✅
    │   │   └── repositories/savings_goal_repository.dart ✅ (interface)
    │   └── data/
    │       ├── models/savings_goal_model.dart            ✅
    │       ├── repositories/firestore_savings_goal_repository.dart ✅
    │       └── providers/savings_goal_repository_provider.dart     ✅
    └── dashboard/
        ├── domain/
        │   ├── entities/monthly_summary_entity.dart          ✅ (Task 4)
        │   ├── entities/category_expense_entity.dart         ✅ (Task 5)
        │   ├── usecases/calculate_monthly_summary_usecase.dart ✅ (Task 4)
        │   └── usecases/calculate_category_expenses_usecase.dart ✅ (Task 5)
        └── presentation/
            ├── providers/dashboard_providers.dart            ✅ (Task 4-5: stream + summary + kategori + budgetLimit Notifier)
            ├── pages/dashboard_page.dart                     ✅ (Task 4)
            └── widgets/category_expense_pie_card.dart        ✅ (Task 5)
```

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

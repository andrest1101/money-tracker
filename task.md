# 📋 TASK TRACKER - MONEYTRACKER APP

> **Cara pakai file ini:** Jika sesi terputus, minta AI agent membaca file ini + `AGENTS.md` + `PRD.md`,
> lalu lanjutkan dari task berstatus `[ ]` berikutnya. Jangan kerjakan beberapa task sekaligus —
> 1 task = 1 commit, agar setiap perubahan bisa di-review dan dipelajari.

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

⚠️ **Prasyarat:** Cloud Firestore harus sudah aktif di Firebase Console + security rules mengizinkan read/write.

---

## 📝 Daftar Task (1 task = 1 commit)

### FASE 1 — Core Dashboard & Input Transaksi

- [x] **Task 1 — Data layer Transaksi**
  File: `lib/core/firebase/firebase_providers.dart`, `transactions/data/models/transaction_model.dart`, `transactions/data/repositories/firestore_transaction_repository.dart`, `transactions/data/providers/transaction_repository_provider.dart`
  Commit: `637e390`

- [ ] **Task 2 — Data layer Savings**
  Buat `SavingsGoalModel` (toMap/fromMap), `FirestoreSavingsGoalRepository` (implementasi interface `savings_goal_repository.dart`), provider DI di `savings/data/`. Koleksi Firestore: `savings_goals`. Pola sama persis dengan Task 1.

- [ ] **Task 3 — App shell**
  Rewrite `main.dart`: bungkus `ProviderScope`, tema Material 3, halaman shell dengan `NavigationBar` 4 tab. Isi tab masih placeholder sederhana. Update `test/widget_test.dart` agar tidak test counter app lama.

- [ ] **Task 4 — Dashboard bagian 1: Card Saldo + Status Anggaran**
  Use case/provider kalkulasi saldo (income − expense bulan berjalan) dari stream transaksi. UI: Card Saldo Utama + `LinearProgressIndicator` status anggaran.

- [ ] **Task 5 — Dashboard bagian 2: PieChart kategori**
  PieChart `fl_chart` pengeluaran per kategori bulan berjalan.

- [ ] **Task 6 — Quick Add Form (bottom sheet)**
  Form nominal, tipe (income/expense), kategori, tanggal, catatan. Validasi kosong, simpan via repo, SnackBar sukses/gagal, auto-pop. FAB trigger di Dashboard.

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
├── main.dart                        ← masih template default (diubah di Task 3)
├── firebase_options.dart            ← config Firebase (generated)
├── core/firebase/firebase_providers.dart
└── features/
    ├── transactions/
    │   ├── domain/
    │   │   ├── entities/transaction_entity.dart          ✅
    │   │   └── repositories/transaction_repository.dart  ✅ (interface CRUD + watch)
    │   └── data/
    │       ├── models/transaction_model.dart             ✅
    │       ├── repositories/firestore_transaction_repository.dart ✅
    │       └── providers/transaction_repository_provider.dart     ✅
    ├── savings/
    │   ├── domain/
    │   │   ├── entities/savings_goal_entity.dart         ✅
    │   │   └── repositories/savings_goal_repository.dart ✅ (interface)
    │   └── data/                    ← Task 2 mengisi folder ini
    └── dashboard/{domain,data,presentation}/  ← Task 4-5 mengisi
```

---

## 📌 Log Perubahan Singkat

| Tanggal | Task | Catatan |
|---------|------|---------|
| 2026-08-25 | Task 1 | Data layer transaksi selesai, analyze bersih, commit `637e390` |

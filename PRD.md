# PRODUCT REQUIREMENTS DOCUMENT (PRD) - MONEYTRACKER APP

**Project Name:** MoneyTracker App  
**Platform:** Mobile (Android & iOS)  
**Target User:** Mahasiswa & anak kos Indonesia (fokus pencegahan "bocor halus" & pencatatan cepat).

---

## 1. 🎯 App Vision & Core-Loop

- **Core Loop:** Buka app -> Lihat sisa anggaran & ringkasan saldo -> Tap tambah transaksi -> Sinkron ke Firestore -> Dashboard auto-update.
- **Killer Features:** Input transaksi super cepat, _Overspending Alert_ (peringatan anggaran), dan Alokasi Target Tabungan (contoh: UKT Semester 3).

## 2. 🏗️ Tech Stack & Architecture (STRICT RULES)

- **Framework:** Flutter (Dart)
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers)
- **State Management:** Riverpod (Wajib menggunakan Notifier / AsyncNotifier)
- **Backend/Database:** Firebase Firestore
- **Local Storage:** SharedPreferences (Dark Mode & Batas Anggaran Bulanan)

## 3. 🗄️ Database Schema & Data Models

### Collection 1: `transactions`

- `id` (String, Primary Key)
- `amount` (Double)
- `type` (String, enum: 'income', 'expense')
- `category` (String, spesifik: 'Makanan', 'Transportasi', 'Bensin Scoopy', 'Nongkrong')
- `date` (Timestamp)
- `note` (String)

### Collection 2: `savings_goals`

- `id` (String, Primary Key)
- `title` (String, default: 'UKT Semester 3')
- `targetAmount` (Double)
- `currentAmount` (Double)
- `deadline` (Timestamp)

---

## 4. 🚀 Roadmap & Phased Implementation

### FASE 1: Core Dashboard & Input Transaksi

- **Dasbor Saldo (Home Dashboard):**
  - Ringkasan Keuangan (Card Saldo Utama).
  - Bagan Pengeluaran (`fl_chart` PieChart berdasarkan kategori).
  - Status Anggaran (LinearProgressIndicator).
- **Catat Transaksi (Quick Add Form):**
  - Formulir input angka, kategori, tanggal, dan catatan.
  - Validasi form kosong, simpan ke Firestore, lalu _pop_ kembali ke Home.

### FASE 2: Target & Kontrol Anggaran

- **Peringatan Anggaran (Overspending Alert):**
  - Bilah progres berubah warna menjadi **MERAH** jika total pengeluaran bulan berjalan mencapai $\ge 80\%$ dari batas anggaran yang disimpan di SharedPreferences.
- **Target Tabungan (Savings Goals):**
  - List target tabungan dengan indikator progres.
  - Fitur 'Alokasikan Dana': Dialog input nominal untuk memindahkan saldo utama ke `currentAmount` target tabungan.

### FASE 3: Manajemen Riwayat & Sunting

- **Riwayat Transaksi (Transaction History):**
  - Daftar kronologis dikelompokkan per tanggal (terurut _descending_).
  - **Fitur Baru (Edit Transaksi):** Kemampuan menyunting/mengubah data transaksi yang salah catat.
  - **Fitur Hapus:** _Dismissible widget_ (swipe kiri/kanan) dengan dialog konfirmasi sebelum hapus data di Firestore.

### FASE 4: Personalisasi & Pengaturan

- **Pengaturan (Settings):**
  - Toggle Mode Gelap (_Dark Mode_) via SharedPreferences.
  - Menu Atur Batas Anggaran Bulanan (_Monthly Budget Limit_).

---

## 5. 🛑 Non-Negotiable Constraints (JANGAN DILANGGAR)

1. **Dilarang Merubah Arsitektur:** Wajib memisahkan UseCase (Domain), Repository Implementation (Data), dan Controller/Notifier (Presentation).
2. **Error Handling:** Setiap request Firestore WAJIB dibungkus `try-catch`. Tampilkan `SnackBar` untuk status sukses/gagal.
3. **No Dummy Code:** Jangan tinggalkan `// TODO`. Logika kalkulasi saldo, chart, dan alokasi wajib ditulis utuh.
4. **Git Auto-Commit:** Jika kode bebas _error_, jalankan `git add .`, lalu `git commit -m "feat: implement [feature name]"`.

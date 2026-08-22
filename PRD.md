# PRODUCT REQUIREMENTS DOCUMENT (PRD)

**Project Name:** MoneyTracker App
**Platform:** Mobile (Android & iOS)

---

## 1. 🎯 App Vision & Core Value

- **Deskripsi:** Aplikasi ini dirancang untuk mahasiswa dan anak kos untuk menghentikan kebiasaan "bocor halus". Aplikasi mempermudah pencatatan cepat dan memastikan pengguna dapat mencapai target krusial seperti biaya UKT Semester 3.
- **Core Loop:** User membuka aplikasi -> Melihat sisa anggaran (Progress Bar) -> Menekan tombol tambah transaksi -> Data tersinkronisasi ke Firestore & Dashboard ter-update otomatis.
- **Killer Features:** Peringatan otomatis batas anggaran bulanan (Overspending Alert) dan input transaksi super cepat.

## 2. 🏗️ Tech Stack & Architecture (STRICT RULES)

Agen WAJIB mematuhi stack berikut tanpa pengecualian:

- **Framework:** Flutter (Dart)
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers)
- **State Management:** Riverpod (Wajib menggunakan Notifier/AsyncNotifier)
- **Backend/Database:** Firebase Firestore
- **Local Storage:** SharedPreferences (Untuk menyimpan pengaturan Dark Mode dan Batas Anggaran Bulanan)

## 3. 🗄️ Database Schema & Data Models

Berikut adalah struktur data Firestore yang mutlak harus diikuti:

**Collection 1:** `transactions`

- `id` (String, Primary Key)
- `amount` (Double)
- `type` (String, enum: 'income', 'expense')
- `category` (String, misal: 'Makanan', 'Transportasi', 'Nongkrong')
- `date` (Timestamp)
- `note` (String)

**Collection 2:** `savings_goals`

- `id` (String, Primary Key)
- `title` (String, default example: 'UKT Semester 3')
- `targetAmount` (Double)
- `currentAmount` (Double)
- `deadline` (Timestamp)

## 4. 📱 User Flow & UI Requirements

**Screen 1: Home Dashboard**

- **UI Components:** Custom Card untuk Saldo, PieChart (menggunakan fl_chart package) untuk kategori pengeluaran, LinearProgressIndicator untuk batas anggaran.
- **Logic:** Progress indicator harus berubah warna menjadi MERAH jika total pengeluaran bulan ini mencapai 80% dari batas yang disimpan di SharedPreferences.

**Screen 2: Quick Add Form**

- **UI Components:** TextField (Number) untuk jumlah, DropdownButton untuk kategori, DatePicker, TextField untuk catatan, ElevatedButton.
- **Logic:** Validasi input tidak boleh kosong. Setelah tersimpan di Firestore, pop kembali ke Home Dashboard.

**Screen 3: Savings Goals Tracker**

- **UI Components:** ListView dari Card. Setiap Card menampilkan judul (misal: 'UKT Semester 3'), LinearProgressIndicator untuk progres tabungan, teks persentase terkumpul, dan tombol 'Alokasikan Dana'.
- **Logic:** Saat tombol 'Alokasikan Dana' ditekan, munculkan dialog input angka untuk memindahkan nominal dari Saldo Utama ke currentAmount target tersebut. Update data di Firestore.

**Screen 4: Transaction History**

- **UI Components:** ListView.builder yang dikelompokkan berdasarkan tanggal. Gunakan Dismissible widget (fitur swipe kiri/kanan) untuk menghapus.
- **Logic:** Data diurutkan dari yang paling baru (descending). Jika user melakukan swipe untuk menghapus, tampilkan dialog konfirmasi sebelum benar-benar menghapus data dari Firestore.

_(Catatan tambahan untuk Bagian 3 pada field category: jadikan contohnya lebih spesifik seperti 'Makanan', 'Transportasi', 'Bensin Scoopy', 'Nongkrong')_

## 5. 🛑 Non-Negotiable Constraints (JANGAN DILANGGAR)

1. **Dilarang Merubah Arsitektur:** Selalu pisahkan UseCase (Domain) dan Repository Implementation (Data).
2. **Error Handling:** Setiap request ke Firestore WAJIB dibungkus try-catch. Tampilkan SnackBar saat operasi sukses atau gagal.
3. **No Dummy Code:** Jangan tinggalkan `// TODO`. Kerjakan logika kalkulasi saldo dan chart secara utuh.
4. **Git Auto-Commit:** Jika kode bebas error, jalankan `git add .`, `git commit -m "feat: implement [feature name]"`.

INI DAH SESUAI BANGET KAN PRD NYA ? ATAU ADA YANG SALAH ATAU PERLU DIMODIFIKASI AGAR SESUAI ?

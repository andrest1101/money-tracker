# Format Ekspor — Dompetku

Dokumen ini menjelaskan hasil ekspor **CSV Data** dan **Laporan Excel** agar
aplikasi, pengguna, dan reviewer memakai definisi yang sama.

- **Nama aplikasi di file:** `Dompetku` (sumber tunggal: `AppConfig.appName`).
- **Di luar scope:** PDF, impor, backup/restore JSON, dan perubahan skema Firestore.
- **Semua angka** dihitung satu kali di `BuildReportSummary` sebagai rupiah bulat.
  Exporter hanya memformat.

---

## 1. Dua format ekspor

| Format | File | Untuk siapa | Isi |
| --- | --- | --- | --- |
| Laporan Excel | `Dompetku_Laporan_{YYYY-MM-DD}_sd_{YYYY-MM-DD}.xlsx` | Pengguna biasa, dosen, orang tua | 5 sheet: Ringkasan, Transaksi, Per Kategori, Bulanan, Target Tabungan |
| CSV Data | `Dompetku_Transaksi_{YYYY-MM-DD}_sd_{YYYY-MM-DD}.csv` | Pengguna yang ingin mengolah sendiri | Satu tabel datar 9 kolom |

Nama file memakai **rentang tanggal data yang benar-benar diekspor**, bukan
akhir periode yang diminta. Contoh ekspor "Bulan ini" pada 9 November
menghasilkan `..._2026-11-01_sd_2026-11-09.xlsx`.

---

## 2. Definisi angka

| Istilah | Definisi |
| --- | --- |
| **Tipe Tabungan** | Transaksi `expense` dengan kategori `Alokasi Tabungan`. Kategori ini dipakai satu konstanta (`FinanceCategories.savingsAllocation`). |
| **Total Pemasukan** | Σ transaksi `income` di dalam periode. |
| **Pengeluaran** | Σ transaksi `expense` **selain** Tipe Tabungan. |
| **Ditabung** | Σ Tipe Tabungan. |
| **Saldo akhir periode** | Saldo kumulatif sampai akhir periode ekspor. Untuk periode terfilter, dimulai dari saldo sebelum periode. |
| **Selisih bersih** | Pemasukan − Pengeluaran − Ditabung di dalam periode. |
| **Tingkat tabungan** | Ditabung ÷ Pemasukan, satu desimal. |
| **Rata-rata pengeluaran/hari** | Pengeluaran ÷ jumlah hari dalam periode. Untuk all-time, hari dihitung dari transaksi paling awal sampai paling akhir. |
| **Persen kategori** | Total kategori ÷ Pengeluaran (atau ÷ Pemasukan untuk tabel pemasukan). Tipe Tabungan tidak ikut tabel pengeluaran. |
| **Saldo siklus aktif (dashboard)** | Pemasukan − seluruh pengeluaran (termasuk tabungan) dalam siklus anggaran aktif. Sama dengan angka dashboard. |

Zona waktu: Timestamp Firestore dikonversi ke waktu lokal perangkat sebelum
dikelompokkan per tanggal atau bulan. Nominal pecahan dibulatkan sekali di
Domain; exporter tidak membulatkan ulang.

---

## 3. CSV Data (v2)

### Aturan teknis

| Aspek | Keputusan |
| --- | --- |
| Encoding | UTF-8 dengan BOM |
| Pemisah default | `;` (Excel regional Indonesia). Opsi `,` tersedia di dialog |
| Akhir baris | CRLF |
| Urutan | Terlama ke terbaru; nomor `No` selalu 1..n |
| Nominal | Bilangan bulat tanpa `Rp`, tanpa pemisah ribuan, tanpa `.00` |
| Quote | RFC 4180: kutip ganda jika berisi pemisah, kutip, atau baris baru; kutip di dalam isi digandakan |
| Formula injection | Sel teks yang diawali `=`, `+`, `-`, `@`, atau tab diawali `'` |
| Ringkasan | Tidak ada; CSV hanya satu tabel datar |

### Kolom

| # | Kolom | Contoh | Catatan |
| --- | --- | --- | --- |
| 1 | `No` | `1` | Nomor urut, menggantikan ID Firestore |
| 2 | `Tanggal` | `2026-08-29` | ISO `yyyy-MM-dd` |
| 3 | `Jam` | `22:57` | Waktu lokal `HH:mm` |
| 4 | `Tipe` | `Pemasukan` / `Pengeluaran` / `Tabungan` | Bahasa Indonesia |
| 5 | `Kategori` | `Belanja` | Untuk Tabungan: `Alokasi Tabungan` |
| 6 | `Target Tabungan` | `Mouse` | Hanya baris Tabungan; kosong untuk tipe lain; `(Tidak tercatat)` bila tidak cocok |
| 7 | `Nominal` | `20000` | Selalu positif; arah ditentukan `Tipe` |
| 8 | `Catatan` | `Menabung untuk Mouse` | Teks asli pengguna |
| 9 | `Saldo Berjalan` | `10723000` | Saldo setelah transaksi. Untuk ekspor terfilter, mulai dari saldo sebelum periode |

ID Firestore sengaja tidak diekspor. ID 16 digit akan rusak di Excel dan tidak
berguna bagi pengguna.

---

## 4. Laporan Excel (.xlsx)

### Gaya umum

- Font Calibri 11. Header tabel tebal dengan fill brand `#315B7D` dan teks putih.
- Nominal `"Rp" #,##0` sebagai sel angka; persen `0.0%`; tanggal `dd mmm yyyy`.
- Sheet Transaksi dibekukan pada baris header dan diberi filter otomatis.
- Sheet Ringkasan di-setup A4 portrait dengan `fitToPage`.
- Nama sheet maksimal 31 karakter; semua sheet selesai dalam 5 sheet.

### Sheet 1 — Ringkasan

Berisi nama aplikasi, judul Laporan Keuangan, periode, dan waktu ekspor.
KPIs: saldo akhir periode, total pemasukan, pengeluaran, ditabung, selisih
bersih, tingkat tabungan. Aktivitas: jumlah transaksi, hari dalam periode,
hari dengan catatan, rata-rata pengeluaran/hari. Sorotan: kategori pengeluaran
terbesar dan transaksi pengeluaran terbesar. Insight: kalimat deterministik
dari Domain (maksimal 6).

Laporan juga menampilkan **Saldo siklus aktif (dashboard)** agar pengguna bisa
membandingkan dengan dashboard. Angka ini tidak sama dengan saldo akhir periode
untuk ekspor historis.

### Sheet 2 — Transaksi

Kolom: `No · Tanggal · Jam · Tipe · Kategori · Target Tabungan · Pemasukan ·
Pengeluaran · Ditabung · Catatan · Saldo Berjalan`.

Hanya satu dari tiga kolom nominal terisi per baris. `Pemasukan` berwarna hijau.
Tanggal tersimpan sebagai sel tanggal; Jam sebagai teks lokal. Sheet ini
memiliki freeze pane dan filter otomatis.

### Sheet 3 — Per Kategori

Tabel Pengeluaran (tanpa Tipe Tabungan): kategori, jumlah transaksi, total,
% dari pengeluaran, rata-rata/transaksi; urut dari terbesar. Baris Total di
bawah. Di bawah tabel tampil `Ditabung (dipisah dari pengeluaran): Rp ...`.

Tabel Pemasukan: kategori, jumlah transaksi, total, % dari pemasukan,
rata-rata/transaksi.

### Sheet 4 — Bulanan

`Bulan · Pemasukan · Pengeluaran · Ditabung · Selisih · Tingkat tabungan`.
Bulan tanpa transaksi tetap tampil dengan nilai 0. Baris Total di bawah.
Label bulan selalu memuat tahun sehingga periode lintas tahun tetap jelas.

### Sheet 5 — Target Tabungan

`Target · Terkumpul (saat ini) · Target nominal · Progres · Deadline · Sisa hari
· Status · Alokasi di periode`.

- Status: `Aktif` / `Selesai` / `Diarsipkan`.
- `Terkumpul (saat ini)` memakai progress goal pada saat laporan dibuat, bukan
  snapshot akhir periode historis.
- `Alokasi di periode` menjumlahkan alokasi yang masuk ke goal di dalam periode
  ekspor.
- Jika ada alokasi tabungan yang tidak cocok ke target, tampil catatan
  `Alokasi tanpa nama target: N transaksi · Rp ...`.

---

## 5. Matching target tabungan

1. Utamakan `goalId` yang tersimpan pada transaksi.
2. Untuk data lama tanpa `goalId`, catatan dicocokkan dengan judul target
   secara case-insensitive dan trim, dengan atau tanpa awalan `Menabung untuk`.
3. Jika tetap tidak cocok, target tampil `(Tidak tercatat)` dan totalnya
   dihitung sebagai alokasi tanpa nama target.

Goal yang sudah dihapus tidak muncul di sheet Target Tabungan; alokasi lama
tetap tampil sebagai `(Tidak tercatat)`.

---

## 6. Catatan dependency

- `excel_community 1.0.10` dipakai karena semua `excel_community >= 2.0.0`
  membutuhkan `xml 7`, yang membutuhkan Dart SDK `>=3.11.0`. Proyek ini memakai
  Dart `3.8.1`.
- `excel_community 1.0.10` tidak menyediakan freeze pane/filter secara native.
  Keduanya ditulis ke XML worksheet oleh `XlsxPostprocessor` sebelum file
  dibagikan. `archive 4.2.0` ditambahkan sebagai dependency langsung untuk itu.
- Jika Flutter/Dart diperbarui ke Dart `>=3.11.0`, evaluasi ulang
  `excel_community 2.x` dan hapus post-processor bila fitur sudah tersedia.

---

## 7. Batasan yang disengaja

- CSV tidak memuat blok ringkasan; gunakan Laporan Excel untuk analisis siap
  pakai.
- Laporan Excel belum memuat grafik. Formula juga tidak dipakai; semua sel
  berisi nilai sehingga file aman dibuka di berbagai versi Excel/Sheets.
- PDF dengan grafik, impor, dan backup/restore JSON masih di luar scope.
- Filter otomatis dan freeze pane hanya pada sheet Transaksi.
- Isolate belum diaktifkan; data realistis (43–2.000 baris) masih sinkron.
  Exporter ditulis sebagai fungsi Dart murni agar bisa dipindah ke isolate
  tanpa mengubah logika bila profiling menunjukkan kebutuhan.

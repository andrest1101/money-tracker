# PRD Addendum — Fase 6: Ekspor Data & Laporan

**Berlaku untuk:** aplikasi pencatat keuangan (Flutter, Clean Architecture, Riverpod, Firestore)
**Status:** Fase 6 adalah satu-satunya pekerjaan aktif untuk fitur ini. Dokumen ini menambah PRD utama, tidak menggantikannya.

> **Instruksi untuk AI agent**
>
> 1. Baca dokumen ini sampai habis sebelum menyentuh kode.
> 2. Mulai dari **Batch 0 (Audit)**. Jangan langsung menulis exporter.
> 3. Jangan ubah Firestore schema, model data, atau logika dashboard yang sudah ada.
> 4. Satu batch, satu commit, laporkan, lalu berhenti sampai diminta lanjut.
> 5. Nama aplikasi bisa berubah. Ambil dari satu konstanta (`AppConfig.appName`), jangan di-hardcode.

## Daftar Isi

1. [Temuan dari Ekspor Saat Ini](#1-temuan-dari-ekspor-saat-ini)
2. [Tujuan & Scope](#2-tujuan--scope)
3. [Keputusan Format](#3-keputusan-format)
4. [Definisi Angka](#4-definisi-angka-single-source-of-truth)
5. [Spesifikasi CSV v2](#5-spesifikasi-csv-v2-data-mentah)
6. [Spesifikasi Laporan XLSX](#6-spesifikasi-laporan-xlsx)
7. [Aturan Insight Otomatis](#7-aturan-insight-otomatis)
8. [UI Ekspor](#8-ui-ekspor)
9. [Edge Case & Keamanan](#9-edge-case--keamanan)
10. [Arsitektur & File](#10-arsitektur--file)
11. [Rencana Batch](#11-rencana-batch)
12. [Data Uji & Nilai Harapan](#12-data-uji--nilai-harapan)
13. [Pertanyaan untuk Audit](#13-pertanyaan-untuk-audit)
14. [Di Luar Scope](#14-di-luar-scope-butuh-persetujuan)

---

## 1. Temuan dari Ekspor Saat Ini

Dianalisis dari satu file ekspor nyata (43 baris, kolom `ID, Tanggal, Tipe, Kategori, Nominal, Catatan`, UTF-8 dengan BOM).

| #   | Temuan                                                                                                                                       | Dampak                                                                                                                                                                       |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `ID` berupa angka 16 digit (contoh `1794147328405736`)                                                                                       | Excel hanya menyimpan 15 digit: tampil `1,79415E+15` dan digit terakhir hilang                                                                                               |
| 2   | Pemisah koma dan nominal `20000.00`                                                                                                          | Di Excel dengan regional Indonesia, pemisah daftar biasanya titik koma dan titik adalah pemisah ribuan. File bisa terbuka dalam satu kolom atau nominal terbaca sebagai teks |
| 3   | Tanggal `2026-11-08T21:15:28.405736`                                                                                                         | Format teknis dengan mikrodetik, tidak enak dibaca dan tidak selalu dikenali sebagai tanggal                                                                                 |
| 4   | `Tipe` berisi `expense` / `income`                                                                                                           | Bahasa Inggris, sedangkan kolom lain Bahasa Indonesia                                                                                                                        |
| 5   | **25 dari 38 baris pengeluaran adalah `Alokasi Tabungan`** (Rp 2.215.000 dari Rp 4.217.000, 52,5%)                                           | Menabung tercatat sebagai pengeluaran, sehingga "kategori terbesar" dan total pengeluaran menyesatkan. Belanja riil hanya Rp 2.002.000                                       |
| 6   | Nama target tabungan hanya ada di `Catatan` bebas, dengan huruf besar/kecil berbeda (`mouse` dan `Mouse`), dan 3 alokasi tidak punya catatan | Tidak bisa dikelompokkan per target secara andal                                                                                                                             |
| 7   | Tidak ada ringkasan apa pun, urutan terbaru di atas, nama file acak                                                                          | Sulit dibaca manusia, tidak bisa dipakai untuk saldo berjalan                                                                                                                |

## 2. Tujuan & Scope

**Tujuan:** hasil ekspor rapi, jelas, dan langsung berguna: saldo saat ini, pengeluaran per kategori, ringkasan bulanan, progres target tabungan, dan insight, tanpa pengguna perlu mengolahnya sendiri.

**Di dalam scope:** exporter CSV v2, exporter laporan XLSX, use case penghitung ringkasan (Domain), UI ekspor sederhana, unit test.

**Di luar scope:** perubahan skema Firestore, fitur impor, backup/restore, PDF (lihat bagian 14).

## 3. Keputusan Format

CSV adalah satu tabel datar. Tidak bisa punya beberapa sheet, lebar kolom, warna, atau blok ringkasan yang terpisah dari data. Menjejalkan ringkasan di atas data CSV merusak pembacaan di Excel, Google Sheets, dan pandas.

| Ekspor                    | Untuk siapa                                                | Isi                                                                   |
| ------------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------- |
| **CSV Data**              | Pengguna yang mau mengolah sendiri (Excel, Sheets, Python) | Hanya transaksi, bersih, satu tabel                                   |
| **Laporan Excel (.xlsx)** | Pengguna biasa, dosen, orang tua                           | 5 sheet: Ringkasan, Transaksi, Per Kategori, Bulanan, Target Tabungan |

## 4. Definisi Angka (single source of truth)

Semua angka dihitung **satu kali** di Domain, dalam use case `BuildReportSummary` (Dart murni, tanpa Flutter), lalu dipakai oleh kedua exporter. Dilarang menghitung ulang di exporter.

| Istilah                        | Definisi                                                                                                                                                           |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Tipe Tabungan**              | Transaksi `expense` dengan kategori `Alokasi Tabungan`. Gunakan satu konstanta yang sama dengan kode alokasi dana, bukan string baru                               |
| **Total Pemasukan**            | Σ transaksi `income`                                                                                                                                               |
| **Pengeluaran**                | Σ transaksi `expense` **selain** Tipe Tabungan                                                                                                                     |
| **Ditabung**                   | Σ Tipe Tabungan                                                                                                                                                    |
| **Saldo saat ini**             | Pemasukan − Pengeluaran − Ditabung. **Harus sama persis dengan angka di dashboard.** Jika rumus dashboard berbeda, dashboard yang benar: catat selisihnya di audit |
| **Selisih bersih**             | Pemasukan − Pengeluaran − Ditabung (periode terpilih)                                                                                                              |
| **Tingkat tabungan**           | Ditabung ÷ Pemasukan, satu desimal                                                                                                                                 |
| **Rata-rata pengeluaran/hari** | Pengeluaran ÷ jumlah hari dalam periode (bukan jumlah hari yang punya catatan)                                                                                     |
| **Persen kategori**            | Total kategori ÷ Pengeluaran (Tipe Tabungan tidak ikut)                                                                                                            |

Zona waktu: konversi `Timestamp` ke waktu lokal perangkat sebelum dikelompokkan per tanggal atau bulan.

## 5. Spesifikasi CSV v2 (data mentah)

**Nama file:** `{AppName}_Transaksi_{YYYY-MM-DD}_sd_{YYYY-MM-DD}.csv`

**Aturan teknis**

| Aspek       | Keputusan                                                                           | Alasan                                                                    |
| ----------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Encoding    | UTF-8 dengan BOM                                                                    | Excel membaca karakter dengan benar                                       |
| Pemisah     | `;` (default)                                                                       | Cocok dengan Excel regional Indonesia. Sediakan opsi `,` di dialog ekspor |
| Akhir baris | CRLF                                                                                | Standar RFC 4180                                                          |
| Urutan      | **Terlama ke terbaru**                                                              | Wajib agar Saldo Berjalan masuk akal                                      |
| Nominal     | Bilangan bulat tanpa `Rp`, tanpa pemisah ribuan, tanpa `.00`                        | Menghindari konflik pemisah desimal                                       |
| Kutip       | Kutip ganda jika ada pemisah, kutip, atau baris baru; kutip di dalam isi digandakan | RFC 4180                                                                  |

**Kolom**

| #   | Kolom             | Contoh                                   | Catatan                                                                                                                                                |
| --- | ----------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | `No`              | `1`                                      | Nomor urut 1..n dari terlama. **Menggantikan ID panjang**                                                                                              |
| 2   | `Tanggal`         | `2026-08-29`                             | ISO `yyyy-MM-dd`, dikenali semua locale                                                                                                                |
| 3   | `Jam`             | `22:57`                                  | `HH:mm`, waktu lokal                                                                                                                                   |
| 4   | `Tipe`            | `Pemasukan` / `Pengeluaran` / `Tabungan` | Bahasa Indonesia                                                                                                                                       |
| 5   | `Kategori`        | `Belanja`                                | Untuk Tabungan: `Alokasi Tabungan`                                                                                                                     |
| 6   | `Target Tabungan` | `Mouse`                                  | Hanya baris Tabungan. Cocokkan `Catatan` dengan judul target secara case-insensitive dan trim. Tidak cocok: `(Tidak tercatat)`. Kosong untuk tipe lain |
| 7   | `Nominal`         | `20000`                                  | Selalu positif, arah ditentukan `Tipe`                                                                                                                 |
| 8   | `Catatan`         | `Menabung untuk Mouse`                   | Teks asli pengguna                                                                                                                                     |
| 9   | `Saldo Berjalan`  | `10723000`                               | Saldo setelah transaksi tersebut. Untuk ekspor periode tertentu, mulai dari saldo sebelum periode                                                      |

**`ID` Firestore sengaja tidak diekspor.** Angka 16 digit akan rusak di Excel dan tidak berguna bagi pengguna.

## 6. Spesifikasi Laporan XLSX

**Nama file:** `{AppName}_Laporan_{YYYY-MM-DD}_sd_{YYYY-MM-DD}.xlsx`

**Gaya umum**

- Font Calibri 11. Header tabel tebal dengan fill warna brand aplikasi dan teks putih.
- Nominal berformat `"Rp" #,##0` (sel tetap angka, bukan teks). Persen berformat `0.0%`. Tanggal berformat `dd mmm yyyy`.
- Lebar kolom disesuaikan isi. Header dibekukan (freeze) dan diberi filter otomatis pada sheet Transaksi.
- Nama sheet maksimal 31 karakter, tanpa karakter khusus.

### Sheet 1 — `Ringkasan`

Layout satu halaman yang bisa dicetak (A4, portrait).

| Blok        | Isi                                                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------------------------------- |
| Judul       | Nama app, "Laporan Keuangan", periode, tanggal ekspor                                                               |
| Angka utama | Saldo saat ini · Total pemasukan · Pengeluaran · Ditabung · Selisih bersih · Tingkat tabungan                       |
| Aktivitas   | Jumlah transaksi · Jumlah hari dalam periode · Rata-rata pengeluaran/hari                                           |
| Sorotan     | Kategori pengeluaran terbesar (nama, nominal, persen) · Transaksi pengeluaran terbesar (tanggal, kategori, nominal) |
| Insight     | 3–6 kalimat dari bagian 7                                                                                           |

### Sheet 2 — `Transaksi`

Kolom sama dengan CSV v2, tetapi dengan dua kolom nominal terpisah agar mudah dibaca manusia:
`No · Tanggal · Jam · Tipe · Kategori · Target Tabungan · Pemasukan · Pengeluaran · Ditabung · Catatan · Saldo Berjalan`.
Hanya satu dari tiga kolom nominal yang terisi per baris. Pemasukan berfont hijau.

### Sheet 3 — `Per Kategori`

| Tabel       | Kolom                                                                                                                        |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Pengeluaran | Kategori · Jumlah transaksi · Total · % dari pengeluaran · Rata-rata per transaksi. Urut dari terbesar. Baris Total di bawah |
| Pemasukan   | Kategori · Jumlah transaksi · Total · % dari pemasukan                                                                       |

Tabungan **tidak** masuk tabel Pengeluaran. Tampilkan sebagai satu baris terpisah di bawah: "Ditabung (dipisah dari pengeluaran)".

### Sheet 4 — `Bulanan`

`Bulan · Pemasukan · Pengeluaran · Ditabung · Selisih · Tingkat tabungan`. Bulan tanpa transaksi **tetap tampil** dengan nilai 0. Baris Total di bawah.

### Sheet 5 — `Target Tabungan`

| Kolom                | Sumber                                              |
| -------------------- | --------------------------------------------------- |
| Target               | `savings_goals.title`                               |
| Terkumpul            | `currentAmount`                                     |
| Target nominal       | `targetAmount`                                      |
| Progres              | Terkumpul ÷ Target nominal                          |
| Deadline · Sisa hari | `deadline`                                          |
| Status               | Aktif / Selesai / Diarsipkan (sesuai status di app) |

Di bawah tabel, tampilkan baris "Alokasi tanpa nama target: N transaksi, Rp X" bila ada.

## 7. Aturan Insight Otomatis

Insight dibuat dengan **aturan deterministik di Domain** (bukan AI, bukan jaringan), Bahasa Indonesia, sapaan "kamu", dan diuji dengan unit test. Tampilkan hanya yang kondisinya terpenuhi.

| #   | Kondisi                                                    | Template                                                                             |
| --- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| 1   | Pemasukan > 0                                              | "Kamu menabung {X}% dari pemasukan periode ini."                                     |
| 2   | Ada pengeluaran                                            | "Pengeluaran terbesarmu ada di {kategori}: {nominal} ({persen}% dari pengeluaran)."  |
| 3   | Pengeluaran > 0                                            | "Rata-rata kamu mengeluarkan {nominal} per hari."                                    |
| 4   | Ada bulan dengan 0 transaksi di dalam periode              | "Tidak ada catatan di {bulan}. Pencatatan yang rutin bikin angka ini lebih akurat."  |
| 5   | Ada Tabungan tanpa nama target                             | "{N} alokasi tabungan belum punya nama target, jadi tidak bisa dihitung per target." |
| 6   | Batas anggaran diatur dan pengeluaran bulan berjalan ≥ 80% | "Pengeluaran bulan ini sudah {persen}% dari batas anggaranmu."                       |

## 8. UI Ekspor

Minimal dan fungsional. Gunakan komponen dan tema yang sudah ada. Restyle penuh menyusul setelah UI refactor selesai.

- Satu tombol "Ekspor data" di tempat ekspor sekarang, membuka **bottom sheet**.
- Isi sheet: pilihan **Format** (Laporan Excel / CSV Data), pilihan **Periode** (Semua · Bulan ini · Siklus anggaran aktif · Pilih tanggal), opsi **Pemisah CSV** (`;` / `,`, hanya tampil jika CSV), tombol utama **Bagikan**.
- Tampilkan ringkasan kecil sebelum ekspor: "43 transaksi · 29 Agu 2026 – 8 Nov 2026".
- Proses di `compute` (isolate) jika transaksi > 2.000 baris. Tampilkan indikator loading.
- Berhasil: buka share sheet sistem (`share_plus`). Gagal: `SnackBar` dengan pesan yang bisa dipahami.
- Tidak ada transaksi pada periode: tombol Bagikan nonaktif dengan keterangan "Belum ada transaksi di periode ini".

## 9. Edge Case & Keamanan

| Kasus                                                    | Perilaku                                                                                  |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Catatan berisi `;` `,` `"` atau baris baru               | Di-quote sesuai RFC 4180                                                                  |
| Catatan/Kategori/Target diawali `=` `+` `-` `@` atau tab | Awali dengan `'` untuk mencegah formula injection saat dibuka di Excel                    |
| Emoji atau karakter non-Latin                            | Tetap utuh (UTF-8)                                                                        |
| Hanya ada pemasukan, atau hanya satu transaksi           | Semua sheet tetap terbentuk, tanpa pembagian dengan nol                                   |
| Periode lintas tahun                                     | Sheet Bulanan menampilkan bulan dan tahun                                                 |
| Pengguna tamu (guest)                                    | Tetap bisa ekspor                                                                         |
| Nominal pecahan                                          | Bulatkan ke rupiah penuh dan catat di README fitur                                        |
| File sementara                                           | Tulis ke direktori sementara, hapus setelah dibagikan. Jangan simpan isi transaksi di log |

## 10. Arsitektur & File

Ikuti Clean Architecture yang ada. Presentation tidak boleh berisi logika perhitungan.

```
lib/features/export/
├── domain/
│   ├── entities/report_summary.dart        # semua angka, insight, baris per kategori/bulan
│   └── usecases/build_report_summary.dart  # Dart murni, 100% unit-tested
├── data/
│   ├── exporters/csv_exporter.dart
│   ├── exporters/xlsx_exporter.dart
│   └── repositories/export_repository_impl.dart
└── presentation/
    ├── providers/export_notifier.dart
    └── widgets/export_sheet.dart
```

**Paket XLSX:** kandidat `excel` (pure Dart). Verifikasi lisensi dan dukungan fitur di pub.dev: gaya sel, format angka, lebar kolom, freeze, filter, merge. Jika ada fitur yang tidak didukung, pakai alternatif sederhana dan catat di `progress.md`. **Jangan pakai paket dengan lisensi komersial tanpa persetujuan.** Grafik tidak wajib di XLSX.

## 11. Rencana Batch

Branch `feature/export-v2`. Tiap batch: `flutter analyze` bersih, `flutter test` lolos, commit `feat(export): <ringkasan>`. Jangan merge ke `main`.

| Batch | Isi                                                                                                                                                               | Kriteria selesai                                          |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 0     | **Audit.** Tulis `docs/export-audit.md`: lokasi kode ekspor sekarang, rumus saldo di dashboard, cara alokasi tabungan dicatat, jawaban bagian 13. Tanpa ubah kode | Dokumen ada                                               |
| 1     | `ReportSummary` + `BuildReportSummary` + unit test memakai data uji bagian 12                                                                                     | Semua nilai harapan cocok                                 |
| 2     | `CsvExporter` v2                                                                                                                                                  | Test: kolom, urutan, quoting, injection, BOM, `;` dan `,` |
| 3     | `XlsxExporter` 5 sheet                                                                                                                                            | Test baca-ulang file: jumlah sheet, header, nilai kunci   |
| 4     | UI ekspor + share                                                                                                                                                 | Ekspor jalan di perangkat nyata                           |
| 5     | Polish, dokumentasi di README, hapus kode ekspor lama                                                                                                             | Checklist di bawah hijau                                  |

**Checklist akhir (manual, oleh pemilik app)**

- [ ] CSV terbuka rapi di Excel (regional Indonesia) dan Google Sheets, tanpa kolom bergeser.
- [ ] Tidak ada angka berformat ilmiah.
- [ ] Saldo di laporan sama dengan saldo dashboard.
- [ ] Laporan Excel terbaca jelas saat dicetak (sheet Ringkasan satu halaman).
- [ ] Kategori terbesar di laporan bukan "Alokasi Tabungan".

## 12. Data Uji & Nilai Harapan

Simpan file ekspor lama (43 baris) sebagai `test/fixtures/export_sample_v1.csv`. Fixture ini dipakai untuk membuat daftar transaksi uji di unit test. Nilai harapan untuk periode penuh:

| Metrik                        | Nilai                             |
| ----------------------------- | --------------------------------- |
| Jumlah transaksi              | 43                                |
| Periode                       | 2026-08-29 s.d. 2026-11-08        |
| Hari yang punya catatan       | 10                                |
| Total pemasukan               | Rp 12.725.000                     |
| Pengeluaran (tanpa tabungan)  | Rp 2.002.000 (13 transaksi)       |
| Ditabung                      | Rp 2.215.000 (25 transaksi)       |
| Saldo saat ini                | Rp 8.508.000                      |
| Tingkat tabungan              | 17,4%                             |
| Kategori pengeluaran terbesar | Belanja, Rp 730.000 (36,5%)       |
| Kategori kedua                | Kos & Tagihan, Rp 700.000 (35,0%) |
| Alokasi tanpa nama target     | 3 transaksi                       |
| Bulan tanpa transaksi         | Oktober 2026                      |
| Baris Bulanan                 | Agu, Sep, Okt (semua 0), Nov 2026 |

## 13. Pertanyaan untuk Audit

Jawab di `docs/export-audit.md` sebelum Batch 1:

1. Di mana kode ekspor CSV sekarang dan paket apa yang dipakai?
2. Bagaimana dashboard menghitung "Saldo saat ini" dan "Pengeluaran"? Apakah Alokasi Tabungan ikut dihitung sebagai pengeluaran?
3. Bagaimana transaksi alokasi dibuat? Apakah ada penanda selain kategori dan catatan?
4. Apakah `share_plus` dan `path_provider` sudah ada di `pubspec.yaml`?
5. Berapa banyak transaksi per pengguna yang realistis, dan apakah perlu isolate?

## 14. Di Luar Scope (butuh persetujuan)

- **Simpan `goalId` pada transaksi alokasi.** Ini akar masalah temuan #6 dan mengubah skema. Untuk data lama tetap pakai pencocokan catatan.
- **Ekspor PDF** dengan grafik (kandidat paket `pdf`).
- **Backup/restore JSON** yang membawa ID asli.

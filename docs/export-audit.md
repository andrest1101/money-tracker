# Export Audit — Savu Fase 6

> **Batch 0** dari PRD Addendum Fase 6 (Ekspor Data & Laporan).
> Dokumen ini adalah inventaris kondisi kode **sebelum** fitur ekspor v2 dibuat.
> Tidak ada kode fitur yang diubah pada batch ini.

- **Tanggal audit:** 2026-11-09
- **Branch:** `feature/export-v2`
- **Basis:** `refactor/ui-v2` (working tree bersih selain `PRD_ekspor_CSV.md`)
- **Baseline `flutter analyze`:** bersih, tanpa issue.
- **Baseline `flutter test`:** 137/137 lulus.
- **Nama aplikasi untuk ekspor:** `Savu` (diputuskan bersama pemilik aplikasi).

---

## 1. Ringkasan Eksekutif

Ekspor saat ini hanya meneruskan data mentah Firestore ke CSV. Hasilnya benar
secara teknis, tetapi tidak nyaman dipakai:

- `ID` Firestore 16 digit akan berubah menjadi notasi ilmiah di Excel.
- Pemisah koma dan nominal `20000.00` bentrok dengan regional Indonesia.
- Tanggal memakai ISO lengkap dengan mikrodetik.
- Tipe masih `income` / `expense`.
- Tidak ada pemisahan antara belanja riil dan alokasi tabungan.
- Tidak ada ringkasan, kategori, bulanan, atau progress target.

PRD Fase 6 sudah sesuai dengan masalah nyata tersebut. Beberapa detail perlu
disesuaikan dengan kondisi kode saat ini; daftarnya ada di bagian 8.

Temuan terpenting: **`goalId` sudah tersimpan pada transaksi alokasi**. PRD
menyebut penyimpanan `goalId` sebagai pekerjaan di luar scope, padahal kode
sekarang sudah memiliki `TransactionEntity.goalId` dan
`TransactionModel.toMap()` menuliskannya ke Firestore. Artinya matching target
tabungan bisa akurat tanpa perubahan skema.

---

## 2. Inventaris Ekspor Saat Ini

| Komponen | Lokasi | Perilaku |
| --- | --- | --- |
| Exporter CSV | `lib/features/transactions/domain/usecases/generate_transactions_csv_usecase.dart` | Header `ID, Tanggal, Tipe, Kategori, Nominal, Catatan`; tanggal ISO; tipe Inggris; nominal `toStringAsFixed(2)`; pemisah `,`; BOM; CRLF |
| Controller share | `lib/features/transactions/presentation/providers/transaction_export_controller.dart` | Membuat `XFile.fromData`, nama `moneytracker-transaksi.csv`, MIME `text/csv`, subjek `Ekspor transaksi Dompetku` |
| UI masuk | `lib/features/settings/presentation/widgets/settings_data_section.dart` | Tile “Ekspor Data ke CSV” langsung memanggil controller; tidak ada dialog format/periode |
| Test lama | `test/generate_transactions_csv_usecase_test.dart` | Mengunci format v1; akan diganti |
| Fixture | `test/fixtures/` | Belum ada |

Kode ekspor lama berada di feature `transactions`, bukan feature tersendiri.
PRD meminta pemisahan ke `lib/features/export/`; rencana refactor mengikuti
struktur tersebut.

---

## 3. Rumus Dashboard Saat Ini

### 3.1 Sumber data

- `transactionsStreamProvider` membaca `watchTransactions()` dari Firestore.
- Repository mengurutkan `date descending` (terbaru di atas).
- `TransactionEntity.amount` bertipe `double`.

### 3.2 Ringkasan bulanan/siklus

`monthlySummaryProvider`:

1. Menghitung siklus anggaran aktif dengan `CalculateBudgetCyclePeriodUseCase`
   memakai `budgetCycleDateProvider` dan `DateTime.now()`.
2. Memanggil `CalculateMonthlySummaryUseCase` dengan `periodStart` siklus dan
   `periodEnd` akhir hari siklus.
3. Use case menjumlahkan:
   - `totalIncome` = semua transaksi `income` dalam periode.
   - `totalExpense` = semua transaksi `expense` dalam periode, **termasuk**
     `Alokasi Tabungan`.
4. `MonthlySummaryEntity.balance = totalIncome - totalExpense`.

Jadi angka “Saldo saat ini” di dashboard adalah **saldo siklus anggaran aktif**,
bukan saldo kumulatif seluruh riwayat. Rumusnya secara numerik sama dengan
`Pemasukan − Pengeluaran − Ditabung` PRD, tetapi cakupan periodenya berbeda.

### 3.3 Konsekuensi untuk ekspor

- Untuk periode “Siklus anggaran aktif”, angka dashboard bisa direproduksi
  persis.
- Untuk “Semua waktu”, “Bulan ini”, atau rentang kustom, saldo kumulatif tidak
  akan sama dengan dashboard.
- Solusi yang dipakai: tampilkan **dua metrik terpisah** di laporan:
  - `Saldo akhir periode` — kumulatif sampai akhir periode ekspor.
  - `Saldo siklus aktif (dashboard)` — angka dashboard beserta rentang siklusnya.
- CSV hanya memuat `Saldo Berjalan` kumulatif, karena CSV adalah data mentah
  satu tabel.

---

## 4. Cara Alokasi Tabungan Dicatat

Alur di `SavingsActionsController.allocateToGoal`
(`lib/features/savings/presentation/providers/savings_providers.dart`):

```dart
final transaction = TransactionEntity(
  id: DateTime.now().microsecondsSinceEpoch.toString(),
  amount: amount,
  type: TransactionType.expense,
  category: 'Alokasi Tabungan',
  date: DateTime.now(),
  note: 'Menabung untuk ${goal.title}',
  goalId: goal.id,
);
```

Fakta penting:

- Tipe transaksi tetap `expense`, sehingga ikut terhitung sebagai pengeluaran
  di dashboard.
- Kategori selalu `'Alokasi Tabungan'`.
- `goalId` tersimpan di `TransactionEntity` dan `TransactionModel.toMap()`.
- `TransactionEntity.isAllocation` bernilai `goalId != null`.
- `goalId` dibaca kembali di `TransactionModel.fromMap()`.

Implikasi untuk ekspor:

1. Pemisahan tabungan dari belanja memakai kategori
   `'Alokasi Tabungan'` (bukan tipe transaksi baru).
2. Matching target memakai `goalId` terlebih dahulu.
3. Data lama tanpa `goalId` memakai fallback catatan
   `Menabung untuk {judul}` secara case-insensitive dan trim.
4. Jika target sudah dihapus atau catatan tidak cocok, gunakan
   `(Tidak tercatat)`.

---

## 5. Dependency dan Paket XLSX

### 5.1 Kondisi `pubspec.yaml`

| Paket | Status |
| --- | --- |
| `share_plus: ^11.0.0` | Ada |
| `path_provider` | Tidak ada |
| `excel` / `excel_community` / `xlsxwriter` | Tidak ada |
| `archive` (transitif) | `4.2.0` di `pubspec.lock` |

### 5.2 Konflik `excel`

`excel 4.0.6` membutuhkan `archive ^3.6.1`, sedangkan lock aplikasi memakai
`archive 4.2.0`. Menambahkan `excel` berisiko memaksa downgrade `archive` dan
mengganggu paket lain.

### 5.3 Hasil verifikasi: `excel_community 1.0.10`

Versi 2.6.2 tidak dapat dipakai pada SDK proyek saat ini:

- Semua `excel_community >= 2.0.0` membutuhkan `xml ^7.0.1` atau
  `xml >=7.0.0`.
- `xml 7` membutuhkan Dart SDK `>=3.11.0`.
- Flutter proyek ini memakai Dart `3.8.1` (`sdk: ^3.8.1`), sehingga resolver
  menolak versi 2.x.

Versi yang tersedia dan kompatibel:

- `excel_community 1.0.10` — MIT, pure Dart.
- Requirement `archive >=4.0.9 <=5.0.0` — cocok dengan `archive 4.2.0`.
- Requirement `xml ^6.6.1` — kompatibel dengan Dart 3.8.1.
- Membaca dan menulis XLSX, style, number format, merge cell, dan chart.

Keterbatasan yang ditemukan saat verifikasi:

- `excel_community 1.0.10` **tidak menyediakan freeze pane atau autofilter**.
- Print setup / A4 portrait juga tidak tersedia sebagai API.

Penanganan:

- `XlsxPostprocessor` menambahkan `<pane>` freeze row dan `<autoFilter>` untuk
  sheet Transaksi, serta `pageSetup` A4 portrait untuk sheet Ringkasan,
  langsung pada XML worksheet sebelum file dibagikan.
- `archive 4.2.0` ditambahkan sebagai dependency langsung untuk proses
  post-processing tersebut.
- Tidak memakai paket berlisensi komersial.
- Jika nanti Flutter/Dart diperbarui ke Dart >=3.11, evaluasi ulang
  `excel_community 2.x` dan hapus post-processor bila fitur sudah tersedia.

---

## 6. Volume Data dan Isolate

Data contoh PRD berisi 43 transaksi. Aplikasi ini menargetkan mahasiswa dan
young adult, sehingga volume realistis umumnya ratusan sampai beberapa ribu
baris.

Keputusan:

- Implementasi awal sinkron karena 43–2.000 baris masih sangat kecil.
- Exporter tetap ditulis sebagai fungsi Dart murni agar bisa dipindahkan ke
  isolate tanpa mengubah logika.
- Threshold `compute` (2.000 baris) diterapkan pada Batch 5 hanya jika
  pengukuran menunjukkan durasi yang layak diisolasi.
- Jangan memindahkan pembuatan widget atau akses `BuildContext` ke isolate.

---

## 7. Jawaban Pertanyaan Audit (PRD Bagian 13)

1. **Di mana kode ekspor CSV sekarang dan paket apa yang dipakai?**
   - Di `lib/features/transactions/domain/usecases/generate_transactions_csv_usecase.dart`.
   - Tidak memakai paket CSV eksternal; escaping ditulis manual.
   - Share memakai `share_plus`.

2. **Bagaimana dashboard menghitung “Saldo saat ini” dan “Pengeluaran”?
   Apakah Alokasi Tabungan ikut dihitung?**
   - Saldo = `totalIncome - totalExpense` dalam siklus anggaran aktif.
   - Pengeluaran = semua transaksi `expense` dalam siklus, termasuk
     `Alokasi Tabungan`.
   - Ya, alokasi tabungan ikut dihitung sebagai pengeluaran dashboard.

3. **Bagaimana transaksi alokasi dibuat? Apakah ada penanda selain kategori
   dan catatan?**
   - Dibuat di `SavingsActionsController.allocateToGoal`.
   - Penanda: kategori `'Alokasi Tabungan'`, catatan `Menabung untuk {title}`,
     dan **`goalId`**.
   - `goalId` sudah menjadi penanda utama yang akurat.

4. **Apakah `share_plus` dan `path_provider` sudah ada di `pubspec.yaml`?**
   - `share_plus` ada.
   - `path_provider` tidak ada.
   - Rencana: tetap memakai `XFile.fromData`; `path_provider` hanya ditambahkan
     jika tes perangkat nyata menunjukkan masalah nama file/MIME.

5. **Berapa banyak transaksi per pengguna yang realistis, dan apakah perlu
   isolate?**
   - Realistis: ratusan sampai beberapa ribu baris.
   - Belum perlu untuk implementasi awal.
   - Siapkan threshold 2.000 baris dan ukur sebelum menambah `compute`.

---

## 8. Penyesuaian terhadap PRD

| Topik PRD | Kondisi kode | Keputusan |
| --- | --- | --- |
| “Saldo saat ini harus sama persis dengan dashboard” | Dashboard memakai siklus aktif, bukan all-time | Tampilkan `Saldo akhir periode` dan `Saldo siklus aktif (dashboard)` terpisah |
| `goalId` disebut di luar scope | Sudah tersimpan di entity dan Firestore | Pakai `goalId` sebagai matching utama; tidak perlu ubah skema |
| Sheet 2 “dua kolom nominal” | PRD mendaftar tiga kolom | Pakai tiga kolom: Pemasukan, Pengeluaran, Ditabung |
| Nama file memakai akhir periode | Periode bulanan/siklus bisa berakhir di masa depan | Nama file memakai rentang tanggal aktual data |
| “Jumlah hari dalam periode” | Bisa ambigu untuk all-time | Bulanan/siklus/kustom = hari kalender penuh; all-time = tanggal transaksi paling awal sampai akhir |
| Sheet Target Tabungan memakai `currentAmount` | Progress adalah kondisi saat ini, bukan akhir periode historis | Label “Terkumpul (saat ini)”; opsional kolom “Dialokasikan di periode ini” |
| Formula injection | CSV dan XLSX punya perilaku berbeda | CSV: prefix `'`; XLSX: tulis sebagai string cell agar tidak dieksekusi |
| Isolate jika >2.000 baris | Belum ada bukti durasi | Implementasi sinkron dulu; ukur dan tambahkan di Batch 5 bila perlu |
| Nama aplikasi | Package `savu`, UI masih `Dompetku` | Ekspor memakai `Savu`; penyelarasan judul UI menjadi commit terpisah |

---

## 9. Rencana File

```text
lib/features/export/
├── domain/
│   ├── entities/
│   │   ├── report_summary.dart
│   │   ├── report_transaction_row.dart
│   │   ├── category_total.dart
│   │   ├── monthly_total.dart
│   │   ├── goal_progress.dart
│   │   └── export_options.dart
│   ├── repositories/export_repository.dart
│   └── usecases/
│       ├── build_report_summary.dart
│       └── resolve_export_period.dart
├── data/
│   ├── exporters/csv_exporter.dart
│   ├── exporters/xlsx_exporter.dart
│   ├── services/report_share_service.dart
│   └── repositories/export_repository_impl.dart
└── presentation/
    ├── providers/export_controller.dart
    └── widgets/export_sheet.dart
```

File pendukung:

- `lib/core/constants/app_config.dart` — nama aplikasi.
- `lib/core/constants/finance_categories.dart` — konstanta kategori alokasi.
- `test/fixtures/export_sample_v1.csv` — fixture sintetis 43 baris.
- `docs/export-format.md` — dokumentasi format untuk pengguna/developer.

---

## 10. Risiko dan Mitigasi

| Risiko | Mitigasi |
| --- | --- |
| API `excel_community` kurang lengkap | Verifikasi awal Batch 3; fallback sederhana dan dokumentasikan |
| Nama file/MIME tidak sesuai di iOS/Android | Tes perangkat nyata; `path_provider` hanya jika diperlukan |
| Saldo laporan dianggap salah karena beda dengan dashboard | Dua metrik dengan label dan rentang eksplisit |
| Goal selesai sudah dihapus dari daftar | Alokasi tampil sebagai `(Tidak tercatat)` |
| Data lama tanpa `goalId` | Fallback matching catatan |
| Nominal pecahan | Bulatkan sekali di Domain; ekspor memakai integer rupiah |
| Formula injection | Sanitasi teks CSV; XLSX string cell |
| CSV dibuka sebagai satu kolom | Default `;` + opsi `,`, BOM, CRLF |
| File besar | Exporter pure Dart; threshold isolate diukur di Batch 5 |

---

## 11. Gate Batch 0

| Pemeriksaan | Hasil |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 137/137 lulus |
| Perubahan kode fitur | Tidak ada |
| Dokumen audit | `docs/export-audit.md` |

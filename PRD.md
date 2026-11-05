# PRD — Savu App (MoneyTracker)

**Versi:** 2.0 — UI/UX Refactor
**Platform:** Flutter (Android & iOS)
**Target user:** Mahasiswa & anak kos Indonesia
**Status produk:** Fase 1–4 selesai dan berfungsi. **Fase 5 (UI/UX Refactor) adalah satu-satunya pekerjaan aktif.**

> **Instruksi untuk AI agent**
>
> 1. Baca dokumen ini sampai habis sebelum menyentuh kode.
> 2. Fase 1–4 adalah baseline yang tidak boleh rusak. Jangan ubah logika, data, atau arsitektur.
> 3. Mulai dari **Batch 0 (Audit)**. Jangan langsung mengubah layar.
> 4. Kerjakan satu batch, commit, laporkan hasilnya, lalu berhenti sampai diminta lanjut.

## Daftar Isi

1. [Visi & Core Loop](#1-visi--core-loop)
2. [Tech Stack & Aturan Arsitektur](#2-tech-stack--aturan-arsitektur)
3. [Data Model (baseline)](#3-data-model-baseline)
4. [Fitur yang Sudah Ada (Fase 1–4)](#4-fitur-yang-sudah-ada-fase-14)
5. [Fase 5 — UI/UX Refactor](#5-fase-5--uiux-refactor)
6. [Constraint Wajib](#6-constraint-wajib)
7. [Pertanyaan Terbuka untuk Audit](#7-pertanyaan-terbuka-untuk-audit)

---

## 1. Visi & Core Loop

**Visi:** membantu mahasiswa dan anak kos berhenti "bocor halus" lewat pencatatan yang secepat mengetik chat.

**Core loop:** buka app → lihat sisa anggaran dan saldo → tap tambah transaksi → tersimpan ke Firestore → dashboard otomatis ter-update.

**Fitur pembeda:** input transaksi super cepat, peringatan anggaran (_overspending alert_), dan alokasi target tabungan (contoh: UKT Semester 3).

---

## 2. Tech Stack & Aturan Arsitektur

| Aspek            | Keputusan                                                               |
| ---------------- | ----------------------------------------------------------------------- |
| Framework        | Flutter (Dart)                                                          |
| Arsitektur       | Clean Architecture: Domain, Data, Presentation                          |
| State management | Riverpod (`Notifier` / `AsyncNotifier`)                                 |
| Backend          | Firebase Firestore                                                      |
| Local storage    | SharedPreferences (mode gelap, batas anggaran bulanan)                  |
| Font             | Plus Jakarta Sans, **di-bundle sebagai asset** (bukan download runtime) |

Aturan arsitektur (tidak boleh dilanggar):

- UseCase di Domain, implementasi Repository di Data, Notifier di Presentation.
- Presentation tidak boleh berisi logika bisnis. Widget hanya membaca state dan memanggil Notifier.

---

## 3. Data Model (baseline)

> Ini skema dari PRD versi lama. Audit di Batch 0 kemungkinan menemukan field tambahan (misalnya siklus anggaran, status arsip target). **Jangan hapus atau ubah field apa pun.**

**`transactions`:** `id`, `amount` (double), `type` (`income` | `expense`), `category` (string), `date` (Timestamp), `note`.

**`savings_goals`:** `id`, `title`, `targetAmount`, `currentAmount`, `deadline` (Timestamp).

---

## 4. Fitur yang Sudah Ada (Fase 1–4)

| Fase | Fitur                                                                                                  | Status  |
| ---- | ------------------------------------------------------------------------------------------------------ | ------- |
| 1    | Dashboard saldo, ringkasan pemasukan/pengeluaran, bagan pengeluaran per kategori, form catat transaksi | Selesai |
| 2    | Overspending alert (merah jika pengeluaran ≥ 80% batas anggaran), target tabungan, alokasi dana        | Selesai |
| 3    | Riwayat dikelompokkan per tanggal, edit transaksi, hapus dengan swipe + konfirmasi                     | Selesai |
| 4    | Toggle mode gelap, atur batas anggaran bulanan                                                         | Selesai |

**Fitur yang ada di app tetapi belum tercatat di PRD lama** (terlihat di UI): kartu _Insight keuangan_ (siklus anggaran aktif, rata-rata pengeluaran per hari), filter _Siklus aktif_ di Riwayat, pencarian transaksi, tab target _Aktif/Selesai_, pengurutan target, dan target _Diarsipkan_. Semuanya **wajib dipertahankan**. Dokumentasikan di `docs/ui-audit.md`.

---

## 5. Fase 5 — UI/UX Refactor

### 5.1 Tujuan dan Scope

**Tujuan:** tampilan Savu terasa seperti app keuangan yang dirancang dengan sengaja: hierarki jelas, tenang, mudah dipindai, dan rapi di tema terang maupun gelap.

**Di dalam scope:** layout, warna, tipografi, komponen, navigasi, empty state, motion, aksesibilitas, tema gelap.

**Di luar scope (jangan dikerjakan):**

- Perubahan Domain/Data layer, Firestore schema, logika kalkulasi.
- Fitur baru. Contoh yang sengaja ditunda: Undo setelah hapus transaksi (butuh perubahan logika).
- Penggantian state management atau struktur folder fitur.

### 5.2 Diagnosis Kondisi Sekarang

Hasil analisis screenshot Beranda, Target, dan Riwayat:

| #   | Masalah                                                                                    | Dampak                                                                              |
| --- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| 1   | Hampir semua elemen berupa kartu persegi panjang berukuran sama dengan treatment sama      | Tidak ada hierarki. Mata tidak tahu mana yang penting                               |
| 2   | Kartu di dalam kartu (Saldo berisi 2 kotak Pemasukan/Pengeluaran, Insight berisi 2 kotak)  | Visual berat dan berantakan                                                         |
| 3   | Gradasi teal pada hero, kartu insight, dan background layar                                | Terasa dekoratif, bentrok dengan tema gelap                                         |
| 4   | Navigasi bawah berupa pill melayang dengan tombol `+` yang menimpa bar                     | Menutupi konten (teks "Belum ada kategori…" tertutup), label terpotong ("Pengatu…") |
| 5   | Filter Riwayat berlapis: pencarian + 3 chip + segmented, beberapa terpotong ("Ta…", "Ka…") | Padat dan tidak terbaca                                                             |
| 6   | Chip urutan di Target terpotong ("Progr"), tombol "Diarsipkan" selebar layar               | Kontrol sekunder terlalu dominan                                                    |
| 7   | Kondisi kosong (`Rp 0` di mana-mana) tidak didesain                                        | Layar pertama terasa mati                                                           |
| 8   | Setiap pengeluaran berwarna merah                                                          | Merah kehilangan makna sebagai peringatan                                           |
| 9   | Warna di-hardcode di widget                                                                | Penyebab tema gelap rusak                                                           |

### 5.3 Prinsip Desain

1. **Satu hal dominan per layar.** Maksimal satu permukaan berwarna solid (hero). Sisanya terbuka di atas background.
2. **Whitespace dan garis tipis menggantikan kotak.** Pisahkan section dengan jarak dan hairline, bukan kartu.
3. **Kartu hanya untuk objek yang bisa diketuk** (target tabungan) atau satu hero.
4. **Warna punya arti.** Teal = aksi dan brand. Hijau = pemasukan. Merah = peringatan/bahaya, bukan setiap pengeluaran.
5. **Angka adalah bintang.** Nominal selalu tabular, rata kanan, dan bobot jelas.
6. **Tanpa gradasi.** Kedalaman datang dari tone permukaan, bukan gradient.
7. **Tema gelap didesain sendiri**, bukan hasil inversi tema terang.

### 5.4 Design Tokens

Semua warna harus lewat `ThemeExtension` (`AppColors`). **Dilarang memakai `Colors.xxx` literal di widget** (kecuali `Colors.transparent`).

#### Warna

| Token              | Light                              | Dark      | Fungsi                                 |
| ------------------ | ---------------------------------- | --------- | -------------------------------------- |
| `background`       | `#F7F8F7`                          | `#0E1311` | Latar layar                            |
| `surface`          | `#FFFFFF`                          | `#161C1A` | Kartu, sheet, nav bar                  |
| `surfaceVariant`   | `#EEF1EF`                          | `#1E2623` | Blok halus, track progress, ikon tonal |
| `outline`          | `#E1E5E3`                          | `#2A3431` | Hairline 1px                           |
| `textPrimary`      | `#121A18`                          | `#E8EEEC` | Teks utama                             |
| `textSecondary`    | `#5B6764`                          | `#9AA8A4` | Label, caption                         |
| `primary`          | `#0B6B61`                          | `#5CCFBF` | Tombol utama, item nav aktif           |
| `onPrimary`        | `#FFFFFF`                          | `#00201C` | Teks di atas primary                   |
| `primaryContainer` | `#D5EFEA`                          | `#12403B` | Hero, chip terpilih                    |
| `income`           | `#12804A`                          | `#5BD38E` | Nominal pemasukan                      |
| `danger`           | `#C73A32`                          | `#FF8A80` | Overspending, hapus                    |
| `warning`          | `#E8A317` (fill), `#8A5A12` (teks) | `#F5C451` | Deadline dekat                         |

> Target kontras teks minimal 4.5:1. Agent wajib memverifikasi pasangan warna sebelum dipakai.

#### Warna Kategori (satu sumber untuk ikon, legenda, dan segmen bagan)

Delapan hue redup. Kategori dipetakan ke warna secara stabil berdasarkan nama. "Lainnya" selalu `slate`. Latar ikon = warna kategori pada opasitas 14%. Varian gelap = lebih terang ±15% lightness.

`terracotta #D9685A` · `blue #3E86C8` · `amber #E0A030` · `green #6FAE5B` · `violet #8B73C9` · `teal #2FA9A0` · `rose #D9709A` · `slate #7C8A96`

#### Tipografi (Plus Jakarta Sans)

| Style         | Ukuran / Line height | Weight | Dipakai untuk      |
| ------------- | -------------------- | ------ | ------------------ |
| `amountHero`  | 34 / 40              | 700    | Saldo utama        |
| `titleLarge`  | 22 / 28              | 700    | Judul layar        |
| `titleMedium` | 16 / 24              | 600    | Judul section      |
| `body`        | 14 / 20              | 400    | Teks umum          |
| `amountRow`   | 15 / 20              | 600    | Nominal di list    |
| `label`       | 12 / 16              | 500    | Caption, label nav |

Semua nominal memakai `FontFeature.tabularFigures()`. Format: `Rp 1.250.000`, pengeluaran `−Rp 12.000` (tanda minus sebenarnya, U+2212).

#### Spacing, Radius, Elevation

- Grid 4pt. Skala: `4 · 8 · 12 · 16 · 20 · 24 · 32`.
- Padding horizontal layar: **20**. Jarak antar section: **28**.
- Radius hanya tiga: `12` (kontrol, chip), `16` (kartu, sheet), `20` (hero), `999` (pill).
- Elevation: **tidak ada** pada kartu. Light memakai hairline `outline` 1px. Dark memakai tone `surface`. Hanya FAB dan bottom sheet yang boleh punya shadow.

Kerangka `AppColors` (agent boleh menyesuaikan nama field):

```dart
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background, required this.surface, required this.surfaceVariant,
    required this.outline, required this.textPrimary, required this.textSecondary,
    required this.income, required this.danger, required this.warning,
  });
  final Color background, surface, surfaceVariant, outline,
      textPrimary, textSecondary, income, danger, warning;
  // copyWith + lerp wajib diimplementasikan
}
```

### 5.5 Komponen Bersama (`lib/shared/widgets/`)

| Komponen          | Tugas                                                                       |
| ----------------- | --------------------------------------------------------------------------- |
| `AppShell`        | Scaffold + `NavigationBar` + FAB kontekstual, mengatur padding bawah konten |
| `SectionHeader`   | Judul section + aksi teks opsional (contoh: "Lihat semua")                  |
| `AmountText`      | Format nominal, tabular, warna sesuai tipe                                  |
| `StatInline`      | Label kecil + nominal, dipakai berdampingan tanpa kotak                     |
| `BudgetProgress`  | Bar 8dp beranimasi + keterangan sisa; merah jika ≥ 80%                      |
| `CategoryIcon`    | Lingkaran tonal 40dp dengan ikon, warna dari palet kategori                 |
| `TransactionTile` | Baris transaksi tanpa kartu                                                 |
| `GoalCard`        | Satu-satunya kartu "interaktif" di app                                      |
| `EmptyState`      | Ikon dalam lingkaran tonal + judul + 1 kalimat + 1 tombol                   |
| `FilterSheet`     | Bottom sheet filter (periode, kategori, siklus aktif)                       |

Tema dan token ada di `lib/core/theme/`: `app_theme.dart`, `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `category_palette.dart`.

### 5.6 Spesifikasi Layar

#### Navigasi dan FAB (berlaku global)

- Ganti pill melayang dengan **Material 3 `NavigationBar`**, 4 destinasi sesuai urutan sekarang: **Beranda, Target, Riwayat, Pengaturan**. Label penuh, tidak boleh terpotong.
- Tombol catat transaksi menjadi **FAB** (`Scaffold.floatingActionButton`, posisi `endFloat`) di Beranda dan Riwayat. Di tab Target, FAB dipakai untuk "Buat target" jika alur itu ada (cek di audit).
- Semua konten yang bisa di-scroll wajib punya padding bawah = tinggi nav bar + ruang FAB, sehingga tidak pernah tertutup.

#### Beranda (atas ke bawah)

1. **Header.** Sapaan kecil ("Selamat siang") + nama, avatar 36dp, ikon notifikasi (pertahankan perilaku yang ada).
2. **Hero saldo.** Satu-satunya permukaan solid: `primaryContainer`, radius 20, **tanpa gradient**. Isi: label "Saldo saat ini" + ikon mata, `amountHero`, lalu dua `StatInline` (Pemasukan, Pengeluaran) dipisah garis vertikal tipis. **Tidak ada kotak di dalam hero.**
3. **Anggaran bulan ini.** Judul section + aksi "Atur". Jika belum diatur: satu baris teks + tombol outlined "Atur anggaran" (bukan kartu abu dengan ikon info). Jika sudah: "Sisa Rp X", `BudgetProgress`, dan "Rp Y dari Rp Z · N hari lagi".
4. **Pengeluaran per kategori.** Ganti PieChart dengan **satu bar bertumpuk horizontal** (tinggi 12dp, radius 6) + daftar peringkat maksimal 5 baris (`CategoryIcon`, nama, nominal, persen). Kondisi kosong memakai `EmptyState` ("Belum ada pengeluaran bulan ini" + tombol "Catat pengeluaran").
5. **Insight keuangan.** Satu baris ikon bohlam + kalimat ringkas, lalu dua `StatInline` (Pengeluaran, Rata-rata/hari). **Tanpa kartu.**
6. **Transaksi terbaru.** 3–5 `TransactionTile` + "Lihat semua".

#### Riwayat

- App bar: judul, ikon cari (membuka field cari inline), ikon filter dengan titik penanda saat ada filter aktif.
- **Satu kontrol terlihat:** segmented _Semua / Pemasukan / Pengeluaran_.
- Filter lain (periode, kategori, siklus aktif) pindah ke `FilterSheet`. Filter yang aktif tampil sebagai chip yang bisa dihapus, dalam satu baris yang bisa di-scroll. Tidak ada teks terpotong.
- Daftar dikelompokkan per tanggal: header kiri "Selasa, 20 Okt 2026", kanan total bersih hari itu. Ketuk header membuka overview (perilaku yang ada dipertahankan).
- Baris transaksi tanpa kartu, hairline inset sejajar teks. Pemasukan: `income` dengan `+`. **Pengeluaran: `textPrimary` dengan `−`** (bukan merah).
- Ketuk baris = edit. Swipe = hapus dengan dialog konfirmasi (perilaku yang ada).

#### Target Tabungan

- App bar: judul + menu overflow berisi _Diarsipkan_ dan _Urutkan_ (bottom sheet). Hapus chip urutan dan tombol "Diarsipkan" selebar layar.
- Tab _Aktif / Selesai_ dipertahankan, dengan jumlah di samping label.
- `GoalCard`: ikon, judul, persen di kanan atas, "19 Nov 2026 · 47 hari lagi" (warna `warning` jika ≤ 14 hari), progress bar, "Rp 0 terkumpul" di kiri dan "Rp 500.000 lagi" di kanan, tombol utama `FilledButton` "Alokasikan dana". Menu ⋮ untuk edit/arsip.
- Kondisi kosong: `EmptyState` dengan tombol "Buat target pertama".

#### Form Tambah/Edit Transaksi

> Audit dulu bentuk form sekarang, lalu terapkan prinsip berikut tanpa mengubah validasi dan alur simpan.

- Toggle _Pengeluaran / Pemasukan_ di atas.
- Field nominal besar di paling atas, keypad angka, format ribuan `id_ID` saat mengetik.
- Pilihan kategori sebagai grid `CategoryIcon` (kategori terbaru dipakai di urutan pertama). Tanggal default hari ini. Catatan opsional.
- Tombol _Simpan_ menempel di bawah, tetap terlihat saat keyboard terbuka.

#### Pengaturan

- Daftar bergrup (_Tampilan_, _Anggaran_, _Data_): satu permukaan per grup dengan hairline antar baris, bukan satu kartu per item.

### 5.7 Aturan Tema Gelap

- Semua warna berasal dari `AppColors` dan `ColorScheme`. Tidak ada warna literal.
- Tidak ada gradient di mana pun. Perbedaan lapisan dibuat dari `background` → `surface` → `surfaceVariant`.
- Teks tidak pernah putih murni `#FFFFFF` di atas gelap. Pakai `textPrimary`.
- Ikon kategori dan segmen bagan memakai varian gelap dari palet kategori.
- Sebelum batch dinyatakan selesai, bandingkan setiap layar di kedua tema.

### 5.8 Motion, Haptic, Aksesibilitas

- Durasi 200–250ms, kurva `easeOutCubic`. Hitung-naik saldo saat pertama muat 600ms. Progress bar beranimasi 400ms.
- Hormati `MediaQuery.disableAnimations`.
- Haptic ringan hanya saat transaksi berhasil disimpan.
- Semua target ketuk ≥ 48dp. Semua nominal punya label `Semantics` yang terbaca ("minus dua belas ribu rupiah").
- UI tidak overflow pada lebar 360dp dengan text scale 1.0 dan 1.3.

### 5.9 Rencana Eksekusi (per Batch)

Semua pekerjaan di branch `refactor/ui-v2`. **Jangan merge ke `main`.** Tiap batch: `flutter analyze` bersih, `flutter test` lolos, lalu commit `refactor(ui): <ringkasan>`. Setelah itu berhenti dan laporkan.

| Batch | Isi                                                                                                                                                             | Kriteria selesai                                 |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| 0     | **Audit.** Buat branch. Tulis `docs/ui-audit.md`: daftar layar, widget, fitur yang ada, setiap warna literal, setiap gradient, dan semua fitur di luar PRD lama | Dokumen ada. Belum ada perubahan kode UI         |
| 1     | **Fondasi tema.** Token, `ThemeData` light/dark, font ter-bundle, `ThemeExtension`, palet kategori                                                              | App tetap jalan. Tema bisa berganti              |
| 2     | **Komponen bersama** (5.5), diuji dengan widget test sederhana                                                                                                  | Semua komponen punya varian light/dark           |
| 3     | **Shell + Beranda**                                                                                                                                             | Sesuai 5.6, tanpa kartu bersarang                |
| 4     | **Riwayat**                                                                                                                                                     | Tidak ada teks terpotong, filter pindah ke sheet |
| 5     | **Target**                                                                                                                                                      | Sesuai 5.6                                       |
| 6     | **Form transaksi + Pengaturan**                                                                                                                                 | Alur simpan/edit tidak berubah                   |
| 7     | **Polish.** Motion, aksesibilitas, sapu bersih mode gelap, hapus kode mati, update dokumentasi                                                                  | Semua checklist 5.10 hijau                       |

### 5.10 Definition of Done

Jalankan dan lampirkan hasilnya:

```bash
grep -rnE "LinearGradient|RadialGradient|SweepGradient" lib/        # harus kosong
grep -rnP "Colors\.(?!transparent)" lib/features lib/shared         # harus kosong
flutter analyze                                                      # No issues found
flutter test                                                         # semua lolos
```

Checklist manual:

- [ ] Tidak ada kartu di dalam kartu.
- [ ] Maksimal satu permukaan solid berwarna per layar.
- [ ] Nav bar tidak menutupi konten, label tidak terpotong.
- [ ] Tidak ada teks terpotong di 360dp (scale 1.0 dan 1.3).
- [ ] Semua layar terbaca baik di tema terang dan gelap.
- [ ] Setiap layar punya empty state yang didesain.
- [ ] Seluruh fitur di `docs/ui-audit.md` masih berfungsi.

---

## 6. Constraint Wajib

1. **Jangan ubah arsitektur.** UseCase (Domain), Repository impl (Data), Notifier (Presentation) tetap terpisah.
2. **Error handling.** Setiap request Firestore dibungkus `try-catch`; tampilkan `SnackBar` untuk sukses/gagal.
3. **Tanpa kode setengah jadi.** Tidak ada `// TODO` atau placeholder.
4. **Commit per batch** di branch `refactor/ui-v2`, format `refactor(ui): <ringkasan>`. Jangan commit jika analyze atau test gagal.
5. **Jangan tambah dependency** tanpa alasan tertulis di `progress.md`. Font di-bundle sebagai asset.
6. **Copy dalam Bahasa Indonesia**, nada santai, sapaan "kamu". Teks UI terpusat, bukan tersebar di widget.

---

## 7. Pertanyaan Terbuka untuk Audit

Agent menjawab ini di `docs/ui-audit.md` sebelum Batch 1:

1. Di mana alur "Buat target" berada sekarang, dan apakah perlu FAB di tab Target?
2. Apa saja yang dilakukan ikon notifikasi di header?
3. Field tambahan apa yang ada di model (siklus anggaran, arsip) dan layar mana yang memakainya?
4. Apakah `fl_chart` dipakai di tempat lain? Jika tidak, usulkan pelepasannya (jangan hapus tanpa persetujuan).
5. Berapa banyak warna literal dan gradient yang ditemukan, dan di file mana?

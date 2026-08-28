# Prioritas Perbaikan MoneyTracker

Dokumen ini menjadi catatan lanjutan ketika sesi AI terputus, laptop di-refresh,
atau model AI berganti. Status mencerminkan kondisi implementasi terakhir.

## Status Prioritas 1-7

| No. | Prioritas | Status | Catatan |
| --- | --- | --- | --- |
| 1 | Firestore Transaction untuk operasi alokasi | Selesai | Tambah, edit, dan hapus alokasi kini membaca data terbaru di dalam `runTransaction`. |
| 2 | Hapus target dengan banyak riwayat alokasi | Selesai | Transaksi alokasi dihapus dalam chunk 450 dokumen, lalu target dihapus pada batch terpisah. |
| 3 | Test lengkap filter History dan ringkasan | Selesai | Step 14 dibuat dengan use case filter dan test kombinasi dasar. |
| 4 | Modularisasi halaman Settings | Selesai | Entry page dan komposisi content Settings sudah dipisah; section reusable sebelumnya juga berada di file widget terdedikasi. |
| 5 | Empty state Dashboard yang lebih informatif | Selesai | Hero onboarding, empty chart, dan empty insight sudah memiliki copy, visual, serta CTA/informasi yang jelas. |
| 6 | Status sinkronisasi yang lebih detail | Selesai sebagian | Loading, sukses, gagal, dan retry sudah tersedia; last synced/offline queue belum ada. |
| 7 | Firebase Authentication dan isolasi data user | Belum selesai | Data masih memakai collection global dan belum memiliki uid. |

## Fitur yang Sudah Selesai Sebelumnya

- Fase PRD 1 sampai 4.
- Operasi alokasi atomik dengan Firestore Transaction.
- Profil Settings, tipe pengguna, dan detail profil.
- Filter kategori History searchable bottom sheet.
- Validasi edit alokasi agar saldo utama tidak negatif.
- Branding footer `Product by Andre Robert`.
- Status sinkronisasi dasar pada profil Settings.

## Step Terakhir

**Step 14: penguatan filter History dan ringkasan transaksi**

- Logika filter dipindahkan ke `FilterTransactionsUseCase`.
- UI History menampilkan ringkasan filter aktif dan tombol `Reset`.
- Test kategori + tipe, pencarian catatan, dan siklus aktif ditambahkan.

## Step Berikutnya

Prioritas aktif berikutnya adalah **Prioritas 5: empty state Dashboard yang lebih informatif**.

Prioritas aktif berikutnya adalah **Prioritas 6 lanjutan: status sinkronisasi dengan waktu pembaruan terakhir**.

## Step 19

- Menambahkan hero empty state Dashboard untuk pengguna tanpa transaksi.
- Menampilkan greeting pengguna dan CTA `Catat transaksi`.
- Memperjelas empty state pie chart agar menjelaskan manfaat kategori pengeluaran.
- Menambahkan empty state financial insight agar tidak terlihat seperti data error atau palsu.
- Mempertahankan error state dan loading state sebagai kondisi yang berbeda.

## Step 17

- Memindahkan `SettingsSectionTitle` ke `widgets/settings_section_title.dart`.
- Memindahkan `DeveloperCard` ke `widgets/developer_card.dart`.
- Memindahkan `HelpCenterEntry` ke `widgets/help_center_entry.dart`.
- Memindahkan `HelpCenterSheet` beserta FAQ ke `widgets/help_center_sheet.dart`.
- Halaman utama Settings sekarang hanya mengorkestrasi section dan mempertahankan UI premium yang sama.

## Step 18

- Memindahkan entry point Settings ke `pages/settings_page.dart` yang ringan.
- Memindahkan komposisi seluruh content Settings ke `widgets/settings_content.dart`.
- Mempertahankan provider, dialog, feedback, dan visual premium yang sudah ada.
- Menghapus implementasi Settings duplikat dari file page.

## Verifikasi Terakhir

- Jalankan `flutter analyze`.
- Jalankan `flutter test`.
- Validasi manual di device Android untuk filter History dan layar kecil.

## Workflow

- Perubahan belum di-commit oleh AI.
- User melakukan commit manual setelah verifikasi device.

# Progress: Settings Sync dan Validasi Edit Alokasi

## Tanggal

Dibuat 2026-08-28 — diperbarui 2026-09-03

## Status

Tahap ini **selesai dan sudah ter-commit**. Bagian "Perubahan" di bawah adalah
arsip. Lihat "Perkembangan Lanjutan" untuk kondisi terkini.

## Perubahan (arsip 2026-08-28)

- Status `Tersinkronisasi` di profil Settings tidak lagi statis.
- Status profil mengikuti stream transaksi Firestore:
  - Menyiapkan sinkronisasi
  - Tersinkronisasi
  - Sinkronisasi gagal
- Status gagal dapat diketuk untuk mencoba sinkronisasi ulang.
- Edit alokasi menghitung saldo yang tersedia dengan mengembalikan nominal alokasi lama terlebih dahulu.
- Formula validasi edit:

  `saldo tersedia untuk edit = saldo bulan berjalan + alokasi lama`

- Nominal baru ditolak jika melebihi saldo yang tersedia.
- Batas target tabungan tetap divalidasi.
- Pesan error edit alokasi diteruskan ke SnackBar.
- Footer Settings diubah menjadi `Product by Andre Robert`.

## Hasil Verifikasi (2026-08-28)

- `flutter analyze`: bersih
- `flutter test`: seluruh test lulus

## Perkembangan Lanjutan (2026-09-02 s/d 2026-09-03)

Area Settings, sinkronisasi, dan alokasi kembali disentuh oleh beberapa commit di
branch `develop_dua`. Berikut yang berubah sejak catatan di atas.

### Settings dan Profil

- **Avatar preset tersimpan lokal.** `SettingsService` menambahkan
  `getProfileAvatarId()` dan `setProfileAvatarId()` dengan kunci SharedPreferences
  `profile_avatar_id` (default `sunrise`), diekspos lewat `profileAvatarProvider`
  (`a992904`).
- **Avatar dapat diketuk.** Header profil memakai `InkWell` + `AnimatedSwitcher`
  untuk membuka `ProfileAvatarSheet`, menggantikan `CircleAvatar` berinisial nama
  yang statis.
- **Katalog avatar bertambah menjadi 30 preset** dalam kategori `general` (15) dan
  `people` (13).
- **Filter gender dihapus** (`6340933`): `_GenderSelector` beserta `ChoiceChip`
  Laki-laki/Perempuan dibuang. Enum `PresetAvatarGender` masih ada sebagai metadata
  avatar, tetapi tidak dipakai UI.
- **Grid avatar responsif:** 3 kolom di bawah lebar 360px, 4 kolom di atasnya
  (`402f04c`).
- **Kontak founder langsung membuka aplikasi native** (`4a546bf`, `05de391`):
  Gmail melalui intent Android dengan fallback `url_launcher`, WhatsApp melalui
  `android_intent_plus` ke `62895338891504`, dan GitHub melalui browser.
  Import `share_plus` diganti dari file ini.
- **Tombol proporsional:** kirim feedback diperkecil (`d23212c`); tombol batal pada
  ganti akun diperbesar (`9cf2bd8`); aksi dialog diseragamkan dan overflow dicegah
  (`1ec64b1`).
- **Flag onboarding.** `SettingsService` menambahkan `getOnboardingCompleted()` dan
  `setOnboardingCompleted()` dengan provider `onboardingCompletedProvider`
  (`f7b773f`).

### Validasi Alokasi

- **Konfirmasi hapus dan tarik alokasi diperjelas.** Dialog menghapus target kini
  membedakan pesan antara target selesai ("Riwayat alokasi tetap dicatat sebagai
  transaksi historis agar saldo tidak berubah") dan target aktif ("Dana yang sudah
  dialokasikan (Rp X) akan dikembalikan ke saldo utama").
- **Tombol dialog memenuhi lebar.** `edit_allocation_sheet.dart` (`7171105`) dan
  `savings_page.dart` (`e0803c1`) kini memakai `Row` berisi `Expanded` +
  `OutlinedButton` (Batal) berdampingan dengan `FilledButton` (Tarik/Hapus),
  masing-masing `minimumSize: Size.fromHeight(48)`.
- ⚠️ **Catatan untuk kategori:** alokasi otomatis tetap menulis transaksi dengan
  kategori `'Alokasi Tabungan'` (`savings_providers.dart:227`), sementara daftar
  kategori default user sudah menggantinya menjadi "Kesehatan & Perawatan"
  (`96a246a`). Kedua hal ini **tidak boleh disamakan** tanpa migrasi data.

## Hasil Verifikasi Terkini (2026-09-04)

- `flutter analyze`: **No issues found** setelah perbaikan Tahap 30. Sebelumnya terdapat 5 info (3 di antaranya `use_build_context_synchronously` pada
  `settings_content.dart` baris 1306, 1312, 1314).
- `flutter test`: **69/69 lulus**.

## Catatan

Perubahan belum di-commit oleh AI. Commit dilakukan manual oleh user sesuai workflow proyek.
Seluruh perubahan pada dokumen ini sudah berada di branch `develop_dua` dan
working tree dalam keadaan bersih.

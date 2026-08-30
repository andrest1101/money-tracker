# Progress: Settings Sync dan Validasi Edit Alokasi

## Tanggal

2026-08-28

## Perubahan

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

## Hasil Verifikasi

- `flutter analyze`: bersih
- `flutter test`: seluruh test lulus

## Catatan

Perubahan belum di-commit oleh AI. Commit dilakukan manual oleh user sesuai workflow proyek.

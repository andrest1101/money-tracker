# Progress: Firebase Authentication dan Isolasi Data User

## Step 21

### Selesai

- Menambahkan dependency `firebase_auth`.
- Menambahkan Firebase Anonymous Authentication.
- Menambahkan provider Riverpod untuk Firebase Auth dan auth state.
- Menambahkan `AuthGate` agar `MoneyTrackerApp` hanya dibuka setelah anonymous user tersedia.
- Repository transaksi memakai path `users/{uid}/transactions`.
- Repository target memakai path `users/{uid}/savings_goals`.
- Operasi alokasi, edit alokasi, hapus alokasi, reset data, dan hapus target menggunakan path user-scoped yang sama.
- Dependency injection repository menerima instance `FirebaseAuth` dari provider.
- Jika Anonymous Auth gagal karena belum diaktifkan di Firebase Console, `AuthGate` tidak lagi memblokir startup; repository memakai collection global lama sebagai fallback sementara.

### Belum Selesai

- Aktifkan Anonymous provider di Firebase Console.
- Tambahkan Firebase Security Rules yang memverifikasi `request.auth.uid`.
- Migrasikan data lama dari collection global `transactions` dan `savings_goals` jika data lama perlu dipertahankan.
- Tambahkan login permanen atau account linking agar anonymous user tidak hilang ketika aplikasi dihapus.
- Hapus fallback global setelah autentikasi dan security rules siap digunakan di production.
- Validasi langsung di device Android.

### Recovery Fix

- Auth failure tidak lagi memblokir aplikasi saat startup.
- Jika anonymous auth berhasil, data memakai path user-scoped.
- Jika anonymous auth belum aktif atau gagal, aplikasi memakai collection global lama sebagai fallback sementara agar aplikasi tetap dapat dibuka dan data lama tidak tampak hilang.
- Fallback global belum aman untuk multi-user dan harus dihapus setelah Anonymous Auth serta Security Rules siap.

### Verifikasi

- Jalankan `flutter pub get`.
- Jalankan `flutter analyze`.
- Jalankan `flutter test`.

Perubahan belum di-commit oleh AI. User melakukan commit manual sesuai workflow proyek.

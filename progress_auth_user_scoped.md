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
- Repository transaksi dan target menolak operasi ketika sesi user belum tersedia; tidak ada fallback runtime ke collection global.
- `firestore.rules` ditambahkan dan `firebase.json` dikonfigurasi untuk deploy rules tersebut.
- Root collection legacy `transactions` dan `savings_goals` ditutup dari client.
- Guest dapat menghubungkan akun Google atau email/password melalui UI Settings dengan `linkWithCredential`; UID guest tetap dipertahankan.
- Password tidak disimpan di Firestore atau database aplikasi; pengelolaan kredensial dilakukan Firebase Authentication.
- Google Sign-In membutuhkan provider Google aktif serta SHA-1/SHA-256 aplikasi Android terdaftar di Firebase Console.
- Auth landing page sekarang menjadi pintu masuk user baru dengan pilihan Google, email/password, email link, atau Guest.
- Email link memakai `sendSignInLinkToEmail` dan verifikasi `signInWithEmailLink`; fallback tempel link tersedia sebelum deep-link platform dikonfigurasi.
- Android build memakai Kotlin plugin `2.3.0`, NDK `27.0.12077973`, dan Kotlin compilerOptions DSL agar kompatibel dengan plugin Firebase terbaru yang masih didukung project.
- FlutterFire dipatok pada versi yang kompatibel dengan Flutter 3.32/Dart 3.8; `flutter build apk --debug` dan `flutter build web` berhasil.

### Belum Selesai

- Aktifkan Anonymous provider di Firebase Console.
- Deploy Firebase Security Rules yang memverifikasi `request.auth.uid`.
- Migrasikan data lama dari collection global `transactions` dan `savings_goals` jika data lama perlu dipertahankan.
- Tambahkan alur sign-in kembali untuk user yang sudah memiliki akun permanen setelah reinstall.
- Validasi langsung di device Android.
- Aktifkan provider Google dan Email/Password serta izinkan domain action link di Firebase Console.

### Perubahan Keamanan

- Auth failure menampilkan halaman error dengan aksi retry dan tidak membuka data tanpa identitas user.
- Jika anonymous auth berhasil, data memakai path user-scoped.
- Fallback global runtime dihapus karena tidak aman untuk multi-user.
- Data lama harus dimigrasikan secara administratif ke `users/{uid}` sebelum rules production diterapkan.

### Verifikasi

- Jalankan `flutter pub get`.
- Jalankan `flutter analyze`.
- Jalankan `flutter test`.

Perubahan belum di-commit oleh AI. User melakukan commit manual sesuai workflow proyek.

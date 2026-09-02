# Progress: Firebase Authentication dan Isolasi Data User

## Step 21

### Selesai

- Menambahkan dependency `firebase_auth`.
- Menambahkan Firebase Anonymous Authentication.
- Menambahkan provider Riverpod untuk Firebase Auth dan auth state.
- Menambahkan `AuthGate` agar `SavuApp` hanya dibuka setelah anonymous user tersedia.
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
- Feedback auth tidak lagi menutup sheet secara membingungkan; pengiriman email link menampilkan status sukses dan instruksi Inbox/Spam.
- Settings menyediakan logout/ganti akun; guest mendapat konfirmasi khusus karena sesi guest tidak memiliki recovery credential.
- Firebase Hosting dikonfigurasi untuk melayani `build/web`, sehingga action link tidak lagi menuju route Hosting yang kosong.
- Email link menyertakan email pada `continueUrl` sehingga email tujuan dapat diisi otomatis saat link dibuka pada browser/device lain.
- Google Sign-In web memakai Firebase popup, Android memakai native credential, dan error native sekarang menampilkan kode konfigurasi yang actionable.

### Belum Selesai

- Aktifkan Anonymous provider di Firebase Console.
- Deploy Firebase Security Rules yang memverifikasi `request.auth.uid`.
- Migrasikan data lama dari collection global `transactions` dan `savings_goals` jika data lama perlu dipertahankan.
- Tambahkan alur sign-in kembali untuk user yang sudah memiliki akun permanen setelah reinstall.
- Validasi langsung di device Android.
- Aktifkan provider Google dan Email/Password serta izinkan domain action link di Firebase Console.
- Deploy Hosting setelah `flutter build web`, lalu uji action link dari Gmail di Chrome dan Android. Android App Links sudah disiapkan melalui intent-filter dan `web/.well-known/assetlinks.json`; release SHA-256 tetap perlu ditambahkan.
- Google Android masih memerlukan OAuth client dan SHA-1/SHA-256; `android/app/google-services.json` saat ini belum memiliki `oauth_client`.

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

---

## HANDOFF SESI TERBARU

- Email/password login dan register sudah diuji.
- Email link, reset password, dan logout/ganti akun sudah diuji.
- Google Android sudah berhasil setelah konfigurasi OAuth/SHA diperbarui.
- Google Web memakai Firebase popup dan perlu diuji manual.
- Google iOS belum divalidasi dan membutuhkan Mac/Xcode.
- Email verification sudah diwajibkan untuk akun email/password.
- Register langsung mengirim email verifikasi setelah akun dibuat.
- AuthGate menahan akun email/password yang belum `emailVerified` dari Dashboard.
- `email_verification_page.dart` menyediakan pengecekan ulang status, kirim ulang
  dengan cooldown 60 detik, dan aksi ganti akun.
- Linking akun guest ke email/password juga mengirim email verifikasi.
- Email dianggap valid setelah user membuka link verifikasi Firebase; validasi
  format saja memang tidak dapat memastikan inbox benar-benar ada.

### Status Email Verification

- Verification email dikirim otomatis setelah register email/password.
- Dashboard ditahan untuk akun email/password yang belum verified.
- Guest tetap dapat masuk tanpa verifikasi.
- Halaman verifikasi profesional sudah tersedia.
- Tombol `Saya sudah verifikasi` menjalankan `user.reload()`.
- Resend verification memakai cooldown 60 detik.
- Aksi ganti akun tersedia melalui logout.

### Rencana Platform

- Uji Google Web di Chrome/Edge.
- Siapkan Google iOS melalui `GoogleService-Info.plist`, bundle ID yang konsisten, dan `REVERSED_CLIENT_ID` pada `Info.plist`.
- Validasi iOS membutuhkan Mac/Xcode.

### Verifikasi Terakhir

- `flutter analyze`: bersih dari error.
- `flutter test`: 52/52 lulus.
- `flutter build web`: berhasil.
- `flutter build apk --debug`: berhasil.
- `flutter build windows --debug`: berhasil setelah policy CMake Firebase dan
  direktori install Windows diperbaiki.

### Sisa Validasi Manual

- Uji email valid, typo, email palsu, dan resend pada Firebase Console aktif.
- Validasi Google Web di Chrome/Edge.
- Validasi deep link email pada Android.
- Siapkan konfigurasi Google iOS melalui Mac/Xcode.
- Deploy Hosting dan Firestore rules setelah konfigurasi Console siap.

Perubahan kode dan dokumentasi belum di-commit oleh AI. User melakukan commit
manual sesuai workflow proyek.

Perubahan belum di-commit oleh AI. User melakukan commit manual sesuai workflow proyek.

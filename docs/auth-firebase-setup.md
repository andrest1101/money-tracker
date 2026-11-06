# Firebase Authentication Setup — Dompetku

Dokumen ini mencatat konfigurasi Firebase yang dipakai build Android Dompetku.
Jangan mengedit `android/app/google-services.json` secara manual; unduh ulang
dari Firebase agar OAuth client dan package name tetap cocok.

## Project dan app

- Project ID: `money-tracker-e22c0`
- Android app: **Dompetku Android**
- Package name: `com.example.savu`
- Android App ID: `1:671219337997:android:fca6b6a8d030d5831abe44`
- Web App ID: `1:671219337997:web:ebfaf2fd767242471abe44`

App Android lama bernama `money_tracker` dengan package
`com.example.money_tracker` masih ada di project untuk kompatibilitas instalasi
lama. **Jangan memakai konfigurasi app lama untuk build Dompetku saat ini.** File
`google-services.json` memuat kedua client, dan Gradle memilih client yang
package-nya cocok dengan `applicationId`.

## SHA certificate

SHA berikut terdaftar pada app **Dompetku Android**:

- SHA-1: `9B:B1:5F:0F:10:F9:88:D0:14:C5:DA:EF:72:5E:15:87:33:7F:5E:09`
- SHA-256: `0C:05:57:4A:86:A8:8D:BE:92:B3:15:FA:78:14:65:C6:1B:90:FF:47:08:94:12:E6:8F:AF:F1:9D:31:CE:A9:BE`

Nilai tersebut berasal dari debug keystore di mesin pengembangan saat ini.
Build debug **dan** release saat ini sama-sama memakai debug keystore
(`signingConfig = signingConfigs.getByName("debug")`). Sebelum distribusi:

1. Buat release keystore.
2. Konfigurasikan signing release dari `android/key.properties`.
3. Daftarkan SHA-1/SHA-256 release ke app Dompetku Android.
4. Unduh ulang `google-services.json`.

## Provider yang aktif

- Email/Password
- Google
- Anonymous

Email link (passwordless) memerlukan domain berikut di
**Authentication → Settings → Authorized domains**:

- `money-tracker-e22c0.firebaseapp.com`
- `money-tracker-e22c0.web.app`

Untuk email/password, SHA Android tidak berpengaruh. Jika login gagal, periksa
apakah akun sudah terdaftar, password benar, dan provider Email/Password aktif
di project yang sama.

## Reset password

- Email reset memakai `handleCodeInApp: true`; link dibuka di Dompetku atau browser fallback.
- Link membawa `oobCode` dengan `mode=resetPassword`.
- Dompetku memverifikasi `oobCode` dengan `verifyPasswordResetCode`, lalu mengganti password dengan `confirmPasswordReset`.
- Setelah berhasil, aplikasi menampilkan layar **Password berhasil diganti** dan tombol **Lanjutkan ke Dompetku**.
- Tidak ada tombol Continue bawaan Firebase.
- Jika App Links belum terverifikasi, link membuka web Dompetku; halaman web yang sama tetap dapat menyelesaikan reset password.
- Aplikasi tetap mendukung link lama `/finishSignIn?from=password_reset&status=success` untuk kompatibilitas.
- Instalasi apk debug/release harus memakai fingerprint yang sama dengan `web/.well-known/assetlinks.json`.
- Fingerprint yang dipakai sekarang sama dengan build debug yang juga dipakai release saat ini:
- Setelah mengubah fingerprint, deploy hosting:

```powershell
firebase deploy --only hosting --project money-tracker-e22c0
```

- Jika App Links belum terverifikasi, Continue mungkin membuka browser atau menampilkan
  chooser; solusinya adalah deploy assetlinks yang cocok atau pilih Dompetku dari chooser.

## Regenerasi konfigurasi

```powershell
firebase apps:sdkconfig android 1:671219337997:android:fca6b6a8d030d5831abe44 `
  --out android/app/google-services.json `
  --project money-tracker-e22c0
```

Jika App ID berubah, perbarui juga:

- `lib/firebase_options.dart` → `DefaultFirebaseOptions.android.appId`
- `firebase.json` → `flutter.platforms.android.default.appId` dan
  `flutter.platforms.dart.configurations.android`

## Verifikasi cepat

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -storepass android -alias androiddebugkey
firebase apps:android:sha:list 1:671219337997:android:fca6b6a8d030d5831abe44 `
  --project money-tracker-e22c0
```

Nilai SHA-1 dari kedua perintah harus sama.

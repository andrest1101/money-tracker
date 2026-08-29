<div align="center">

# 💰 MoneyTracker

### 📊 Catat lebih cepat. Atur lebih cerdas. Capai target lebih konsisten.

Aplikasi pencatat keuangan pribadi untuk mahasiswa, anak kos, dan siapa pun
yang ingin memahami ke mana uangnya pergi.

[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#-platform-dan-kompatibilitas) [![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/) [![License](https://img.shields.io/badge/License-Not%20Specified-lightgrey)](#-lisensi) [![Status](https://img.shields.io/badge/Status-Active%20Development-00B894)](#-status-proyek)

</div>

<div align="center">

> Satu tempat untuk mencatat pemasukan, mengendalikan pengeluaran, menjaga
> anggaran, dan membangun target tabungan secara bertahap.

</div>

## 🧭 Daftar Isi

- [Tentang MoneyTracker](#-tentang-moneytracker)
- [Fitur Utama](#-fitur-utama)
- [Teknologi yang Digunakan](#️-teknologi-yang-digunakan)
- [Arsitektur dan Struktur Proyek](#️-arsitektur-dan-struktur-proyek)
- [Prasyarat](#-prasyarat)
- [Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
- [Konfigurasi Firebase](#-konfigurasi-firebase)
- [Email Link dan Android App Links](#-email-link-dan-android-app-links)
- [Testing dan Quality Check](#-testing-dan-quality-check)
- [Build dan Deployment](#-build-dan-deployment)
- [Keamanan Data](#-keamanan-data)
- [Roadmap](#️-roadmap)
- [Kontributor dan Author](#-kontributor-dan-author)
- [Lisensi](#-lisensi)

## 📱 Platform dan Kompatibilitas

- **Android:** platform utama dan sudah diverifikasi melalui debug APK.
- **Web:** tersedia untuk Firebase Hosting dan pengujian Google Sign-In.
- **Windows:** build debug tersedia untuk pengujian desktop.
- **iOS:** konfigurasi dasar tersedia; Google Sign-In dan deep link tetap perlu
  divalidasi menggunakan macOS dan Xcode.

## 🚀 Tentang MoneyTracker

MoneyTracker adalah aplikasi mobile berbasis Flutter dan Firebase yang dibuat
untuk membantu pengguna mencatat transaksi tanpa proses yang panjang. Fokus
utamanya adalah mengurangi kebiasaan lupa mencatat, mendeteksi pengeluaran yang
mulai berlebihan, dan membuat target tabungan terasa lebih terukur.

### 🎯 Tujuan Produk

- Memungkinkan pengguna menambahkan transaksi dalam hitungan detik.
- Menampilkan ringkasan saldo dan kondisi anggaran secara mudah dipahami.
- Mengubah data transaksi menjadi insight keuangan yang praktis.
- Membantu pengguna menyisihkan dana untuk target seperti UKT, gadget, atau
  dana darurat.
- Menjaga data setiap pengguna tetap terisolasi dan tidak tercampur.

### 🔄 Alur Penggunaan Utama

1. Pengguna membuka aplikasi dan memilih metode autentikasi.
2. Pengguna melihat saldo, anggaran aktif, chart, dan insight pada Dashboard.
3. Pengguna menambahkan pemasukan atau pengeluaran melalui Quick Add.
4. Data transaksi disimpan ke Firestore pada ruang milik user tersebut.
5. Dashboard memperbarui ringkasan, chart, dan status anggaran secara otomatis.
6. Pengguna mengalokasikan sebagian saldo ke target tabungan.

## ✨ Fitur Utama

### 🔐 Autentikasi dan Manajemen Akun

- Login dan registrasi menggunakan email/password melalui Firebase
  Authentication.
- Verifikasi email wajib untuk akun email/password sebelum Dashboard dibuka.
- Email link login tanpa password dengan fallback copy-paste jika perangkat
  belum mendukung App Links.
- Google Sign-In untuk Android melalui Firebase Authentication.
- Google Sign-In Web menggunakan Firebase popup.
- Guest account untuk mencoba aplikasi tanpa registrasi panjang.
- Account linking agar akun guest dapat diamankan dengan Google atau email
  tanpa memindahkan UID dan data yang sudah ada.
- Logout dan ganti akun melalui halaman Settings.
- Reset password untuk akun email/password.

### 💸 Pencatatan Keuangan

- Catat pemasukan seperti uang kiriman, beasiswa, atau gaji part-time.
- Catat pengeluaran seperti makanan, transportasi, kos, tagihan, dan hiburan.
- Quick Add berbentuk bottom sheet agar input tetap cepat.
- Format nominal Rupiah dengan pemisah ribuan saat mengetik.
- Kategori transaksi umum dan kategori custom.
- Pilih tanggal transaksi dengan default tanggal hari ini.
- Tambahkan catatan opsional pada setiap transaksi.
- Edit transaksi yang salah dicatat.
- Hapus transaksi melalui tombol atau gesture swipe.

### 📊 Dashboard dan Insight Keuangan

- Ringkasan saldo dari total pemasukan dikurangi total pengeluaran.
- Perhitungan mengikuti bulan atau siklus anggaran aktif.
- Donut chart pengeluaran berdasarkan kategori.
- Chart interaktif dengan detail kategori saat dipilih.
- Status anggaran tiga tingkat: aman, siaga, dan terlampaui.
- Peringatan visual saat penggunaan anggaran mencapai minimal 80 persen.
- Budget cycle yang dapat dimulai dari tanggal 1 sampai 28 setiap bulan.
- Proyeksi pengeluaran sampai akhir siklus anggaran.
- Insight perbandingan dengan periode sebelumnya.
- Empty state informatif untuk pengguna yang belum memiliki transaksi.

### 🎯 Target Tabungan

- Buat target tabungan dengan nominal tujuan dan deadline.
- Lihat progress setiap target melalui indikator visual.
- Alokasikan dana dari saldo utama ke target secara atomik.
- Tolak alokasi jika melebihi saldo tersedia atau sisa target.
- Edit nominal alokasi dari halaman History maupun Savings.
- Tarik seluruh alokasi dengan konfirmasi dan pemulihan saldo otomatis.
- Lihat ringkasan serta riwayat aktivitas alokasi.
- Pisahkan target aktif dan target selesai.
- Tampilkan status target tercapai, deadline dekat, atau deadline terlewat.
- Urutkan target berdasarkan terbaru, terlama, atau progress.

### 🧾 Riwayat dan Manajemen Data

- Kelompokkan transaksi berdasarkan tanggal secara descending.
- Cari transaksi berdasarkan catatan atau informasi terkait.
- Filter berdasarkan kategori transaksi.
- Filter berdasarkan pemasukan, pengeluaran, atau siklus anggaran aktif.
- Buka ringkasan harian berisi pemasukan, pengeluaran, dan selisih bersih.
- Ekspor transaksi ke CSV melalui system share sheet.
- Hapus seluruh transaksi dan target dengan konfirmasi berlapis.

### 🎨 Personalisasi dan Pengalaman Pengguna

- Tema Sistem, Terang, dan Gelap.
- Privacy Mode untuk menyamarkan saldo pada Dashboard.
- Nama pengguna dan tipe profil keuangan.
- Status sinkronisasi Firestore dengan waktu pembaruan terakhir.
- Aksi retry ketika sinkronisasi mengalami kegagalan.
- Help Center dan FAQ interaktif.
- Layout responsif untuk layar Android berukuran kecil.

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi | Peran |
| --- | --- | --- |
| Framework | Flutter 3.32+ | Membangun aplikasi lintas platform dengan satu codebase |
| Bahasa | Dart 3.8+ | Bahasa utama aplikasi |
| State Management | Riverpod 3 | Mengelola state dan dependency injection |
| Authentication | Firebase Authentication | Login email, Google, email link, dan guest |
| Database | Cloud Firestore | Menyimpan transaksi dan target secara real-time |
| Local Storage | SharedPreferences | Menyimpan tema, budget, privacy, dan preferensi sederhana |
| Chart | fl_chart 1.0.0 | Menampilkan donut chart pengeluaran |
| Sharing | share_plus | Membagikan file CSV melalui system share sheet |
| Deep Link | app_links | Menerima email link pada Android dan platform terkait |
| Testing | flutter_test | Unit test dan widget test |

> Project ini menggunakan **Riverpod**, bukan package Provider atau BLoC.
> Riverpod dipakai untuk Notifier, AsyncValue, provider dependency injection,
> dan koneksi state antara domain, data, serta presentation.

## 🏗️ Arsitektur dan Struktur Proyek

MoneyTracker menerapkan Clean Architecture agar tampilan, aturan bisnis, dan
akses database tidak tercampur. Ibarat sebuah restoran, **Presentation** adalah
pelayan, **Domain** adalah resep dan aturan masakan, sedangkan **Data** adalah
dapur yang berkomunikasi dengan pemasok atau database.

### 🧱 Struktur Direktori Utama

```text
money_tracker/
├── android/                         # Konfigurasi dan resource Android
├── ios/                             # Konfigurasi dan resource iOS
├── linux/                           # Konfigurasi desktop Linux
├── macos/                           # Konfigurasi desktop macOS
├── web/                             # Entry point Flutter Web dan Hosting
│   └── .well-known/assetlinks.json  # Verifikasi Android App Links
├── windows/                         # Konfigurasi desktop Windows
├── lib/
│   ├── main.dart                    # Bootstrap Firebase, Riverpod, dan AuthGate
│   ├── firebase_options.dart        # Konfigurasi Firebase hasil FlutterFire
│   ├── core/                        # Infrastruktur lintas fitur
│   │   ├── firebase/                # Firebase dan provider auth
│   │   ├── local_storage/            # SharedPreferences dan settings provider
│   │   ├── navigation/               # App shell dan NavigationBar
│   │   └── utils/                    # Formatter tanggal dan nominal
│   └── features/                    # Modul fitur aplikasi
│       ├── auth/                    # Landing page dan email verification
│       ├── dashboard/               # Summary, budget, chart, dan insight
│       ├── savings/                 # Target dan alokasi tabungan
│       ├── settings/                # Pengaturan dan manajemen data
│       └── transactions/            # Quick Add, History, filter, dan CSV
├── test/                            # Unit test dan widget test
├── firestore.rules                  # Firestore Security Rules
├── firebase.json                    # Konfigurasi Firebase Hosting dan Rules
├── pubspec.yaml                     # Dependency dan metadata Flutter
└── README.md                        # Dokumentasi project
```

### 🧩 Pola Layer pada Setiap Fitur

```text
feature/
├── domain/
│   ├── entities/                    # 🧱 Objek bisnis murni
│   ├── repositories/                # 📜 Kontrak repository
│   └── usecases/                    # 🧠 Aturan bisnis dan kalkulasi
├── data/
│   ├── models/                      # 🔄 Konversi entity ke/dari JSON
│   ├── repositories/                # ☁️ Implementasi Firestore
│   └── providers/                   # 🔌 Dependency injection data layer
└── presentation/
    ├── pages/                       # 📱 Halaman utama fitur
    ├── providers/                   # 🔄 Notifier dan state UI
    └── widgets/                     # 🧱 Komponen UI yang reusable
```

- **Domain** tidak bergantung pada Flutter UI atau Firebase.
- **Data** menerjemahkan data Firestore menjadi entity yang dipahami domain.
- **Presentation** menampilkan state dan meneruskan aksi pengguna ke use case
  atau controller.
- Use case dapat diuji secara terpisah tanpa membutuhkan koneksi Firebase.

## 📋 Prasyarat

- Flutter SDK versi 3.32 atau lebih baru.
- Dart SDK versi 3.8 atau lebih baru.
- Android Studio atau VS Code dengan Flutter extension.
- Android SDK untuk menjalankan aplikasi Android.
- Firebase CLI jika ingin melakukan deployment.
- FlutterFire CLI jika ingin menghasilkan ulang konfigurasi Firebase.
- Akun Firebase dengan project yang aktif.

## 🚀 Cara Menjalankan Aplikasi

### 1️⃣ Clone Repository

```bash
git clone <URL_REPOSITORY>
cd money_tracker
```

- Ganti `<URL_REPOSITORY>` dengan URL repository GitHub project.
- Gunakan branch yang sesuai dengan kebutuhan pengembangan.

### 2️⃣ Periksa Environment Flutter

```bash
flutter doctor
```

- Pastikan tidak ada masalah kritis pada Flutter SDK dan Android toolchain.
- Hubungkan emulator atau perangkat Android untuk pengujian.

### 3️⃣ Pasang Dependency

```bash
flutter pub get
```

- Perintah ini membaca `pubspec.yaml` dan mengunduh seluruh dependency.
- `pubspec.lock` menjaga versi dependency tetap konsisten.

### 4️⃣ Jalankan Aplikasi

```bash
flutter run
```

- Untuk memilih device tertentu, jalankan `flutter devices` terlebih dahulu.
- Untuk menjalankan pada device tertentu, gunakan `flutter run -d <device_id>`.

## 🔥 Konfigurasi Firebase

### 🆔 Project Firebase

Project saat ini menggunakan Firebase project:

```text
money-tracker-e22c0
```

### 📱 Android

- `android/app/google-services.json` diperlukan oleh Firebase Android SDK.
- Package name aplikasi adalah `com.example.money_tracker`.
- Daftarkan SHA-1 dan SHA-256 debug maupun release di Firebase Console.
- Aktifkan provider Anonymous, Email/Password, Google, dan Email Link sesuai
  kebutuhan aplikasi.

### 🍎 iOS

- Tambahkan `GoogleService-Info.plist` ke target Runner.
- Pastikan bundle ID Firebase dan Xcode sama.
- Tambahkan `REVERSED_CLIENT_ID` untuk Google Sign-In.
- Validasi build dan deep link iOS membutuhkan macOS dan Xcode.

### 🌐 Web

- Tambahkan domain Hosting ke Authorized domains pada Firebase Authentication.
- Gunakan domain `money-tracker-e22c0.web.app` untuk action link.
- Firebase Hosting membaca hasil build dari folder `build/web`.

### 🗄️ Firestore

- Buat atau aktifkan Cloud Firestore pada Firebase Console.
- Deploy rules dari file `firestore.rules` sebelum dipakai banyak user.
- Data baru memakai path `users/{uid}/transactions` dan
  `users/{uid}/savings_goals`.
- Collection root legacy tidak dibuka untuk akses client.

## 🔗 Email Link dan Android App Links

Email link dirancang agar link dari Gmail dapat membuka aplikasi Android secara
langsung, bukan hanya login pada browser.

### 🔄 Cara Kerja

1. User memasukkan email pada mode Email Link.
2. Firebase mengirim action link ke email tersebut.
3. Android mengenali host `money-tracker-e22c0.web.app` melalui intent-filter.
4. `app_links` meneruskan URL ke Flutter saat app terbuka atau baru dimulai.
5. AuthController memproses link dan membuat sesi login.
6. Jika App Links belum aktif, user masih dapat menyalin link dan menempelnya
   ke fallback form.

### 🧰 File Konfigurasi

- `android/app/src/main/AndroidManifest.xml` berisi intent-filter Android.
- `web/.well-known/assetlinks.json` memverifikasi aplikasi Android pada domain.
- `lib/main.dart` menerima initial link dan link saat runtime.
- `lib/core/firebase/auth_providers.dart` menyelesaikan kredensial email link.

### ⚠️ Catatan Production

- Fingerprint debug tersedia untuk pengujian lokal.
- Tambahkan SHA-256 keystore release ke `assetlinks.json` sebelum distribusi.
- Deploy Hosting agar file `.well-known/assetlinks.json` dapat diakses publik.
- Setelah install APK, uji link langsung dari Gmail pada perangkat Android.

## 🧪 Testing dan Quality Check

### 🔍 Static Analysis

```bash
flutter analyze
```

- Pemeriksaan terakhir project lulus tanpa issue.

### 🧪 Test Suite

```bash
flutter test
```

- Suite terakhir berisi 52 test yang lulus.
- Test mencakup use case budget, filter, alokasi, insight, formatter, dan
  widget utama.

### 📱 Build Verification

```bash
flutter build apk --debug
flutter build web
flutter build windows --debug
```

- APK debug digunakan untuk validasi Android.
- Web build digunakan sebelum Firebase Hosting deployment.
- Windows build membantu memastikan kompatibilitas desktop.

## 📦 Build dan Deployment

### 🤖 Build Android Debug

```bash
flutter build apk --debug
```

### 📱 Build Android Release

```bash
flutter build appbundle --release
```

- Gunakan release keystore sendiri.
- Jangan memakai debug signing untuk distribusi production.
- Pastikan SHA-256 release sudah terdaftar di Firebase dan App Links.

### 🌐 Deploy Firebase Hosting dan Rules

```bash
flutter build web
firebase deploy --only hosting,firestore:rules
```

- Hosting mengambil file dari `build/web`.
- Firestore Rules membatasi akses berdasarkan `request.auth.uid`.
- Periksa file App Links setelah deploy:
  `https://money-tracker-e22c0.web.app/.well-known/assetlinks.json`.

## 🔐 Keamanan Data

- Setiap operasi transaksi memakai user Firebase yang sedang aktif.
- Transaksi berada di `users/{uid}/transactions`.
- Target berada di `users/{uid}/savings_goals`.
- Firestore Rules hanya mengizinkan user mengakses dokumen miliknya sendiri.
- Collection global legacy ditutup dari akses client.
- Password diproses Firebase Authentication dan tidak disimpan di Firestore.
- Operasi alokasi menggunakan batch atau transaction untuk mencegah data goal
  dan transaksi menjadi tidak konsisten.
- Penghapusan target dengan banyak riwayat memakai batch berukuran aman.
- Privacy Mode hanya menyamarkan nominal pada Dashboard dan tidak mengubah
  data asli atau nominal di History.

## 🗺️ Roadmap

- Dashboard saldo dan ringkasan keuangan.
- Quick Add pemasukan dan pengeluaran.
- Budget limit dan overspending alert.
- Target tabungan dan alokasi atomik.
- History dengan edit, hapus, search, dan filter.
- Settings premium dengan tema dan privacy mode.
- Firebase Authentication dan user-scoped Firestore.
- Email verification dan email link flow.
- Android App Links untuk email link.
- Validasi manual Google Sign-In Web dan Android pada environment production.
- Konfigurasi Google Sign-In iOS.
- Migrasi data lama dari collection global jika masih diperlukan.
- Peningkatan visual background, warna, spacing, typography, dan micro-
  interaction secara bertahap.

## 🤝 Kontributor dan Author

- **Author:** Andre Robert
- **Product:** MoneyTracker
- Untuk kontribusi, buat branch fitur, tambahkan test yang sesuai, lalu ajukan
  pull request dengan deskripsi perubahan yang jelas.

## 📄 Lisensi

- Tambahkan file `LICENSE` dan ubah badge di bagian atas README setelah jenis
  lisensi project diputuskan.

## 🙏 Apresiasi

- Terima kasih kepada komunitas Flutter dan Firebase.
- Terima kasih kepada setiap pengguna yang membantu menguji flow autentikasi,
  deep link, dan responsivitas aplikasi.
- MoneyTracker dikembangkan secara bertahap dengan fokus pada pengalaman
  pengguna yang sederhana, aman, dan bermanfaat.

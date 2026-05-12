# Flowin — Setup & Build Guide

## 1. PRASYARAT

- Flutter SDK (≥ 3.4.0) sudah terinstall
- Akun Supabase: https://supabase.com
- Android Studio / VS Code dengan Flutter extension
- Java 17+ (untuk build APK)

---

## 2. SETUP SUPABASE

### A. Buat Proyek Supabase
1. Login ke https://app.supabase.com
2. Klik **New Project** → isi nama, database password, dan region
3. Tunggu proyek selesai dibuat

### B. Jalankan SQL Schema
1. Buka **SQL Editor** di Supabase Dashboard
2. Copy seluruh isi file `supabase_schema.sql`
3. Paste dan klik **Run**

### C. Konfigurasi Auth
1. Buka **Authentication → Settings**
2. Pastikan **Email Provider** aktif
3. (Opsional) Nonaktifkan **Confirm email** untuk testing

### D. Dapatkan Credentials
1. Buka **Project Settings → API**
2. Copy nilai:
   - **Project URL** (`https://xxxxx.supabase.co`)
   - **anon public** key

---

## 3. KONFIGURASI APP

### Edit `lib/main.dart`
Ganti placeholder dengan credentials Supabase kamu:

```dart
const _supabaseUrl = 'https://xxxxx.supabase.co';      // ← ganti ini
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5...'; // ← ganti ini
```

---

## 4. SETUP ASSETS (WAJIB)

Pastikan file-file ini sudah ada di posisi yang benar:

```
assets/
├── icon/
│   └── flowin.png      ← PNG 1024x1024 (untuk launcher icon)
└── logo/
    └── flowin.svg      ← SVG logo (sudah ada placeholder)
```

**Copy file icon kamu:**
```
# Salin icon 1024x1024 ke folder yang benar
copy path\ke\flowin.png assets\icon\flowin.png
```

---

## 5. INSTALL DEPENDENCIES

```bash
flutter pub get
```

---

## 6. GENERATE LAUNCHER ICON

Setelah `assets/icon/flowin.png` sudah ada:

```bash
dart run flutter_launcher_icons
```

Ini akan generate icon untuk Android dan iOS secara otomatis.

---

## 7. JALANKAN APP (DEBUG)

```bash
# Sambungkan device Android / emulator
flutter run
```

---

## 8. BUILD RELEASE APK

### A. (Opsional) Buat Keystore untuk signing
```bash
keytool -genkey -v -keystore android\app\flowin-keystore.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias flowin
```

### B. Buat `android/key.properties`
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=flowin
storeFile=flowin-keystore.jks
```

### C. Edit `android/app/build.gradle.kts`
Tambahkan signing config (lihat dokumentasi Flutter untuk detail).

### D. Build APK
```bash
# APK universal (semua arsitektur)
flutter build apk --release

# APK per arsitektur (lebih kecil, direkomendasikan)
flutter build apk --split-per-abi --release
```

Output APK:
- `build\app\outputs\flutter-apk\app-release.apk` (universal)
- `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` (64-bit)
- `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk` (32-bit)

### E. Build App Bundle (untuk Play Store)
```bash
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

---

## 9. STRUKTUR PROYEK

```
lib/
├── main.dart                          # Entry point, init Supabase
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Warna tema (dark)
│   │   ├── app_strings.dart           # Semua teks UI (Bahasa Indonesia)
│   │   └── app_theme.dart             # ThemeData konfigurasi
│   ├── router/
│   │   └── app_router.dart            # go_router konfigurasi
│   └── utils/
│       ├── currency_formatter.dart    # Format Rupiah
│       └── date_formatter.dart        # Format tanggal Indonesia
├── domain/
│   ├── models/
│   │   └── transaction_model.dart     # Model transaksi
│   └── repositories/
│       ├── auth_repository.dart       # Interface auth
│       └── transaction_repository.dart # Interface transaksi
├── data/
│   └── repositories/
│       ├── auth_repository_impl.dart  # Implementasi Supabase Auth
│       └── transaction_repository_impl.dart # Implementasi CRUD
└── presentation/
    ├── providers/
    │   ├── repository_providers.dart  # Provider Riverpod
    │   ├── auth_provider.dart         # State auth
    │   └── transaction_provider.dart  # State transaksi
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── shell/
    │   │   └── shell_screen.dart      # Bottom nav + FAB
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart  # Beranda
    │   ├── transaction/
    │   │   ├── transaction_screen.dart
    │   │   └── add_edit_transaction_screen.dart
    │   ├── analytics/
    │   │   └── analytics_screen.dart  # Grafik
    │   └── profile/
    │       └── profile_screen.dart
    └── widgets/
        ├── transaction_card.dart      # Kartu transaksi (swipeable)
        ├── empty_state.dart           # Empty state UI
        └── loading_overlay.dart       # Loading indicator
```

---

## 10. FITUR LENGKAP

| Fitur | Status |
|-------|--------|
| Login / Register | ✅ |
| Persistent session | ✅ |
| Tambah transaksi | ✅ |
| Edit transaksi (tap) | ✅ |
| Hapus transaksi (swipe) | ✅ |
| Filter Semua/Pemasukan/Pengeluaran | ✅ |
| Saldo total bulan ini | ✅ |
| 5 transaksi terbaru di Beranda | ✅ |
| Bar chart ringkasan bulanan | ✅ |
| Pie chart income vs expense | ✅ |
| Bar chart 6 bulan terakhir | ✅ |
| Dark theme | ✅ |
| Plus Jakarta Sans font | ✅ |
| Bahasa Indonesia | ✅ |
| SafeArea + responsive layout | ✅ |
| No scrollbar visible | ✅ |
| No debug banner | ✅ |
| Loading states | ✅ |
| Error handling | ✅ |
| Empty state design | ✅ |

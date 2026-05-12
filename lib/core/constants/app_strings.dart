class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Flowin';

  // Auth
  static const String masukAkun = 'Masuk Akun';
  static const String buatAkun = 'Buat Akun';
  static const String email = 'Email';
  static const String password = 'Kata Sandi';
  static const String konfirmasiPassword = 'Konfirmasi Kata Sandi';
  static const String masuk = 'Masuk';
  static const String daftar = 'Daftar';
  static const String namaLengkap = 'Nama Lengkap';
  static const String namaWajibDiisi = 'Nama wajib diisi';
  static const String belumPunyaAkun = 'Belum punya akun? ';
  static const String sudahPunyaAkun = 'Sudah punya akun? ';
  static const String loginSekarang = 'Masuk sekarang';
  static const String daftarSekarang = 'Daftar sekarang';
  static const String keluar = 'Keluar';
  static const String konfirmasiKeluar = 'Konfirmasi Keluar';
  static const String pesanKeluar = 'Apakah kamu yakin ingin keluar?';
  static const String batal = 'Batal';

  // Navigation
  static const String beranda = 'Beranda';
  static const String transaksi = 'Transaksi';
  static const String analitik = 'Analitik';
  static const String profil = 'Profil';
  static const String tambah = 'Tambah';

  // Dashboard
  static const String saldoTotal = 'Saldo Total';
  static const String totalPemasukan = 'Total Pemasukan';
  static const String totalPengeluaran = 'Total Pengeluaran';
  static const String transaksiTerbaru = 'Transaksi Terbaru';
  static const String lihatSemua = 'Lihat Semua';
  static const String ringkasanBulanan = 'Ringkasan Bulanan';
  static const String halo = 'Halo,';
  static const String selamatDatang = 'Selamat datang kembali!';

  // Transaction
  static const String tambahTransaksi = 'Tambah Transaksi';
  static const String editTransaksi = 'Edit Transaksi';
  static const String hapusTransaksi = 'Hapus Transaksi';
  static const String konfirmasiHapus = 'Konfirmasi Hapus';
  static const String pesanHapus =
      'Apakah kamu yakin ingin menghapus transaksi ini?';
  static const String hapus = 'Hapus';
  static const String simpan = 'Simpan';
  static const String judul = 'Judul';
  static const String jumlah = 'Jumlah';
  static const String jenis = 'Jenis';
  static const String kategori = 'Kategori';
  static const String tanggal = 'Tanggal';
  static const String pemasukan = 'Pemasukan';
  static const String pengeluaran = 'Pengeluaran';
  static const String semua = 'Semua';
  static const String geserUntukHapus = 'Geser untuk hapus';

  // Categories — Pengeluaran
  static const List<String> kategorisPengeluaran = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja & Fashion',
    'Tagihan & Utilitas',
    'Hiburan & Rekreasi',
    'Kesehatan',
    'Pendidikan',
    'Perawatan Diri',
    'Rumah Tangga',
    'Donasi & Sedekah',
    'Lainnya',
  ];

  // Categories — Pemasukan
  static const List<String> kategorisPemasukan = [
    'Gaji',
    'Freelance',
    'Bisnis & Usaha',
    'Investasi',
    'Bonus',
    'Hadiah',
    'Penjualan',
    'Sewa',
    'Lainnya',
  ];

  // Helper: gabungan semua kategori (untuk filter/analytics)
  static List<String> get semuaKategori =>
      [...kategorisPemasukan, ...kategorisPengeluaran];

  // Analytics
  static const String analitikKeuangan = 'Analitik Keuangan';
  static const String pemasukanVsPengeluaran = 'Pemasukan vs Pengeluaran';
  static const String ringkasanPerBulan = 'Ringkasan Per Bulan';

  // Profile
  static const String profilSaya = 'Profil Saya';
  static const String informasiAkun = 'Informasi Akun';
  static const String versiAplikasi = 'Versi Aplikasi';

  // Empty state
  static const String belumAdaTransaksi = 'Belum Ada Transaksi';
  static const String pesan_belumAdaTransaksi =
      'Tambahkan transaksi pertama kamu dengan menekan tombol + di bawah.';

  // Error
  static const String kesalahan = 'Terjadi kesalahan';
  static const String coba_lagi = 'Coba Lagi';
  static const String emailTidakValid = 'Email tidak valid';
  static const String passwordMin6 = 'Kata sandi minimal 6 karakter';
  static const String passwordTidakCocok = 'Kata sandi tidak cocok';
  static const String judulWajibDiisi = 'Judul wajib diisi';
  static const String jumlahHarusLebihDariNol = 'Jumlah harus lebih dari 0';
  static const String kategoriWajibDipilih = 'Kategori wajib dipilih';

  // Loading
  static const String memuat = 'Memuat...';
  static const String menyimpan = 'Menyimpan...';
}

# Attendify

Attendify adalah aplikasi absensi berbasis Flutter yang dikembangkan sebagai bagian dari tes rekrutmen untuk PT Trimitra Putra Mandiri.




## Deskripsi Project

Project ini bertujuan untuk mendemonstrasikan kemampuan dalam membangun aplikasi mobile menggunakan Flutter, dengan fitur utama berupa sistem absensi karyawan yang terintegrasi dengan backend API.

## 📱 Tutorial Penggunaan Aplikasi

### **1. Registrasi & Login**

#### **Registrasi Akun Baru:**

1. Buka aplikasi Attendify
2. Klik tombol "Sign up" di halaman login
3. Isi form registrasi:
   - **Username**: Minimal 3 karakter
   - **Email**: Format email yang valid
   - **Password**: Minimal 6 karakter
   - **Confirm Password**: Harus sama dengan password
   - **Gender**: Pilih Laki-laki atau Perempuan
4. Klik "REGISTER"
5. Setelah berhasil, akan diarahkan ke halaman login

#### **Login:**

1. Masukkan email dan password
2. Klik "LOGIN"
3. Setelah berhasil, akan masuk ke halaman utama

### **2. Halaman Utama (Dashboard)**

#### **Informasi yang Ditampilkan:**

- **Greeting**: Salam sesuai waktu (Good morning/afternoon/evening/night)
- **Profile**: Foto profil dan nama user
- **Status Kehadiran**: "Attended" atau "Not Attended" dapat diklik untuk detailnya
- **Jarak dari Kantor**: Real-time distance dalam meter
- **Waktu**: Tanggal dan jam saat ini
- **Riwayat Absensi**: Daftar absensi terbaru

#### **Fitur Dashboard:**

- **Tap Status Kehadiran**: Untuk melihat detail kehadiran hari ini
- **Tap Profile Icon**: Untuk masuk ke halaman profil
- **Swipe Refresh**: Untuk memperbarui data

### **3. Absensi (Check In/Out)**

#### **Akses Halaman Absensi:**

1. Dari halaman utama, klik tombol Floating Action Button
2. Akan masuk ke halaman Maps dengan peta lokasi

#### **Validasi Lokasi:**

- **Jarak Maksimal**: 100 meter dari kantor
- **GPS**: Harus aktif dan izin lokasi diberikan
- **Status**: Ditampilkan real-time (dalam/luar jarak)

#### **Proses Check In:**

1. **Ambil Foto** (Wajib):

   - Klik tombol "Ambil Foto"
   - Gunakan kamera depan
   - Foto akan ditampilkan dengan status "Sudah terupload"

2. **Check In**:
   - Pastikan dalam jarak ≤ 100m dari kantor
   - Klik tombol "Check In"
   - Tunggu proses selesai
   - Akan muncul notifikasi sukses

#### **Proses Check Out:**

1. **Validasi**: Harus sudah check in hari ini
2. **Lokasi**: Pastikan dalam jarak ≤ 100m dari kantor
3. **Check Out**: Klik tombol "Check Out"
4. **Selesai**: Akan muncul snackbar sukses

### **4. Pengajuan Izin**

#### **Cara Mengajukan Izin:**

1. Dari halaman Maps, klik tombol "Ajukan Izin"
2. Pilih tanggal izin (maksimal 30 hari ke depan)
3. Isi alasan izin (minimal 10 karakter)
4. Klik "Ajukan Izin"
5. Akan muncul snackbar sukses

### **5. Riwayat Absensi**

#### **Akses Riwayat:**

1. Dari halaman utama, scroll ke bagian "Riwayat Absensi"
2. Atau klik salah satu daftar kehadiran untuk detail

#### **Informasi yang Ditampilkan:**

- **Tanggal**: Hari dan tanggal absensi
- **Status**: Present, Late, Permission, atau Izin
- **Check In Time**: Jam masuk
- **Check Out Time**: Jam keluar
- **Badge**: Warna sesuai status (Hijau=Present, Merah=Late, Orange=Permission)

#### **Detail Absensi:**

1. Klik item riwayat untuk melihat detail
2. Informasi lengkap:
   - Tanggal dan waktu
   - Lokasi check in/out
   - Alamat lengkap
   - Foto check in
   - Status kehadiran

### **6. Profil Pengguna**

#### **Akses Profil:**

1. Dari halaman utama, klik icon profil di pojok kanan atas
2. Akan masuk ke halaman profil

#### **Fitur Profil:**

- **Edit Nama**: Klik icon edit di AppBar
- **Update Foto**: Klik icon kamera di foto profil
- **Informasi**: Nama, email, gender
- **Logout**: Klik tombol logout di bagian bawah

### **7. Fitur Tambahan**

#### **Refresh Data:**

- **Pull to Refresh**: Di halaman utama
- **Manual Refresh**: Klik icon refresh di maps

#### **Snackbar/Informasi:**

- **Sukses**: Background hijau
- **Error**: Background merah
- **Warning**: Background orange/kuning

#### **Validasi:**

- **Jarak**: Maksimal 100m dari kantor
- **Foto**: Wajib untuk check in
- **Lokasi**: GPS harus aktif
- **Internet**: Koneksi stabil untuk API

### **8. Troubleshooting**

#### **Masalah Umum:**

**GPS Tidak Terdeteksi:**

- Pastikan GPS aktif
- Berikan izin lokasi ke aplikasi
- Restart aplikasi

**Jarak Terlalu Jauh:**

- Pastikan berada dalam radius 100m dari kantor
- Cek koordinat kantor di settings

**Foto Tidak Bisa Diambil:**

- Berikan izin kamera ke aplikasi
- Pastikan kamera tidak digunakan aplikasi lain

**Login Gagal:**

- Cek koneksi internet
- Pastikan email dan password benar
- Coba registrasi ulang jika perlu

**API Error:**

- Cek koneksi internet
- Pastikan backend server aktif
- Hubungi admin jika masalah berlanjut

---

## Kekurangan Teknis

- **API Masih Menggunakan Port Forwarding (Ngrok):**  
  Untuk keperluan pengujian, backend API yang digunakan pada aplikasi ini masih diakses melalui port forwarding menggunakan layanan [ngrok](https://ngrok.com/). Hal ini menyebabkan:

  - Koneksi API tidak stabil dan dapat berubah sewaktu-waktu (URL ngrok bisa expired).
  - Kecepatan akses API bisa terpengaruh oleh koneksi internet dan limitasi ngrok.
  - Tidak direkomendasikan untuk penggunaan production.

- **Belum Ada Deployment Backend Permanen:**  
  Karena backend belum di-deploy secara permanen, aplikasi hanya dapat digunakan selama tunnel ngrok aktif.

## Kelebihan Project

- **UI/UX Modern:**  
  Menggunakan desain antarmuka yang modern dan responsif, dengan komponen yang mudah digunakan.

- **Fitur Absensi Lengkap:**

  - Check-in dan check-out dengan validasi lokasi.
  - Riwayat absensi lengkap dengan detail status (masuk, izin, telat, dsb).

- **Arsitektur Modular:**  
  Struktur kode dipisahkan dengan baik antara layer presentasi, data, dan service, sehingga mudah untuk dikembangkan lebih lanjut.

- **Custom Widget Reusable:**  
  Banyak komponen dibuat sebagai custom widget agar mudah digunakan ulang di berbagai halaman.

- **Validasi Form yang Baik:**  
  Setiap form (register, login, reset password) sudah dilengkapi validasi yang jelas dan user-friendly.

## Catatan

Project ini hanya digunakan untuk keperluan tes dan demonstrasi. Untuk penggunaan production, disarankan untuk:

- Deploy backend API ke server yang stabil.
- Mengganti endpoint API dari ngrok ke domain/hosting permanen.
- Melakukan audit keamanan dan optimasi performa aplikasi.

---

Terima kasih atas kesempatan yang diberikan untuk mengikuti tes ini di PT Trimitra Putra Mandiri.

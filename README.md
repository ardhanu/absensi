# Attendify

Attendify adalah aplikasi absensi berbasis Flutter yang dikembangkan sebagai bagian dari tes rekrutmen untuk PT Trimitra Putra Mandiri.

## Deskripsi Project

Project ini bertujuan untuk mendemonstrasikan kemampuan dalam membangun aplikasi mobile menggunakan Flutter, dengan fitur utama berupa sistem absensi karyawan yang terintegrasi dengan backend API.

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

- **Dukungan Notifikasi:**  
  Sudah terintegrasi dengan OneSignal untuk pengiriman notifikasi (dapat dikembangkan lebih lanjut).

- **Validasi Form yang Baik:**  
  Setiap form (register, login, reset password) sudah dilengkapi validasi yang jelas dan user-friendly.

## Catatan

Project ini hanya digunakan untuk keperluan tes dan demonstrasi. Untuk penggunaan production, disarankan untuk:
- Deploy backend API ke server yang stabil.
- Mengganti endpoint API dari ngrok ke domain/hosting permanen.
- Melakukan audit keamanan dan optimasi performa aplikasi.

---

Terima kasih atas kesempatan yang diberikan untuk mengikuti tes ini di PT Trimitra Putra Mandiri.

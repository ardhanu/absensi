import 'dart:convert';
import 'dart:io';

import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:attendify/presentation/pages/attendance/izin_page.dart';
import 'package:attendify/presentation/widgets/button.dart';

import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? _currentPosition;
  String? _currentAddress;
  GoogleMapController? _mapController;
  bool _loading = true;
  String? _errorMessage;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  Attendance? _todayAbsenResponse;
  File? _checkInPhoto;
  bool _isTakingPhoto = false;

  // Distance validation variables
  double? _distanceFromOffice;
  bool _isWithinAllowedDistance = false;
  String _distanceMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchTodayAttendanceData();
  }

  Future<void> _checkTodayCheckInStatus() async {
    try {
      final todayAttendance = await AttendanceService.getTodayAttendance();
      // Status is now handled in _fetchTodayAttendanceData
    } catch (e) {
      // Error handling is now in _fetchTodayAttendanceData
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // Use MapsServices to get current location
      final position = await MapsServices.getCurrentLocation();
      if (position == null) {
        setState(() {
          _loading = false;
          _errorMessage =
              "Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi diberikan.";
        });
        return;
      }

      setState(() {
        _currentPosition = position;
      });

      await _getAddressFromLatLng(position);

      // Check distance validation
      await _checkDistanceValidation();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      String errorMsg = "Terjadi kesalahan saat mengambil lokasi: $e";
      if (e.toString().contains('MissingPluginException')) {
        errorMsg =
            "Aplikasi tidak dapat mengakses layanan lokasi. Pastikan aplikasi dijalankan di perangkat fisik atau emulator dengan plugin yang benar.";
      } else if (e.toString().contains('timeout')) {
        errorMsg =
            "Timeout saat mengambil lokasi. Pastikan GPS aktif dan coba lagi.";
      }
      setState(() {
        _loading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  Future<void> _checkDistanceValidation() async {
    try {
      final validationResult = await MapsServices.getDistanceAndValidation();
      setState(() {
        _distanceFromOffice = validationResult['distance'];
        _isWithinAllowedDistance = validationResult['isWithinRange'];
        _distanceMessage = validationResult['message'];
      });
    } catch (e) {
      setState(() {
        _distanceFromOffice = null;
        _isWithinAllowedDistance = false;
        _distanceMessage = 'Gagal memvalidasi jarak: $e';
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      // Use MapsServices to get address from coordinates
      final address = await MapsServices.getAddressFromLatLng(position);
      setState(() {
        _currentAddress =
            address ??
            "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Lokasi tidak dapat di-decode";
        _loading = false;
        _errorMessage = "Gagal mendapatkan alamat: $e";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _fetchTodayAttendanceData() async {
    try {
      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final todayAbsenResponse = await AttendanceService.getTodayAttendance(
        date: todayDate,
      );
      setState(() {
        _todayAbsenResponse = todayAbsenResponse;
      });
    } catch (e) {
      setState(() {
        _todayAbsenResponse = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _checkInPhoto = File(photo.path);
          _isTakingPhoto = false;
        });
      } else {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    } catch (e) {
      setState(() {
        _isTakingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    if (_currentAddress == null || _currentAddress!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    if (_currentPosition!.latitude == 0.0 &&
        _currentPosition!.longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koordinat lokasi tidak valid. Coba refresh lokasi.'),
        ),
      );
      return;
    }

    // Validasi jarak dari kantor (maksimal 100 meter)
    if (!_isWithinAllowedDistance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anda berada di luar jarak yang diizinkan untuk absen. Maksimal 100 meter dari kantor.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Pastikan sudah foto sebelum check in
    if (_checkInPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap ambil foto terlebih dahulu sebelum check in!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      try {
        // Convert photo to base64 with proper data URL format
        final bytes = await _checkInPhoto!.readAsBytes();
        final base64String = base64Encode(bytes);

        // Ensure base64 string is valid (length must be multiple of 4)
        String validBase64String = base64String;
        while (validBase64String.length % 4 != 0) {
          validBase64String += '=';
        }

        final base64Photo = 'data:image/jpeg;base64,$validBase64String';

        final response = await AttendanceService.checkIn(
          checkInLocation: "Current Location",
          checkInAddress: _currentAddress!,
          checkInLat: _currentPosition!.latitude,
          checkInLng: _currentPosition!.longitude,
          checkInPhoto: base64Photo,
        );

        await _fetchTodayAttendanceData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check In Berhasil: ${response.status}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } on Exception catch (e) {
        final msg = e.toString();
        // Tangani error dari backend jika sudah check-in hari ini
        if (msg.contains('Already checked in today') || msg.contains('400')) {
          await _fetchTodayAttendanceData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda sudah melakukan absen hari ini'),
              backgroundColor: Colors.yellow[800],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check In Gagal: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    if (_currentAddress == null || _currentAddress!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    // Validasi jarak dari kantor (maksimal 100 meter)
    if (!_isWithinAllowedDistance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anda berada di luar jarak yang diizinkan untuk absen. Maksimal 100 meter dari kantor.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Pastikan sudah check in hari ini
    final attendanceDate = _todayAbsenResponse?.attendanceDate;
    if (attendanceDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Belum check in hari ini, tidak bisa check out!'),
        ),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });
    try {
      final response = await AttendanceService.checkOut(
        attendanceDate: attendanceDate.toIso8601String().substring(0, 10),
        checkOutLocation: "Current Location",
        checkOutAddress: _currentAddress!,
        checkOutLat: _currentPosition!.latitude,
        checkOutLng: _currentPosition!.longitude,
      );

      await _fetchTodayAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check Out Berhasil! Waktu: ${response.checkOut?.toIso8601String() ?? 'Now'}',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check Out Gagal: ${e.toString()}',
                  style: GoogleFonts.lexend(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  Future<void> _handleIzin() async {
    Navigator.pop(context);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const IzinPage()),
    );

    if (result == true && mounted) {
      await _fetchTodayAttendanceData();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current status based on today's attendance data
    bool isCheckedIn = false;
    bool isCheckedOut = false;
    bool isIzin = false;
    bool canCheckIn = true;
    bool canCheckOut = false;

    if (_todayAbsenResponse != null) {
      final data = _todayAbsenResponse!;

      // Check if user has taken leave today
      if (data.status != null && data.status.toLowerCase() == 'izin') {
        isIzin = true;
        canCheckIn = false;
        canCheckOut = false;
      } else {
        // Check if user has checked in today
        if (data.checkIn != null) {
          isCheckedIn = true;
          canCheckIn = false;

          // Check if user has checked out today
          if (data.checkOut != null) {
            isCheckedOut = true;
            canCheckOut = false;
          } else {
            canCheckOut = true;
          }
        } else {
          // User hasn't checked in yet
          canCheckIn = true;
          canCheckOut = false;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        backgroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        centerTitle: true,
        title: Text(
          'Kehadiran',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      _loading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage == null
                                        ? "Mengambil lokasi..."
                                        : _errorMessage!,
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.text,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: _getCurrentLocation,
                                        icon: Icon(Icons.refresh),
                                        label: Text("Coba Lagi"),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : (_currentPosition == null)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Lokasi tidak tersedia",
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.text,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _getCurrentLocation,
                                    icon: Icon(Icons.refresh),
                                    label: Text("Refresh Lokasi"),
                                  ),
                                ],
                              ),
                            )
                          : GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 15.0,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('current_location'),
                                  position: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: 'Lokasi Anda',
                                    snippet:
                                        _currentAddress ??
                                        'Alamat tidak tersedia',
                                  ),
                                ),
                              },
                            ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          onPressed: _getCurrentLocation,
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.text,
                          child: Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          isIzin
                              ? 'Izin'
                              : (isCheckedOut
                                    ? 'Sudah Check Out'
                                    : (isCheckedIn
                                          ? 'Sudah Check In'
                                          : 'Belum Check In')),
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isIzin
                                ? Colors.orange
                                : (isCheckedOut
                                      ? Colors.blue
                                      : (isCheckedIn
                                            ? Colors.green
                                            : Colors.red)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Only show photo status if not checked in yet
                    if (!isCheckedIn && !isCheckedOut && !isIzin)
                      Row(
                        children: [
                          Text(
                            'Foto: ',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _checkInPhoto != null
                                ? 'Sudah terupload'
                                : 'Belum terupload',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _checkInPhoto != null
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alamat: ',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _currentAddress ?? '-',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Distance information
                    Row(
                      children: [
                        Text(
                          'Jarak: ',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _distanceFromOffice != null
                              ? '${_distanceFromOffice!.toStringAsFixed(1)}m dari kantor'
                              : 'Menghitung...',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isWithinAllowedDistance
                                ? Colors.green
                                : (_distanceFromOffice != null
                                      ? Colors.red
                                      : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    if (_distanceFromOffice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              _isWithinAllowedDistance
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 16,
                              color: _isWithinAllowedDistance
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _distanceMessage,
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: _isWithinAllowedDistance
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Kehadiran',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final days = [
                            'Sunday',
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                          ];
                          String dayName = days[now.weekday % 7];
                          String monthName = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ][now.month - 1];
                          String dateStr =
                              "${now.day.toString().padLeft(2, '0')}-${monthName}-${now.year}";

                          String checkInTime = '-';
                          String checkOutTime = '-';

                          final todayData = _todayAbsenResponse;

                          if (todayData != null) {
                            if (todayData.status != null &&
                                todayData.status.toLowerCase() == 'izin') {
                              checkInTime = 'Izin';
                              checkOutTime = '-';
                            } else {
                              if (todayData.checkIn != null) {
                                try {
                                  final dt = todayData.checkIn!;
                                  checkInTime =
                                      "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                                } catch (_) {
                                  checkInTime = todayData.checkIn!
                                      .toIso8601String();
                                }
                              }
                              if (todayData.checkOut != null) {
                                try {
                                  final dt = todayData.checkOut!;
                                  checkOutTime =
                                      "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                                } catch (_) {
                                  checkOutTime = todayData.checkOut!
                                      .toIso8601String();
                                }
                              }
                            }
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayName,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check In',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      checkInTime,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: checkInTime == 'Izin'
                                            ? Colors.orange
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check Out',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      checkOutTime,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    // Photo button
                    if (!isCheckedIn && !isCheckedOut && !isIzin)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 12),
                        child: CustomButton(
                          onPressed: _isTakingPhoto ? null : _takePhoto,
                          text: _isTakingPhoto
                              ? 'Mengambil Foto...'
                              : 'Ambil Foto',
                          minWidth: double.infinity,
                          height: 45,
                          backgroundColor: _checkInPhoto != null
                              ? Colors.green
                              : AppColors.primary,
                          foregroundColor: AppColors.text,
                          borderRadius: BorderRadius.circular(10),
                          icon: _isTakingPhoto
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.text,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : (_checkInPhoto != null
                                    ? Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      )),
                        ),
                      ),
                    // Check in/out and izin buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed:
                                _isCheckingIn ||
                                    _isCheckingOut ||
                                    isIzin ||
                                    isCheckedOut ||
                                    !_isWithinAllowedDistance
                                ? null
                                : (canCheckOut
                                      ? _handleCheckOut
                                      : _handleCheckIn),
                            text: _isCheckingIn
                                ? 'Checking In...'
                                : (_isCheckingOut
                                      ? 'Checking Out...'
                                      : (isCheckedOut
                                            ? 'Sudah Check Out'
                                            : (!_isWithinAllowedDistance
                                                  ? 'Jarak Terlalu Jauh'
                                                  : (canCheckOut
                                                        ? 'Check Out'
                                                        : 'Check In')))),
                            minWidth: double.infinity,
                            height: 45,
                            backgroundColor: isCheckedOut
                                ? Colors.grey
                                : (!_isWithinAllowedDistance
                                      ? Colors.red
                                      : (canCheckOut
                                            ? Colors.blue
                                            : AppColors.primary)),
                            foregroundColor: AppColors.text,
                            borderRadius: BorderRadius.circular(10),
                            icon: _isCheckingIn || _isCheckingOut
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.text,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : (isCheckedOut
                                      ? Icon(Icons.check_circle, size: 20)
                                      : (!_isWithinAllowedDistance
                                            ? Icon(Icons.location_off, size: 20)
                                            : null)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            onPressed: isIzin ? null : _handleIzin,
                            text: isIzin ? 'Sudah Izin' : 'Ajukan Izin',
                            minWidth: double.infinity,
                            height: 45,
                            backgroundColor: isIzin
                                ? Colors.grey
                                : Colors.orange,
                            foregroundColor: AppColors.text,
                            borderRadius: BorderRadius.circular(10),
                            icon: isIzin
                                ? Icon(Icons.check_circle, size: 20)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tambahkan copyright di bawah konten utama
                const SizedBox(height: 24),
                CopyrightText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

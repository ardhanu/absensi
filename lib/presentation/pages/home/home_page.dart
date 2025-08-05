import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:attendify/presentation/pages/attendance/detail_absen_page.dart';
import 'package:attendify/presentation/pages/home/widgets/container_check_in_out_widget.dart';
import 'package:attendify/presentation/pages/home/widgets/container_distance.dart';
import 'package:attendify/presentation/pages/home/widgets/header_widget.dart';
import 'package:attendify/presentation/pages/home/widgets/list_data_widget.dart';
import 'package:attendify/presentation/pages/home/widgets/section_riwayat_details_widget.dart';
import 'package:attendify/presentation/pages/attendance/maps_page.dart';
import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/button.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:attendify/presentation/widgets/detail_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  Future<List<Attendance>>? _futureAbsenHistory;
  bool _isFirstLoad = true;
  Future<User>? _futureProfile;

  @override
  bool get wantKeepAlive => true;

  double? _distanceFromOffice;
  String? _currentAddress;
  bool _hasAttendedToday = false;
  Attendance? _todayAbsenResponse;

  Future<User> _loadProfile() async {
    return UserProfileService.getProfile();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstLoad) {
      _refreshEssentialData();
    } else {
      _isFirstLoad = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshAfterAttendance();
    }
  }

  Future<void> _fetchTodayAttendanceData() async {
    try {
      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final todayAbsenResponse = await AttendanceService.getTodayAttendance(
        date: todayDate,
      );

      setState(() {
        _todayAbsenResponse = todayAbsenResponse;
      });

      if (todayAbsenResponse != null) {
        try {
          if (todayAbsenResponse.checkIn != null) {
            final checkInTime = _parseTimeString(
              todayAbsenResponse.checkIn!.toIso8601String(),
            );
            setState(() {
              _hasAttendedToday = true;
            });
          } else {
            setState(() {
              _hasAttendedToday = false;
            });
          }
        } catch (e) {
          setState(() {
            _hasAttendedToday = false;
          });
        }
      } else {
        setState(() {
          _hasAttendedToday = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasAttendedToday = false;
      });
    }
  }

  Future<void> _fetchLocationData() async {
    try {
      final distance = await MapsServices.getDistanceFromOffice();
      final address = await MapsServices.getCurrentAddress();
      setState(() {
        _distanceFromOffice = distance;
        _currentAddress = address;
      });
    } catch (e) {
      setState(() {
        _distanceFromOffice = null;
        _currentAddress = null;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _futureAbsenHistory = AttendanceService.getAttendanceHistory();
        _futureProfile = _loadProfile();
      });
      await Future.wait([_fetchLocationData(), _fetchTodayAttendanceData()]);
    } catch (_) {}
  }

  Future<void> _refreshAfterAttendance() async {
    try {
      await _fetchTodayAttendanceData();
      setState(() {
        _futureAbsenHistory = AttendanceService.getAttendanceHistory();
      });
      await _fetchLocationData();
    } catch (_) {}
  }

  Future<void> _refreshFromMapsPage() async {
    try {
      await Future.wait([_fetchTodayAttendanceData(), _fetchLocationData()]);
      setState(() {
        _futureAbsenHistory = AttendanceService.getAttendanceHistory();
      });
    } catch (_) {}
  }

  Future<void> _refreshEssentialData() async {
    try {
      await Future.wait([_fetchTodayAttendanceData(), _fetchLocationData()]);
      setState(() {
        _futureAbsenHistory = AttendanceService.getAttendanceHistory();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              if (_futureProfile != null)
                HeaderWidget(
                  futureProfile: _futureProfile!,
                  hasAttendedToday: _hasAttendedToday,
                  showDialogDetailsAttended: _showDialogDetailsAttended,
                  onRefreshData: () async {
                    if (mounted) {
                      await _refreshEssentialData();
                    }
                  },
                ),
              const SizedBox(height: 16),
              ContainerDistanceAndOpenMapWidget(
                distanceFromOffice: _distanceFromOffice,
              ),
              const SizedBox(height: 16),
              ContainerCheckInOutWidget(
                currentAddress: _currentAddress,
                hasAttendedToday: _hasAttendedToday,
                checkInTime: _todayAbsenResponse?.checkIn?.toIso8601String(),
                checkOutTime: _todayAbsenResponse?.checkOut?.toIso8601String(),
              ),
              const SizedBox(height: 4),
              SectionRiwayatDetailsWidget(
                onDetailsPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailAbsenPage(),
                    ),
                  );
                  if (mounted) {
                    await _refreshEssentialData();
                  }
                },
              ),
              Expanded(
                flex: 15,
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColors.primary,
                  child: _futureAbsenHistory != null
                      ? ListDataWidget(futureAbsenHistory: _futureAbsenHistory!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 16),
              const CopyrightText(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialogCheckInAndOut(context);
        },
        tooltip: 'Absen & Izin',
        backgroundColor: AppColors.primary,
        child: Icon(Icons.fingerprint, color: AppColors.text, size: 28),
      ),
    );
  }

  Future<dynamic> _showDialogCheckInAndOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.text,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset('assets/icons/attend.png', width: 80, height: 80),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attendance',
              style: GoogleFonts.lexend(
                fontSize: 26,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Seamlessly check in or out for your attendance. Your presence, your way.',
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: AppColors.primary.withOpacity(0.85),
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapsPage(),
                          fullscreenDialog: false,
                        ),
                      ).then((_) async {
                        await _refreshFromMapsPage();
                      });
                    },
                    text: 'Check In / Out',
                    height: 48,
                    backgroundColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    textStyle: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                    icon: const Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _parseTimeString(String timeStr) {
    if (timeStr.isEmpty) return '-- : -- : --';
    try {
      final dateTime = DateTime.tryParse(timeStr);
      if (dateTime != null) {
        return '${dateTime.hour.toString().padLeft(2, '0')} : ${dateTime.minute.toString().padLeft(2, '0')} : ${dateTime.second.toString().padLeft(2, '0')}';
      }
      final timeParts = timeStr.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        final second = timeParts.length > 2
            ? (int.tryParse(timeParts[2]) ?? 0)
            : 0;
        return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} : ${second.toString().padLeft(2, '0')}';
      }
      if (timeStr.contains(' : ')) {
        return timeStr;
      }
      return '-- : -- : --';
    } catch (e) {
      return '-- : -- : --';
    }
  }

  Future<dynamic> _showDialogDetailsAttended() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Today\'s Attendance Data',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_todayAbsenResponse != null) ...[
                DetailRow(
                  label: 'Date:',
                  value: _todayAbsenResponse!.attendanceDate != null
                      ? _todayAbsenResponse!.attendanceDate!
                            .toIso8601String()
                            .split('T')
                            .first
                      : 'Not available',
                ),
                DetailRow(
                  label: 'Check In:',
                  value: _todayAbsenResponse!.checkIn != null
                      ? _parseTimeString(
                          _todayAbsenResponse!.checkIn!.toIso8601String(),
                        )
                      : '-',
                ),
                DetailRow(
                  label: 'Check In Address:',
                  value: _todayAbsenResponse!.checkInAddress ?? '-',
                ),
                DetailRow(
                  label: 'Check Out:',
                  value: _todayAbsenResponse!.checkOut != null
                      ? _parseTimeString(
                          _todayAbsenResponse!.checkOut!.toIso8601String(),
                        )
                      : '-',
                ),
                DetailRow(
                  label: 'Check Out Address:',
                  value: _todayAbsenResponse!.checkOutAddress ?? '-',
                ),
                DetailRow(
                  label: 'Status:',
                  value: _todayAbsenResponse!.status ?? '-',
                ),
                if (_todayAbsenResponse!.checkInPhoto != null &&
                    _todayAbsenResponse!.checkInPhoto!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Photo:',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildAttendancePhoto(
                            _todayAbsenResponse!.checkInPhoto!,
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                DetailRow(
                  label: 'Status:',
                  value: 'No attendance data for today',
                ),
                DetailRow(label: 'Message:', value: 'No response message'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.lexend(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePhoto(String photo) {
    // Perbaikan: handle base64, data:image, dan url dengan benar
    try {
      if (photo.startsWith('data:image')) {
        final base64Str = photo.split(',').last;
        return _buildBase64Image(base64Str);
      } else if (photo.length > 100 && !photo.startsWith('http')) {
        return _buildBase64Image(photo);
      } else if (photo.startsWith('http')) {
        return Image.network(
          photo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      } else {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        );
      }
    } catch (e) {
      debugPrint("Error displaying attendance photo: $e");
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      );
    }
  }

  Widget _buildBase64Image(String base64String) {
    try {
      String validBase64 = _fixBase64String(base64String);
      final bytes = base64Decode(validBase64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      );
    } catch (e) {
      debugPrint("Error decoding base64 image: $e");
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      );
    }
  }

  String _fixBase64String(String base64String) {
    String cleaned = base64String
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    return cleaned;
  }
}

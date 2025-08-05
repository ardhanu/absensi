import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:attendify/presentation/widgets/detail_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Added for base64Decode

class DetailAbsenPage extends StatefulWidget {
  const DetailAbsenPage({super.key});

  @override
  State<DetailAbsenPage> createState() => _DetailAbsenPageState();
}

class _DetailAbsenPageState extends State<DetailAbsenPage> {
  List<Attendance> listHistoryAbsen = [];
  UserStats? statAbsen;
  bool _isLoading = true;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  int _selectedMonth = DateTime.now().month;

  Future<void> _getHistoryAbsen() async {
    setState(() => _isLoading = true);
    try {
      final response = await AttendanceService.getAttendanceHistory();
      listHistoryAbsen = response;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getStatAbsen() async {
    setState(() => _isLoading = true);
    try {
      final statAbsenData = await UserProfileService.getUserStats();
      setState(() {
        statAbsen = statAbsenData;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _filterStartDate = DateTime(now.year, now.month, 1);
    _filterEndDate = DateTime(now.year, now.month + 1, 0);
    _fetchFilteredHistory();
    _getStatAbsen();
  }

  Future<void> _fetchFilteredHistory() async {
    setState(() => _isLoading = true);
    try {
      // Jika filterStartDate dan filterEndDate null, artinya "Semua" (tanpa filter)
      if (_filterStartDate == null && _filterEndDate == null) {
        // Ambil semua data
        final response = await AttendanceService.getAttendanceHistory();
        setState(() {
          listHistoryAbsen = response;
          _isLoading = false;
        });
        return;
      }

      // Ambil semua data history, lalu filter berdasarkan tanggal
      final allHistoryData = await AttendanceService.getAttendanceHistory();

      // Filter data berdasarkan tanggal yang dipilih
      final filteredData = allHistoryData.where((absen) {
        final absenDate = absen.attendanceDate;
        if (absenDate == null) return false;
        return absenDate.isAfter(
              _filterStartDate!.subtract(const Duration(days: 1)),
            ) &&
            absenDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
      }).toList();

      setState(() {
        listHistoryAbsen = filteredData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        listHistoryAbsen = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFilterDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_filterStartDate ?? DateTime.now())
        : (_filterEndDate ?? DateTime.now());
    final firstDate = DateTime(DateTime.now().year - 2, 1, 1);
    final lastDate = DateTime(DateTime.now().year + 1, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _filterStartDate = picked;
          if (_filterEndDate != null && _filterEndDate!.isBefore(picked)) {
            _filterEndDate = picked;
          }
        } else {
          _filterEndDate = picked;
          if (_filterStartDate != null && _filterStartDate!.isAfter(picked)) {
            _filterStartDate = picked;
          }
        }
      });
      _fetchFilteredHistory();
    }
  }

  Widget _buildMonthSelector() {
    final months = [
      'Semua', // Default option to show all data
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, idx) {
          final isSelected =
              (_selectedMonth == 0 && idx == 0) || (_selectedMonth == idx);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (idx == 0) {
                  // Jika memilih "Semua", tampilkan semua data (tanpa filter)
                  _selectedMonth = 0;
                  _filterStartDate = null;
                  _filterEndDate = null;
                  _fetchFilteredHistory();
                } else {
                  _selectedMonth = idx;
                  final now = DateTime.now();
                  _filterStartDate = DateTime(now.year, _selectedMonth, 1);
                  _filterEndDate = DateTime(now.year, _selectedMonth + 1, 0);
                  _fetchFilteredHistory();
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[400]!,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  months[idx],
                  style: GoogleFonts.lexend(
                    color: isSelected ? AppColors.text : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: Text(
          'Detail Attendance',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: AppColors.text,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back_ios, size: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildFilterSection(),
              SizedBox(height: 18),
              _buildMonthSelector(),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _getHistoryAbsen();
                    await _getStatAbsen();
                  },
                  color: AppColors.primary,
                  child: _buildAttendanceList(),
                ),
              ),
              // Tambahkan copyright di bawah konten utama
              const SizedBox(height: 24),
              CopyrightText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    int total = statAbsen?.totalDays ?? 0;
    int present = statAbsen?.presentDays ?? 0;
    int permission = statAbsen?.leaveDays ?? 0;

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            _buildSummaryItem('Attendance', total),
            const VerticalDivider(color: Colors.white60, thickness: 1),
            _buildSummaryItem('Present', present),
            const VerticalDivider(color: Colors.white60, thickness: 1),
            _buildSummaryItem('Permission', permission),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(fontSize: 12, color: Colors.white60),
          ),
          Text(
            '$count',
            style: GoogleFonts.lexend(
              fontSize: 20,
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Data Kehadiran',
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectFilterDate(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _filterStartDate != null
                            ? " ${_filterStartDate!.day.toString().padLeft(2, '0')}-${_filterStartDate!.month.toString().padLeft(2, '0')}-${_filterStartDate!.year}"
                            : "-",
                        style: GoogleFonts.lexend(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("s/d", style: GoogleFonts.lexend(fontSize: 13)),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectFilterDate(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _filterEndDate != null
                            ? "${_filterEndDate!.day.toString().padLeft(2, '0')}-${_filterEndDate!.month.toString().padLeft(2, '0')}-${_filterEndDate!.year}"
                            : "-",
                        style: GoogleFonts.lexend(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == "null") {
      return '-- : -- : --';
    }
    // Try to parse as HH:mm:ss or HH:mm
    try {
      // If already in HH:mm:ss
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timeStr)) {
        return timeStr;
      }
      // If in HH:mm, add :00
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(timeStr)) {
        return '$timeStr:00';
      }
      // If in ISO format (e.g. 2024-06-01T08:30:00), extract time
      if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}').hasMatch(timeStr)) {
        final dt = DateTime.parse(timeStr);
        return DateFormat('HH:mm:ss').format(dt);
      }
      // Try to parse as DateTime
      final dt = DateTime.tryParse(timeStr);
      if (dt != null) {
        return DateFormat('HH:mm:ss').format(dt);
      }
    } catch (_) {}
    return timeStr;
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (listHistoryAbsen.isEmpty) {
      return Center(
        child: Text(
          "No attendance records found.",
          style: GoogleFonts.lexend(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      itemCount: listHistoryAbsen.length,
      itemBuilder: (context, index) {
        final absen = listHistoryAbsen[index];

        // Tanggal
        final date = absen.attendanceDate;
        if (date == null) return Container(); // Skip if no date

        final dayName = _getDayName(date.weekday);
        final dateStr = '${date.day}/${date.month}/${date.year}';

        // Check In Time
        String checkInTime = _formatTime(absen.checkIn?.toIso8601String());

        // Check Out Time
        String checkOutTime = _formatTime(absen.checkOut?.toIso8601String());

        // Status
        String statusStr = absen.status
            .toString()
            .split('.')
            .last
            .toLowerCase();
        final isLate = (statusStr == 'late');
        final isPermission = (statusStr == 'permission' || statusStr == 'izin');
        final isMasuk = (statusStr == 'masuk' || statusStr == 'present');

        return GestureDetector(
          onTap: () => _showDetailDialog(absen),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
                color: isLate
                    ? Colors.red.withOpacity(0.05)
                    : isPermission
                    ? Colors.orange.withOpacity(0.05)
                    : isMasuk
                    ? Colors.green.withOpacity(0.05)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isLate)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LATE',
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (isPermission)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PERMISSION',
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (isMasuk)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PRESENT',
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Check in',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            checkInTime,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isLate ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Check out',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            checkOutTime,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLate
                            ? Colors.red
                            : isPermission
                            ? Colors.orange
                            : isMasuk
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> _showDetailDialog(Attendance absen) async {
    String safeFormat(String? time) {
      try {
        return _formatTime(time) ?? '-';
      } catch (_) {
        return '-';
      }
    }

    String checkInTime = safeFormat(absen.checkIn?.toIso8601String());
    String checkOutTime = safeFormat(absen.checkOut?.toIso8601String());

    if (!mounted) return; // Pastikan widget masih aktif

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Attendance Detail',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DetailRow(
                    label: 'Date:',
                    value: absen.attendanceDate != null
                        ? DateFormat('dd/MM/yyyy').format(absen.attendanceDate!)
                        : '-',
                  ),
                  DetailRow(label: 'Check In:', value: checkInTime),
                  DetailRow(
                    label: 'Check In Location:',
                    value:
                        (absen.checkInLat != null && absen.checkInLng != null)
                        ? '${absen.checkInLat}, ${absen.checkInLng}'
                        : '-',
                  ),
                  DetailRow(
                    label: 'Check In Address:',
                    value: (absen.checkInAddress?.isNotEmpty ?? false)
                        ? absen.checkInAddress!
                        : '-',
                  ),
                  DetailRow(label: 'Check Out:', value: checkOutTime),
                  DetailRow(
                    label: 'Check Out Location:',
                    value:
                        (absen.checkOutLat != null && absen.checkOutLng != null)
                        ? '${absen.checkOutLat}, ${absen.checkOutLng}'
                        : '-',
                  ),
                  DetailRow(
                    label: 'Check Out Address:',
                    value: (absen.checkOutAddress?.isNotEmpty ?? false)
                        ? absen.checkOutAddress!
                        : '-',
                  ),
                  DetailRow(
                    label: 'Status:',
                    value: absen.status == 'present' || absen.status == 'masuk'
                        ? 'Masuk'
                        : absen.status == 'leave' || absen.status == 'izin'
                        ? 'Izin'
                        : (absen.status ?? '-'),
                  ),
                  DetailRow(
                    label: 'Alasan Izin:',
                    value: (absen.alasanIzin?.trim().isNotEmpty ?? false)
                        ? absen.alasanIzin!
                        : '-',
                  ),

                  // Foto Check In
                  if (absen.checkInPhoto != null &&
                      absen.checkInPhoto!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Photo:',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Builder(
                              builder: (context) {
                                try {
                                  if (absen.checkInPhoto!.startsWith(
                                    'data:image',
                                  )) {
                                    return _buildBase64Image(
                                      absen.checkInPhoto!.split(',').last,
                                    );
                                  } else if (absen.checkInPhoto!.length > 100 &&
                                      !absen.checkInPhoto!.startsWith('http')) {
                                    return _buildBase64Image(
                                      absen.checkInPhoto!,
                                    );
                                  } else {
                                    return Image.network(
                                      absen.checkInPhoto!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                              ),
                                    );
                                  }
                                } catch (_) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.lexend(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBase64Image(String base64String) {
    try {
      // Validate and fix base64 string
      String validBase64 = _fixBase64String(base64String);
      final bytes = base64Decode(validBase64);
      return Image.memory(
        bytes,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      );
    } catch (e) {
      print("Error decoding base64 image: $e");
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.broken_image)),
      );
    }
  }

  String _fixBase64String(String base64String) {
    // Remove any whitespace
    String cleaned = base64String.trim();

    // Ensure length is multiple of 4
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }

    return cleaned;
  }
}

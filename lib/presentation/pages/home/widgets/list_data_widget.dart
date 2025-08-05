import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListDataWidget extends StatefulWidget {
  final Future<List<Attendance>> futureAbsenHistory;

  const ListDataWidget({Key? key, required this.futureAbsenHistory})
    : super(key: key);

  @override
  State<ListDataWidget> createState() => _ListDataWidgetState();
}

class _ListDataWidgetState extends State<ListDataWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Attendance>>(
      future: widget.futureAbsenHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load data'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(child: Text('No attendance data'));
        }

        // Sort data descending by attendanceDate (today at top, older below)
        final sortedData = List<Attendance>.from(data);
        sortedData.sort((a, b) {
          final aDate = a.attendanceDate ?? DateTime(1970);
          final bDate = b.attendanceDate ?? DateTime(1970);
          return bDate.compareTo(aDate); // descending
        });

        // Use all sorted data instead of limiting to 7 items
        final displayData = sortedData;

        return ListView.builder(
          itemCount: displayData.length,
          itemBuilder: (BuildContext context, int index) {
            final absen = displayData[index];

            final date = absen.attendanceDate;
            if (date == null) return Container(); // Skip if no date

            final dayName = _getDayName(date.weekday);
            final dateStr = '${date.day}/${date.month}/${date.year}';

            String statusStr = absen.status
                .toString()
                .split('.')
                .last
                .toLowerCase();

            final isLate = (statusStr == 'late');
            final isPermission =
                (statusStr == 'permission' || statusStr == 'izin');
            final isMasuk = (statusStr == 'masuk');

            // Tampilkan jam checkin dan out seperti di detail_absen_page.dart
            String formatTime(String? timeStr) {
              if (timeStr == null || timeStr.isEmpty) return '-- : -- : --';

              try {
                // Handle ISO8601 format like "2024-01-15T08:30:00.000Z"
                if (timeStr.contains('T')) {
                  final dateTime = DateTime.tryParse(timeStr);
                  if (dateTime != null) {
                    return '${dateTime.hour.toString().padLeft(2, '0')} : ${dateTime.minute.toString().padLeft(2, '0')} : ${dateTime.second.toString().padLeft(2, '0')}';
                  }
                }

                // Handle format like "2024-06-07 08:00:00"
                if (timeStr.contains(' ')) {
                  final parts = timeStr.split(' ');
                  if (parts.length > 1) {
                    final timePart = parts[1];
                    if (timePart.contains(':')) {
                      final timeComponents = timePart.split(':');
                      if (timeComponents.length >= 3) {
                        final hour = int.tryParse(timeComponents[0]) ?? 0;
                        final minute = int.tryParse(timeComponents[1]) ?? 0;
                        final second = int.tryParse(timeComponents[2]) ?? 0;
                        return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} : ${second.toString().padLeft(2, '0')}';
                      }
                    }
                  }
                }

                // Handle format like "08:00:00"
                if (timeStr.contains(':')) {
                  final timeComponents = timeStr.split(':');
                  if (timeComponents.length >= 3) {
                    final hour = int.tryParse(timeComponents[0]) ?? 0;
                    final minute = int.tryParse(timeComponents[1]) ?? 0;
                    final second = int.tryParse(timeComponents[2]) ?? 0;
                    return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} : ${second.toString().padLeft(2, '0')}';
                  }
                }

                return '-- : -- : --';
              } catch (e) {
                return '-- : -- : --';
              }
            }

            return Padding(
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
                              formatTime(absen.checkIn?.toIso8601String()),
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
                              formatTime(absen.checkOut?.toIso8601String()),
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
            );
          },
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
}

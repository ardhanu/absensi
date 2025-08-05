import 'dart:convert';
import 'package:attendify/data/models/attendance_model.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../../core/network/endpoints.dart';
import '../local/preferences.dart';

class AttendanceService {
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final token = await Preferences.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Attendance> checkIn({
    String? attendanceDate,
    required String checkInLocation,
    required String checkInAddress,
    String? checkInPhoto,
    double? checkInLat,
    double? checkInLng,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.checkIn),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (attendanceDate != null) 'attendanceDate': attendanceDate,
        'checkInLocation': checkInLocation,
        'checkInAddress': checkInAddress,
        if (checkInPhoto != null) 'checkInPhoto': checkInPhoto,
        if (checkInLat != null) 'checkInLat': checkInLat,
        if (checkInLng != null) 'checkInLng': checkInLng,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Attendance.fromJson(data['attendance']);
    } else {
      throw Exception('Failed to check in: ${response.body}');
    }
  }

  static Future<Attendance> checkOut({
    String? attendanceDate,
    required String checkOutLocation,
    required String checkOutAddress,
    double? checkOutLat,
    double? checkOutLng,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.checkOut),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (attendanceDate != null) 'attendanceDate': attendanceDate,
        'checkOutLocation': checkOutLocation,
        'checkOutAddress': checkOutAddress,
        if (checkOutLat != null) 'checkOutLat': checkOutLat,
        if (checkOutLng != null) 'checkOutLng': checkOutLng,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Attendance.fromJson(data['attendance']);
    } else {
      throw Exception('Failed to check out: ${response.body}');
    }
  }

  static Future<Attendance> submitLeave({
    String? attendanceDate,
    required String alasanIzin,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.permission),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (attendanceDate != null) 'attendanceDate': attendanceDate,
        'alasanIzin': alasanIzin,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Attendance.fromJson(data['attendance']);
    } else {
      throw Exception('Failed to submit leave: ${response.body}');
    }
  }

  static Future<Attendance?> getTodayAttendance({String? date}) async {
    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;

    final uri = Uri.parse(
      date != null ? Endpoint.todayAbsenWithDate(date) : Endpoint.todayAbsen,
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['attendance'] != null
          ? Attendance.fromJson(data['attendance'])
          : null;
    } else {
      throw Exception('Failed to get today attendance: ${response.body}');
    }
  }

  static Future<List<Attendance>> getAttendanceHistory({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse(
      Endpoint.allHistoryAbsen,
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> attendancesJson = data['attendances'];
      return attendancesJson.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get attendance history: ${response.body}');
    }
  }
}

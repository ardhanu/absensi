import 'dart:convert';
import 'package:attendify/data/models/user_model.dart';
import 'package:attendify/data/models/user_stats_model.dart';
import 'package:http/http.dart' as http;
import '../../core/network/endpoints.dart';
import '../local/preferences.dart';

class UserProfileService {
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final token = await Preferences.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<User> getProfile() async {
    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  static Future<User> updateProfile({
    String? name,
    String? jenisKelamin,
    String? photo,
  }) async {
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (jenisKelamin != null) body['jenisKelamin'] = jenisKelamin;
    if (photo != null) body['photo'] = photo;

    final response = await http.put(
      Uri.parse(Endpoint.profile),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse(Endpoint.changePassword),
      headers: await _getHeaders(),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  static Future<UserStats> getUserStats({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse(
      Endpoint.statAbsen,
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserStats.fromJson(data['stats']);
    } else {
      throw Exception('Failed to get user stats: ${response.body}');
    }
  }
}

import 'dart:convert';
import 'package:attendify/data/models/auth_response_model.dart';
import 'package:http/http.dart' as http;
import '../../core/network/endpoints.dart';
import '../local/preferences.dart';

class AuthService {
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final token = await Preferences.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    String? photo,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'jenisKelamin': jenisKelamin,
        if (photo != null) 'photo': photo,
      }),
    );

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('DEBUG: Login response status: ${response.statusCode}');
      print('DEBUG: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('DEBUG: Parsed response data: $responseData');

        final authResponse = AuthResponse.fromJson(responseData);

        // Validate token before saving
        if (authResponse.token.isEmpty) {
          throw Exception('Token is empty or null from server response');
        }

        await Preferences.saveToken(authResponse.token);
        await Preferences.saveLoginSession();
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: Login error: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      }
      rethrow;
    }
  }
}

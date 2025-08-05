import 'package:attendify/data/models/user_model.dart';

class AuthResponse {
  final String message;
  final User user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message']?.toString() ?? 'Success',
      user: User.fromJson(json['user'] ?? {}),
      token: json['token']?.toString() ?? '',
    );
  }
}

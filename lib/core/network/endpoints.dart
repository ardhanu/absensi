class Endpoint {
  static final String baseUrl = 'https://9ef65db53952.ngrok-free.app/api';
  static final String register = '$baseUrl/auth/register';
  static final String login = '$baseUrl/auth/login';
  static final String allHistoryAbsen = '$baseUrl/attendance/history';
  static final String statAbsen = '$baseUrl/user/stats';
  static final String profile = '$baseUrl/user/profile';
  static final String checkIn = '$baseUrl/attendance/check-in';
  static final String checkOut = '$baseUrl/attendance/check-out';
  static final String permission = '$baseUrl/attendance/leave';
  static final String changePassword = '$baseUrl/user/change-password';
  static final String todayAbsen = '$baseUrl/attendance/today';
  static String todayAbsenWithDate(String date) => '$todayAbsen?date=$date';
  static final String healthCheck = '$baseUrl/../health';
}

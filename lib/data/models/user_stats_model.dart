class UserStats {
  final int totalDays;
  final int presentDays;
  final int leaveDays;
  final int absentDays;
  final int attendancePercentage;

  UserStats({
    required this.totalDays,
    required this.presentDays,
    required this.leaveDays,
    required this.absentDays,
    required this.attendancePercentage,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalDays: json['totalDays'],
      presentDays: json['presentDays'],
      leaveDays: json['leaveDays'],
      absentDays: json['absentDays'],
      attendancePercentage: json['attendancePercentage'],
    );
  }
}

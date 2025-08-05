class Attendance {
  final String id;
  final String userId;
  final DateTime? attendanceDate;
  final DateTime? checkIn;
  final String? checkInLocation;
  final String? checkInAddress;
  final String? checkInPhoto;
  final double? checkInLat;
  final double? checkInLng;
  final DateTime? checkOut;
  final String? checkOutLocation;
  final String? checkOutAddress;
  final String? checkOutPhoto;
  final double? checkOutLat;
  final double? checkOutLng;
  final String status;
  final String? alasanIzin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    this.attendanceDate,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkInPhoto,
    this.checkInLat,
    this.checkInLng,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.checkOutPhoto,
    this.checkOutLat,
    this.checkOutLng,
    required this.status,
    this.alasanIzin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      attendanceDate: json['attendanceDate'] != null
          ? DateTime.parse(json['attendanceDate'])
          : null,
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkInLocation: json['checkInLocation'],
      checkInAddress: json['checkInAddress'],
      checkInPhoto: json['checkInPhoto'],
      checkInLat: json['checkInLat'] != null
          ? double.parse(json['checkInLat'].toString())
          : null,
      checkInLng: json['checkInLng'] != null
          ? double.parse(json['checkInLng'].toString())
          : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'])
          : null,
      checkOutLocation: json['checkOutLocation'],
      checkOutAddress: json['checkOutAddress'],
      checkOutPhoto: json['checkOutPhoto'],
      checkOutLat: json['checkOutLat'] != null
          ? double.parse(json['checkOutLat'].toString())
          : null,
      checkOutLng: json['checkOutLng'] != null
          ? double.parse(json['checkOutLng'].toString())
          : null,
      status: json['status'],
      alasanIzin: json['alasanIzin'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'attendanceDate': attendanceDate?.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkInLocation': checkInLocation,
      'checkInAddress': checkInAddress,
      'checkInPhoto': checkInPhoto,
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOut': checkOut?.toIso8601String(),
      'checkOutLocation': checkOutLocation,
      'checkOutAddress': checkOutAddress,
      'checkOutPhoto': checkOutPhoto,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
      'status': status,
      'alasanIzin': alasanIzin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

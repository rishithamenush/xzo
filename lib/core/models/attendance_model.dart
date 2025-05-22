import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  String? id;
  String memberId;
  DateTime checkInTime;
  DateTime? checkOutTime;

  AttendanceModel({
    this.id,
    required this.memberId,
    required this.checkInTime,
    this.checkOutTime,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      memberId: json['memberId'],
      checkInTime: (json['checkInTime'] as Timestamp).toDate(),
      checkOutTime: json['checkOutTime'] != null ? (json['checkOutTime'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
    };
  }
} 
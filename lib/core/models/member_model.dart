import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? membershipType;
  String? registrationNumber;
  String? status;
  DateTime? joinDate;
  DateTime? expiryDate;

  MemberModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.membershipType,
    this.registrationNumber,
    this.status = 'active',
    this.joinDate,
    this.expiryDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      membershipType: json['membershipType'],
      registrationNumber: json['registrationNumber'],
      status: json['status'] ?? 'active',
      joinDate: json['joinDate'] != null ? (json['joinDate'] as Timestamp).toDate() : null,
      expiryDate: json['expiryDate'] != null ? (json['expiryDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'membershipType': membershipType,
      'registrationNumber': registrationNumber,
      'status': status,
      'joinDate': joinDate,
      'expiryDate': expiryDate,
    };
  }
} 
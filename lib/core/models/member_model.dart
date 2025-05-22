import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  String? id;
  String name;
  String email;
  String phone;
  String membershipType;
  DateTime joinDate;
  DateTime expiryDate;

  MemberModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipType,
    required this.joinDate,
    required this.expiryDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      membershipType: json['membershipType'],
      joinDate: (json['joinDate'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'membershipType': membershipType,
      'joinDate': joinDate,
      'expiryDate': expiryDate,
    };
  }
} 
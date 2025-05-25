import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class MemberModel {
  /// This id should ALWAYS be the Firebase Auth UID
  String? id;
  String? name;
  String? email;
  String? phone;
  String? membershipType;
  String? registrationNumber;
  DateTime? joinDate;
  DateTime? expiryDate;
  String? status;
  double? longitude;
  double? latitude;
  List<String>? favList;
  String? dietPlan;

  MemberModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.membershipType,
    this.registrationNumber,
    this.joinDate,
    this.expiryDate,
    this.status,
    this.longitude,
    this.latitude,
    this.favList,
    this.dietPlan,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    log('Creating MemberModel from JSON: $json');
    
    // Ensure ID is set
    String? id = json['id'];
    if (id == null || id.isEmpty) {
      log('WARNING: Member JSON missing or empty ID field');
    }
    
    return MemberModel(
      id: id,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      membershipType: json['membershipType'],
      registrationNumber: json['registrationNumber'],
      joinDate: json['joinDate'] != null ? (json['joinDate'] as Timestamp).toDate() : null,
      expiryDate: json['expiryDate'] != null ? (json['expiryDate'] as Timestamp).toDate() : null,
      status: json['status'] ?? 'active', // Default to active if not specified
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      favList: json['favList'] != null ? List<String>.from(json['favList']) : [],
      dietPlan: json['dietPlan'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (membershipType != null) data['membershipType'] = membershipType;
    if (registrationNumber != null) data['registrationNumber'] = registrationNumber;
    if (joinDate != null) data['joinDate'] = Timestamp.fromDate(joinDate!);
    if (expiryDate != null) data['expiryDate'] = Timestamp.fromDate(expiryDate!);
    if (status != null) data['status'] = status;
    if (longitude != null) data['longitude'] = longitude;
    if (latitude != null) data['latitude'] = latitude;
    if (favList != null) data['favList'] = favList;
    if (dietPlan != null) data['dietPlan'] = dietPlan;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemberModel &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
} 
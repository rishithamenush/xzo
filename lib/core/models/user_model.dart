import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/shared.dart';

enum UsersRole { user, expert }

// Model class representing a UserModel
class UserModel {
  String? id;
  String? name;
  String? role;
  double? longitude;
  double? latitude;
  String? email;
  List<String>? favList;


  String? phone;
  String? registrationNumber;
  String? membershipType;
  DateTime? joinDate;
  DateTime? expiryDate;
  UserModel.empty();
  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.longitude,
    required this.latitude,
    this.registrationNumber,
    this.membershipType,
    this.joinDate,
    this.expiryDate,
  }) {
    role = UsersRole.user.name;
    id = uuid.v4();
    favList=[];
  }

//This is a factory Constructor to create UserModel instance from JSON obj
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    role = json['role'];
    longitude = json['longitude'];
    latitude = json['latitude'];

    phone = json['phone'];
    email = json['email'];
    favList = json['favList'].cast<String>();
    registrationNumber = json['registrationNumber'];
    membershipType = json['membershipType'];
    joinDate = json['joinDate'] != null ? (json['joinDate'] as Timestamp).toDate() : null;
    expiryDate = json['expiryDate'] != null ? (json['expiryDate'] as Timestamp).toDate() : null;
  }

//convert the UserModel instance to a JSON object

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['role'] = role;
    data['longitude'] = longitude;
    data['latitude'] = latitude;

    data['phone'] = phone;
    data['email'] = email;
    data['favList'] = favList;
    data['registrationNumber'] = registrationNumber;
    data['membershipType'] = membershipType;
    data['joinDate'] = joinDate;
    data['expiryDate'] = expiryDate;

    return data;
  }
}

//  class representing a list of Users

class UserList {
  List<UserModel> users;

  UserList({required this.users});

  factory UserList.fromJson(List<dynamic> data) {
    List<UserModel> temp = [];
    temp = data.map((item) {
      return UserModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return UserList(users: temp);
  }
}

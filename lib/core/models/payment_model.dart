import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  String? id;
  String memberId;
  double amount;
  DateTime paymentDate;
  DateTime expiryDate;

  PaymentModel({
    this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    required this.expiryDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      memberId: json['memberId'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: (json['paymentDate'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'paymentDate': paymentDate,
      'expiryDate': expiryDate,
    };
  }
} 
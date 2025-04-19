import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? picture;
  double totalBalance;
  double totalLoan;
  double totalBorrowed;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.picture,
    this.totalBalance = 0.0,
    this.totalLoan = 0.0,
    this.totalBorrowed = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var user = User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      picture: json['picture'],
      totalBalance: json['totalBalance']?.toDouble() ?? 0.0,
      totalLoan: json['totalLoan']?.toDouble() ?? 0.0,
      totalBorrowed: json['totalBorrowed']?.toDouble() ?? 0.0,
    );

    return user;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, totalBalance: $totalBalance, totalLoan: $totalLoan, totalBorrowed: $totalBorrowed)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'picture': picture,
      'totalBalance': totalBalance,
      'totalLoan': totalLoan,
      'totalBorrowed': totalBorrowed,
    };
  }
}
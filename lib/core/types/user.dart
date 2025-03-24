class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double totalBalance;
  final double totalLoan;
  final double totalBorrowed;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalBalance,
    required this.totalLoan,
    required this.totalBorrowed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      totalBalance: json['totalBalance'],
      totalLoan: json['totalLoan'],
      totalBorrowed: json['totalBorrowed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'totalBalance': totalBalance,
      'totalLoan': totalLoan,
      'totalBorrowed': totalBorrowed,
    };
  }
}

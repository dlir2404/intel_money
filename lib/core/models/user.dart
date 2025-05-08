class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? picture;
  double totalBalance;
  double totalLoan;
  double totalDebt;

  UserPreferences preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.picture,
    this.totalBalance = 0.0,
    this.totalLoan = 0.0,
    this.totalDebt = 0.0,
    required this.preferences,
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
      totalDebt: json['totalBorrowed']?.toDouble() ?? 0.0,
      preferences: UserPreferences.fromJson(json['preferences']),
    );

    return user;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, totalBalance: $totalBalance, totalLoan: $totalLoan, totalBorrowed: $totalDebt)';
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
      'totalBorrowed': totalDebt,
    };
  }
}

class UserPreferences {
  String? timezone;

  UserPreferences(this.timezone);

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(json['timezone'] ?? '');
  }
}

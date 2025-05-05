import '../state/related_user_state.dart';

class RelatedUser {
  final int? id;
  final String name;
  final String? email;
  final String? phone;

  final double totalLoan;
  final double totalBorrow;

  bool isTemporary;

  RelatedUser({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.totalLoan = 0.0,
    this.totalBorrow = 0.0,
    this.isTemporary = false,
  });

  factory RelatedUser.fromContext(int? id) {
    return RelatedUserState().relatedUsers.firstWhere((user) => user.id == id);
  }

  factory RelatedUser.fromJson(Map<String, dynamic> json) {
    return RelatedUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      totalLoan: json['totalLoan']?.toDouble() ?? 0.0,
      totalBorrow: json['totalBorrow']?.toDouble() ?? 0.0,
    );
  }

  factory RelatedUser.newTemporaryUser(String name) {
    return RelatedUser(
      id: null,
      name: name,
      email: null,
      phone: null,
      totalLoan: 0.0,
      totalBorrow: 0.0,
      isTemporary: true,
    );
  }
}
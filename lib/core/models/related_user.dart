import '../state/related_user_state.dart';

class RelatedUser {
  int? id;
  final String name;
  final String? email;
  final String? phone;

  double totalLoan;
  double totalPaid;

  double totalDebt;
  double totalCollected;

  bool isTemporary;

  RelatedUser({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.totalLoan = 0.0,
    this.totalDebt = 0.0,
    this.totalPaid = 0.0,
    this.totalCollected = 0.0,
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
      totalDebt: json['totalDebt']?.toDouble() ?? 0.0,
      totalPaid: json['totalPaid']?.toDouble() ?? 0.0,
      totalCollected: json['totalCollected']?.toDouble() ?? 0.0,
    );
  }

  factory RelatedUser.newTemporaryUser(String name) {
    return RelatedUser(
      id: null,
      name: name,
      email: null,
      phone: null,
      totalLoan: 0.0,
      totalDebt: 0.0,
      totalPaid: 0.0,
      totalCollected: 0.0,
      isTemporary: true,
    );
  }

  void setId(int id) {
    this.id = id;
  }
}
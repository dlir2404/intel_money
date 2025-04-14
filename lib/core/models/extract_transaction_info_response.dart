class ExtractTransactionInfoResponse {
  final double? amount;
  final int? categoryId;
  final int? walletId;

  final DateTime? date;
  final String? description;

  ExtractTransactionInfoResponse(this.amount, this.categoryId, this.walletId, this.date, this.description);

  factory ExtractTransactionInfoResponse.fromJson(Map<String, dynamic> json) {
    return ExtractTransactionInfoResponse(
      double.parse(json['amount'].toString()),
      json['categoryId'],
      json['walletId'],
      DateTime.parse(json['date']),
      json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'categoryId': categoryId,
      'walletId': walletId,
      'date': date?.toIso8601String(),
      'description': description,
    };
  }
}
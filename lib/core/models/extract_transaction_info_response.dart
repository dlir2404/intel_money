import 'package:intel_money/shared/helper/app_time.dart';

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
      AppTime.parseFromApi(json['date']),
      json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'categoryId': categoryId,
      'walletId': walletId,
      'date': date != null ? AppTime.toUtcIso8601String(date!) : null,
      'description': description,
    };
  }
}
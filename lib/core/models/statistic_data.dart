import 'package:intel_money/core/models/transaction.dart';

import 'category.dart';

class StatisticData {
  double totalIncome;
  double totalExpense;

  List<ByCategoryData> byCategoryIncome;
  List<ByCategoryData> byCategoryExpense;

  //only for year statistic
  List<StatisticData>? byMonthStatistic = [];
  List<StatisticData>? byQuarterStatistic = [];

  StatisticData({
    required this.totalIncome,
    required this.totalExpense,
    required this.byCategoryIncome,
    required this.byCategoryExpense,
    this.byMonthStatistic,
    this.byQuarterStatistic,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    final data = StatisticData(
      totalIncome: json['totalIncome'].toDouble(),
      totalExpense: json['totalExpense'].toDouble(),
      byCategoryIncome: ((json['byCategoryIncome'] ?? []) as List)
          .map((e) => ByCategoryData.fromJson(e))
          .toList(),
      byCategoryExpense: ((json['byCategoryExpense'] ?? []) as List)
          .map((e) => ByCategoryData.fromJson(e))
          .toList(),
    );

    if (json['byMonthStatistic'] != null) {
      data.byMonthStatistic = (json['byMonthStatistic'] as List)
          .map((e) => StatisticData.fromJson(e))
          .toList();
    }

    if (json['byQuarterStatistic'] != null) {
      data.byQuarterStatistic = (json['byQuarterStatistic'] as List)
          .map((e) => StatisticData.fromJson(e))
          .toList();
    }

    return data;
  }

  factory StatisticData.defaultData(){
    return StatisticData(
      totalIncome: 0,
      totalExpense: 0,
      byCategoryIncome: [],
      byCategoryExpense: [],
      byMonthStatistic: [],
      byQuarterStatistic: [],
    );
  }
}


class ByCategoryData {
  Category category;
  double amount;
  List<Transaction> transactions;

  ByCategoryData({
    required this.category,
    required this.amount,
    required this.transactions,
  });

  factory ByCategoryData.fromJson(Map<String, dynamic> json) {
    return ByCategoryData(
      category: Category.fromContext(json['id']),
      amount: json['amount'].toDouble(),
      transactions: ((json['transactionIds'] ?? []) as List)
          .map((e) => Transaction.fromContext(e))
          .toList(),
    );
  }
}

class CompactStatisticData {
  double totalIncome;
  double totalExpense;

  CompactStatisticData({
    required this.totalIncome,
    required this.totalExpense,
  });

  factory CompactStatisticData.fromJson(Map<String, dynamic> json) {
    return CompactStatisticData(
      totalIncome: json['totalIncome'].toDouble(),
      totalExpense: json['totalExpense'].toDouble(),
    );
  }

  factory CompactStatisticData.defaultData() {
    return CompactStatisticData(
      totalIncome: 0,
      totalExpense: 0,
    );
  }
}
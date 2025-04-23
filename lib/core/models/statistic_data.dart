import 'category.dart';

class StatisticData {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;

  final List<ByCategoryData> byCategoryIncome;
  final List<ByCategoryData> byCategoryExpense;

  StatisticData({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.byCategoryIncome,
    required this.byCategoryExpense,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    return StatisticData(
      totalIncome: json['totalIncome'].toDouble(),
      totalExpense: json['totalExpense'].toDouble(),
      totalBalance: json['totalBalance'].toDouble(),
      byCategoryIncome: (json['byCategoryIncome'] as List)
          .map((e) => ByCategoryData.fromJson(e))
          .toList(),
      byCategoryExpense: (json['byCategoryExpense'] as List)
          .map((e) => ByCategoryData.fromJson(e))
          .toList(),
    );
  }

  factory StatisticData.defaultData(){
    return StatisticData(
      totalIncome: 0,
      totalExpense: 0,
      totalBalance: 0,
      byCategoryIncome: [],
      byCategoryExpense: [],
    );
  }
}


class ByCategoryData {
  final Category category;
  final double amount;

  ByCategoryData({
    required this.category,
    required this.amount,
  });

  factory ByCategoryData.fromJson(Map<String, dynamic> json) {
    return ByCategoryData(
      category: Category.fromContext(json['id']),
      amount: json['amount'].toDouble(),
    );
  }
}
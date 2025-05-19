import 'category.dart';

class StatisticData {
  double totalIncome;
  double totalExpense;
  double totalBalance;

  List<ByCategoryData> byCategoryIncome;
  List<ByCategoryData> byCategoryExpense;

  //only for year statistic
  List<StatisticData>? byMonthStatistic = [];
  List<StatisticData>? byQuarterStatistic = [];

  StatisticData({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.byCategoryIncome,
    required this.byCategoryExpense,
    this.byMonthStatistic,
    this.byQuarterStatistic,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    final data = StatisticData(
      totalIncome: json['totalIncome'].toDouble(),
      totalExpense: json['totalExpense'].toDouble(),
      totalBalance: json['totalBalance'] != null ? json['totalBalance'].toDouble() : 0,
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
      totalBalance: 0,
      byCategoryIncome: [],
      byCategoryExpense: [],
      byMonthStatistic: [],
      byQuarterStatistic: [],
    );
  }
}


class ByCategoryData {
  final Category category;
  double amount;

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
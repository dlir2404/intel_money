import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/services/statistic_service.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../../shared/helper/app_time.dart';
import '../models/statistic_data.dart';
import '../models/transaction.dart';

class StatisticState extends ChangeNotifier {
  static final StatisticState _instance = StatisticState._internal();
  factory StatisticState() => _instance;
  StatisticState._internal();

  StatisticData? _todayStatisticData;
  StatisticData? _thisWeekStatisticData;
  StatisticData? _thisMonthStatisticData;
  StatisticData? _thisQuarterStatisticData;
  StatisticData? _thisYearStatisticData;

  StatisticData? get todayStatisticData => _todayStatisticData;
  void setTodayStatisticData(StatisticData statisticData) {
    _todayStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisWeekStatisticData {
    if (_thisWeekStatisticData != null) {
      return _thisWeekStatisticData;
    }

    StatisticService().getThisWeekStatisticData();
    return _thisWeekStatisticData;
  }
  void setThisWeekStatisticData(StatisticData statisticData) {
    _thisWeekStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisMonthStatisticData {
    if (_thisMonthStatisticData != null) {
      return _thisMonthStatisticData;
    }

    StatisticService().getThisMonthStatisticData();
    return _thisMonthStatisticData;
  }
  void setThisMonthStatisticData(StatisticData statisticData) {
    _thisMonthStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisQuarterStatisticData {
    if (_thisQuarterStatisticData != null) {
      return _thisQuarterStatisticData;
    }

    StatisticService().getThisQuarterStatisticData();
    return _thisQuarterStatisticData;
  }
  void setThisQuarterStatisticData(StatisticData statisticData) {
    _thisQuarterStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisYearStatisticData {
    if (_thisYearStatisticData != null) {
      return _thisYearStatisticData;
    }

    StatisticService().getThisYearStatisticData();
    return _thisYearStatisticData;
  }
  void setThisYearStatisticData(StatisticData statisticData) {
    _thisYearStatisticData = statisticData;
    notifyListeners();
  }

  void updateStatisticData(Transaction newTransaction) {
    if (AppTime.isToday(newTransaction.transactionDate)) {
      if (newTransaction.type == TransactionType.expense) {
        _todayStatisticData!.totalExpense += newTransaction.amount;

        int categoryIndex = _todayStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == newTransaction.category!.id);
        if (categoryIndex != -1) {
          _todayStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
        } else {
          _todayStatisticData!.byCategoryExpense.add(ByCategoryData(
            category: newTransaction.category!,
            amount: newTransaction.amount,
          ));
        }

      } else if (newTransaction.type == TransactionType.income) {
        _todayStatisticData!.totalIncome += newTransaction.amount;

        int categoryIndex = _todayStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == newTransaction.category!.id);
        if (categoryIndex != -1) {
          _todayStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        } else {
          _todayStatisticData!.byCategoryIncome.add(ByCategoryData(
            category: newTransaction.category!,
            amount: newTransaction.amount,
          ));
        }
      }
    }

    notifyListeners();
  }
}
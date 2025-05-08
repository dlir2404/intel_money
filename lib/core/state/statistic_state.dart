import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/services/statistic_service.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../../shared/helper/app_time.dart';
import '../models/analysis_data.dart';
import '../models/category.dart';
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

  List<AnalysisData>? _byDayAnalysisData;
  List<AnalysisData>? get byDayAnalysisData {
    if (_byDayAnalysisData != null) {
      return _byDayAnalysisData;
    }

    StatisticService().getByDayAnalysisData(AppTime.startOfMonth(), AppTime.endOfToday());
    return _byDayAnalysisData;
  }
  void setByDayAnalysisData(List<AnalysisData> analysisData) {
    _byDayAnalysisData = analysisData;
    notifyListeners();
  }

  List<AnalysisData>? _byMonthAnalysisData;
  List<AnalysisData>? get byMonthAnalysisData {
    if (_byMonthAnalysisData != null) {
      return _byMonthAnalysisData;
    }

    StatisticService().getByMonthAnalysisData(AppTime.startOfYear(), AppTime.endOfMonth());
    return _byMonthAnalysisData;
  }
  void setByMonthAnalysisData(List<AnalysisData> analysisData) {
    _byMonthAnalysisData = analysisData;
    notifyListeners();
  }

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
      updateTodayStatisticData(newTransaction);
    }

    if (AppTime.isThisWeek(newTransaction.transactionDate)) {
      updateThisWeekStatisticData(newTransaction);
    }

    if (AppTime.isThisMonth(newTransaction.transactionDate)) {
      updateThisMonthStatisticData(newTransaction);
    }

    if (AppTime.isThisQuarter(newTransaction.transactionDate)) {
      updateThisQuarterStatisticData(newTransaction);
    }

    if (AppTime.isThisYear(newTransaction.transactionDate)) {
      updateThisYearStatisticData(newTransaction);
    }

    notifyListeners();
  }

  void updateTodayStatisticData(Transaction newTransaction) {
    if (newTransaction.type == TransactionType.expense) {
      _todayStatisticData!.totalExpense += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _todayStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _todayStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
      } else {
        _todayStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _todayStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _todayStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _todayStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
      } else {
        _todayStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }
    }
  }

  void updateThisWeekStatisticData(Transaction newTransaction) {
    if (_thisWeekStatisticData == null){
      return;
    }

    if (newTransaction.type == TransactionType.expense) {
      _thisWeekStatisticData!.totalExpense += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisWeekStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisWeekStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisWeekStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisWeekStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisWeekStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisWeekStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisWeekStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }
    }
  }

  void updateThisMonthStatisticData(Transaction newTransaction) {
    if (_thisMonthStatisticData == null){
      return;
    }

    if (newTransaction.type == TransactionType.expense) {
      _thisMonthStatisticData!.totalExpense += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisMonthStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisMonthStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisMonthStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisMonthStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisMonthStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisMonthStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisMonthStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }
    }
  }

  void updateThisQuarterStatisticData(Transaction newTransaction) {
    if (_thisQuarterStatisticData == null){
      return;
    }

    if (newTransaction.type == TransactionType.expense) {
      _thisQuarterStatisticData!.totalExpense += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisQuarterStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisQuarterStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisQuarterStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisQuarterStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisQuarterStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisQuarterStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisQuarterStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }
    }
  }

  void updateThisYearStatisticData(Transaction newTransaction) {
    if (_thisYearStatisticData == null){
      return;
    }

    if (newTransaction.type == TransactionType.expense) {
      _thisYearStatisticData!.totalExpense += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisYearStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisYearStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisYearStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisYearStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisYearStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisYearStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
      } else {
        _thisYearStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
        ));
      }
    }
  }
}
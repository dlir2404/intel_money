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

  List<AnalysisData>? _byYearAnalysisData;
  List<AnalysisData>? get byYearAnalysisData {
    if (_byYearAnalysisData != null) {
      return _byYearAnalysisData;
    }

    //get 10 years data
    StatisticService().getByYearAnalysisData(AppTime.startOfYear(date: DateTime(DateTime.now().year - 10)), AppTime.startOfYear());
    return _byYearAnalysisData;
  }
  void setByYearAnalysisData(List<AnalysisData> analysisData) {
    _byYearAnalysisData = analysisData;
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
        _todayStatisticData!.byCategoryExpense[categoryIndex].transactions.add(newTransaction);
      } else {
        _todayStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _todayStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _todayStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _todayStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        _todayStatisticData!.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
      } else {
        _todayStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
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
        _thisWeekStatisticData!.byCategoryExpense[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisWeekStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisWeekStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisWeekStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisWeekStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        _thisWeekStatisticData!.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisWeekStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
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
        _thisMonthStatisticData!.byCategoryExpense[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisMonthStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisMonthStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisMonthStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisMonthStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        _thisMonthStatisticData!.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisMonthStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
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
        _thisQuarterStatisticData!.byCategoryExpense[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisQuarterStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

    } else if (newTransaction.type == TransactionType.income) {
      _thisQuarterStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisQuarterStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      if (categoryIndex != -1) {
        _thisQuarterStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        _thisQuarterStatisticData!.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisQuarterStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
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
      //by category expense
      if (categoryIndex != -1) {
        _thisYearStatisticData!.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
        _thisYearStatisticData!.byCategoryExpense[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisYearStatisticData!.byCategoryExpense.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

      //by month statistic
      final month = newTransaction.transactionDate.month;
      _thisYearStatisticData!.byMonthStatistic![month - 1].totalExpense += newTransaction.amount;

      //by quarter statistic
      final quarter = (newTransaction.transactionDate.month / 3).toInt() + 1;
      _thisYearStatisticData!.byQuarterStatistic![quarter - 1].totalExpense += newTransaction.amount;
    } else if (newTransaction.type == TransactionType.income) {
      _thisYearStatisticData!.totalIncome += newTransaction.amount;

      int categoryId = newTransaction.category!.parentId ?? newTransaction.category!.id;
      int categoryIndex = _thisYearStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      // by category income
      if (categoryIndex != -1) {
        _thisYearStatisticData!.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
        _thisYearStatisticData!.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
      } else {
        _thisYearStatisticData!.byCategoryIncome.add(ByCategoryData(
          category: Category.fromContext(categoryId),
          amount: newTransaction.amount,
          transactions: [newTransaction],
        ));
      }

      //by month statistic
      final month = newTransaction.transactionDate.month;
      _thisYearStatisticData!.byMonthStatistic![month - 1].totalIncome += newTransaction.amount;

      //by quarter statistic
      final quarter = (newTransaction.transactionDate.month / 3).toInt() + 1;
      _thisYearStatisticData!.byQuarterStatistic![quarter - 1].totalIncome += newTransaction.amount;
    }
  }
}
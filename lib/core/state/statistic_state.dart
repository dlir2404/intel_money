import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/services/statistic_service.dart';
import 'package:intel_money/features/reports/controller/statistic_controller.dart';

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

  //These data do not applied filters
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

    StatisticController().getThisWeekStatisticDataV2();
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

    StatisticController().getThisMonthStatisticDataV2();
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

    StatisticController().getThisQuarterStatisticDataV2();
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

    StatisticController().getThisYearStatisticDataV2();
    return _thisYearStatisticData;
  }
  void setThisYearStatisticData(StatisticData statisticData) {
    _thisYearStatisticData = statisticData;
    notifyListeners();
  }

  void recalculateStatisticData() {
    StatisticController().getTodayStatisticDataV2();

    if (_thisWeekStatisticData != null) {
      StatisticController().getThisWeekStatisticDataV2();
    }

    if (_thisMonthStatisticData != null) {
      StatisticController().getThisMonthStatisticDataV2();
    }

    if (_thisQuarterStatisticData != null) {
      StatisticController().getThisQuarterStatisticDataV2();
    }

    if (_thisYearStatisticData != null) {
      StatisticController().getThisYearStatisticDataV2();
    }
  }

  void updateStatisticDataAfterCreateTransaction(Transaction newTransaction) {
    if (AppTime.isToday(newTransaction.transactionDate)) {
      _todayStatisticData = StatisticController.calculateNewStatisticDataAfterCreateTransaction(
        newTransaction: newTransaction,
        oldData: _todayStatisticData!,
      );
    }

    if (_thisWeekStatisticData != null && AppTime.isThisWeek(newTransaction.transactionDate)) {
      _thisWeekStatisticData = StatisticController.calculateNewStatisticDataAfterCreateTransaction(
        newTransaction: newTransaction,
        oldData: _thisWeekStatisticData!,
      );
    }

    if (_thisMonthStatisticData != null && AppTime.isThisMonth(newTransaction.transactionDate)) {
      _thisMonthStatisticData = StatisticController.calculateNewStatisticDataAfterCreateTransaction(
        newTransaction: newTransaction,
        oldData: _thisMonthStatisticData!,
      );
    }

    if (_thisQuarterStatisticData != null && AppTime.isThisQuarter(newTransaction.transactionDate)) {
      _thisQuarterStatisticData = StatisticController.calculateNewStatisticDataAfterCreateTransaction(
        newTransaction: newTransaction,
        oldData: _thisQuarterStatisticData!,
      );
    }

    //TODO: replace this
    if (AppTime.isThisYear(newTransaction.transactionDate)) {
      updateThisYearStatisticDataAfterCreateTransaction(newTransaction);
    }

    notifyListeners();
  }

  void updateStatisticDataAfterRemoveTransaction(Transaction removedTransaction) {
    if (AppTime.isToday(removedTransaction.transactionDate)) {
      _todayStatisticData = StatisticController.calculateNewStatisticDataAfterRemoveTransaction(
        removedTransaction: removedTransaction,
        oldData: _todayStatisticData!,
      );
    }

    if (_thisWeekStatisticData != null && AppTime.isThisWeek(removedTransaction.transactionDate)) {
      _thisWeekStatisticData = StatisticController.calculateNewStatisticDataAfterRemoveTransaction(
        removedTransaction: removedTransaction,
        oldData: _thisWeekStatisticData!,
      );
    }

    if (_thisMonthStatisticData != null && AppTime.isThisMonth(removedTransaction.transactionDate)) {
      _thisMonthStatisticData = StatisticController.calculateNewStatisticDataAfterRemoveTransaction(
        removedTransaction: removedTransaction,
        oldData: _thisMonthStatisticData!,
      );
    }

    if (_thisQuarterStatisticData != null && AppTime.isThisQuarter(removedTransaction.transactionDate)) {
      _thisQuarterStatisticData = StatisticController.calculateNewStatisticDataAfterRemoveTransaction(
        removedTransaction: removedTransaction,
        oldData: _thisQuarterStatisticData!,
      );
    }

    //TODO: replace this
    if (AppTime.isThisYear(removedTransaction.transactionDate)) {
      updateThisYearStatisticDataAfterRemoveTransaction(removedTransaction);
    }

    notifyListeners();
  }

  ///This data is the most complex one cause it has by month and by quarter statistic
  void updateThisYearStatisticDataAfterCreateTransaction(Transaction newTransaction) {
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

  void updateThisYearStatisticDataAfterRemoveTransaction(Transaction removedTransaction) {
    if (_thisYearStatisticData == null) {
      return;
    }

    if (removedTransaction.type == TransactionType.expense) {
      _thisYearStatisticData!.totalExpense -= removedTransaction.amount;

      int categoryId = removedTransaction.category!.parentId ?? removedTransaction.category!.id;
      int categoryIndex = _thisYearStatisticData!.byCategoryExpense.indexWhere((element) => element.category.id == categoryId);
      //by category expense
      if (categoryIndex != -1) {
        if (_thisYearStatisticData!.byCategoryExpense[categoryIndex].transactions.length > 1) {
          _thisYearStatisticData!.byCategoryExpense[categoryIndex].amount -= removedTransaction.amount;
          _thisYearStatisticData!.byCategoryExpense[categoryIndex].transactions.removeWhere((element) => element.id == removedTransaction.id);
        } else {
          _thisYearStatisticData!.byCategoryExpense.removeAt(categoryIndex);
        }
      }

      //by month statistic
      final month = removedTransaction.transactionDate.month;
      _thisYearStatisticData!.byMonthStatistic![month - 1].totalExpense -= removedTransaction.amount;

      //by quarter statistic
      final quarter = (removedTransaction.transactionDate.month / 3).toInt() + 1;
      _thisYearStatisticData!.byQuarterStatistic![quarter - 1].totalExpense -= removedTransaction.amount;
    } else if (removedTransaction.type == TransactionType.income) {
      _thisYearStatisticData!.totalIncome -= removedTransaction.amount;

      int categoryId = removedTransaction.category!.parentId ?? removedTransaction.category!.id;
      int categoryIndex = _thisYearStatisticData!.byCategoryIncome.indexWhere((element) => element.category.id == categoryId);
      // by category income
      if (categoryIndex != -1) {
        if (_thisYearStatisticData!.byCategoryIncome[categoryIndex].transactions.length > 1) {
          _thisYearStatisticData!.byCategoryIncome[categoryIndex].amount -= removedTransaction.amount;
          _thisYearStatisticData!.byCategoryIncome[categoryIndex].transactions.removeWhere((element) => element.id == removedTransaction.id);
        } else {
          _thisYearStatisticData!.byCategoryIncome.removeAt(categoryIndex);
        }
      }

      //by month statistic
      final month = removedTransaction.transactionDate.month;
      _thisYearStatisticData!.byMonthStatistic![month - 1].totalIncome -= removedTransaction.amount;

      //by quarter statistic
      final quarter = (removedTransaction.transactionDate.month / 3).toInt() + 1;
      _thisYearStatisticData!.byQuarterStatistic![quarter - 1].totalIncome -= removedTransaction.amount;
    }
  }
}
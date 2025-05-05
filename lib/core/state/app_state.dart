import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/models/user.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../models/statistic_data.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  //system config
  Currency? _currency = CurrencyService().findByCode("VND");
  Currency? get currency => _currency;
  void setCurrency(Currency? currency) {
    _currency = currency;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void decreaseUserBalance(double amount) {
    _user!.totalBalance -= amount;
    notifyListeners();
  }

  void increaseUserBalance(double amount) {
    _user!.totalBalance += amount;
    notifyListeners();
  }


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

  StatisticData? get thisWeekStatisticData => _thisWeekStatisticData;
  void setThisWeekStatisticData(StatisticData statisticData) {
    _thisWeekStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisMonthStatisticData => _thisMonthStatisticData;
  void setThisMonthStatisticData(StatisticData statisticData) {
    _thisMonthStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisQuarterStatisticData => _thisQuarterStatisticData;
  void setThisQuarterStatisticData(StatisticData statisticData) {
    _thisQuarterStatisticData = statisticData;
    notifyListeners();
  }

  StatisticData? get thisYearStatisticData => _thisYearStatisticData;
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

  void clear() {
    _user = null;
    notifyListeners();
  }
}

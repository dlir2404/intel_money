import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../models/analysis_data.dart';
import '../models/category.dart';
import '../models/statistic_data.dart';
import '../models/wallet.dart';
import '../network/api_client.dart';

class StatisticService {
  final ApiClient _apiClient = ApiClient.instance;

  static final StatisticService _instance = StatisticService._internal();

  factory StatisticService() => _instance;

  StatisticService._internal();

  Future<StatisticData> getTodayStatisticDataV2() async {
    final todayTransactions =
        TransactionState().transactions.where((transaction) {
          return AppTime.isToday(transaction.transactionDate);
        }).toList();

    final statisticData = calculateStatistic(transactions: todayTransactions);

    return statisticData;
  }

  Future<StatisticData> getThisWeekStatisticDataV2() async {
    final thisWeekTransactions =
        TransactionState().transactions.where((transaction) {
          return AppTime.isThisWeek(transaction.transactionDate);
        }).toList();

    final statisticData = calculateStatistic(
      transactions: thisWeekTransactions,
    );

    return statisticData;
  }

  Future<StatisticData> getThisMonthStatisticDataV2() async {
    final thisMonthTransactions =
        TransactionState().transactions.where((transaction) {
          return AppTime.isThisMonth(transaction.transactionDate);
        }).toList();

    final statisticData = calculateStatistic(
      transactions: thisMonthTransactions,
    );

    return statisticData;
  }

  Future<StatisticData> getThisQuarterStatisticDataV2() async {
    final thisQuarterTransactions =
        TransactionState().transactions.where((transaction) {
          return AppTime.isThisQuarter(transaction.transactionDate);
        }).toList();

    final statisticData = calculateStatistic(
      transactions: thisQuarterTransactions,
    );

    return statisticData;
  }

  Future<StatisticData> getThisYearStatisticDataV2() async {
    final thisYearTransactions =
        TransactionState().transactions.where((transaction) {
          return AppTime.isThisYear(transaction.transactionDate);
        }).toList();

    final statisticData = calculateStatistic(
      transactions: thisYearTransactions,
    );

    List<StatisticData> byMonthStatistic = [];
    for (int month = 1; month <= 12; month++) {
      final monthlyStatistic = getMonthlyStatisticData(
        transactions: thisYearTransactions,
        month: month,
        year: DateTime.now().year,
      );
      byMonthStatistic.add(monthlyStatistic);
    }
    statisticData.byMonthStatistic = byMonthStatistic;

    List<StatisticData> byQuarterStatistic = [];
    for (int quarter = 1; quarter <= 4; quarter++) {
      final quarterlyStatistic = getQuarterlyStatisticData(
        transactions: thisYearTransactions,
        quarter: quarter,
        year: DateTime.now().year,
      );
      byQuarterStatistic.add(quarterlyStatistic);
    }
    statisticData.byQuarterStatistic = byQuarterStatistic;

    return statisticData;
  }

  Future<StatisticData> getCustomRangeStatisticData(
    DateTime from,
    DateTime to,
  ) async {
    final response = await _apiClient.get(
      '/statistic/custom-range',
      params: {
        'from': AppTime.toUtcIso8601String(from),
        'to': AppTime.toUtcIso8601String(to),
      },
    );

    final statisticData = StatisticData.fromJson(response);
    return statisticData;
  }

  Future<StatisticData> getCustomRangeStatisticDataV2(
    DateTime from,
    DateTime to,
  ) async {
    final transactions = TransactionState().transactions.where((transaction) {
      return (transaction.transactionDate.isAfter(from) || transaction.transactionDate.isAtSameMomentAs(from)) &&
             transaction.transactionDate.isBefore(to);
    }).toList();

    final statisticData = calculateStatistic(transactions: transactions);
    return statisticData;
  }

  Future<List<AnalysisData>> getByDayAnalysisData(
    DateTime from,
    DateTime to,
  ) async {
    final response = await _apiClient.get(
      '/statistic/by-day',
      params: {
        'from': AppTime.toUtcIso8601String(from),
        'to': AppTime.toUtcIso8601String(to),
      },
    );

    final analysisData =
        (response as List)
            .map((analysisData) => AnalysisData.fromJson(analysisData))
            .toList();

    return analysisData;
  }

  Future<List<AnalysisData>> getByDayAnalysisDataV2({
    required DateTime from,
    required DateTime to,
    List<Category>? categories,
    List<Wallet>? wallets
  }) async {
    final transactions = TransactionState().transactions.where((transaction) {
      if (wallets != null) {
        if (!wallets.any((wallet) => wallet.id == transaction.sourceWallet.id)) {
          return false;
        }
      }

      return (transaction.transactionDate.isAfter(from) || transaction.transactionDate.isAtSameMomentAs(from)) &&
             transaction.transactionDate.isBefore(to);
    }).toList();

    Map<DateTime, List<Transaction>> transactionMap = {};
    List<DateTime> daysRange = AppTime.daysBetween(from, to);
    for (final day in daysRange) {
      transactionMap[day] = [];
    }

    for (final transaction in transactions) {
      final date = AppTime.startOfDay(transaction.transactionDate);
      transactionMap[date]!.add(transaction);
    }

    final analysisData = transactionMap.entries.map((entry) {
      final date = entry.key;
      final dailyTransactions = entry.value;

      final statisticData = calculateCompactStatistic(transactions: dailyTransactions);
      return AnalysisData(
        date: date,
        compactStatisticData: statisticData,
      );
    }).toList();

    return analysisData;
  }

  Future<List<AnalysisData>> getByMonthAnalysisData(
    DateTime from,
    DateTime to,
  ) async {
    final response = await _apiClient.get(
      '/statistic/by-month',
      params: {
        'from': AppTime.toUtcIso8601String(from),
        'to': AppTime.toUtcIso8601String(to),
      },
    );

    final analysisData =
        (response as List)
            .map((analysisData) => AnalysisData.fromJson(analysisData))
            .toList();

    // _state.setByMonthAnalysisData(analysisData);

    return analysisData;
  }

  Future<List<AnalysisData>> getByMonthAnalysisDataV2({
    required DateTime from,
    required DateTime to,
    List<Category>? categories,
    List<Wallet>? wallets
  }) async {
    final transactions = TransactionState().transactions.where((transaction) {
      if (wallets != null) {
        if (!wallets.any((wallet) => wallet.id == transaction.sourceWallet.id)) {
          return false;
        }
      }

      return (transaction.transactionDate.isAfter(from) ||
          transaction.transactionDate.isAtSameMomentAs(from)) &&
          transaction.transactionDate.isBefore(to);
    }).toList();

    Map<DateTime, List<Transaction>> transactionMap = {};
    List<DateTime> monthsRange = AppTime.monthsBetween(from, to);
    for (final month in monthsRange) {
      transactionMap[month] = [];
    }

    for (final transaction in transactions) {
      final date = DateTime(transaction.transactionDate.year, transaction.transactionDate.month);
      transactionMap[date]!.add(transaction);
    }

    final analysisData = transactionMap.entries.map((entry) {
      final date = entry.key;
      final monthlyTransactions = entry.value;

      final statisticData = calculateCompactStatistic(transactions: monthlyTransactions);
      return AnalysisData(
        date: date,
        compactStatisticData: statisticData,
      );
    }).toList();

    return analysisData;
  }

  Future<void> getByYearAnalysisData(DateTime from, DateTime to) async {
    final response = await _apiClient.get(
      '/statistic/by-year',
      params: {
        'from': AppTime.toUtcIso8601String(from),
        'to': AppTime.toUtcIso8601String(to),
      },
    );

    final analysisData =
        (response as List)
            .map((analysisData) => AnalysisData.fromJson(analysisData))
            .toList();

    // _state.setByYearAnalysisData(analysisData);
  }

  Future<List<AnalysisData>> getByYearAnalysisDataV2({
    required DateTime from,
    required DateTime to,
    List<Category>? categories,
    List<Wallet>? wallets
  }) async {
    final transactions = TransactionState().transactions.where((transaction) {
      if (wallets != null) {
        if (!wallets.any((wallet) => wallet.id == transaction.sourceWallet.id)) {
          return false;
        }
      }

      return (transaction.transactionDate.isAfter(from) ||
          transaction.transactionDate.isAtSameMomentAs(from)) &&
          transaction.transactionDate.isBefore(to);
    }).toList();

    Map<DateTime, List<Transaction>> transactionMap = {};
    List<DateTime> yearsRange = AppTime.yearsBetween(from, to);
    for (final year in yearsRange) {
      transactionMap[year] = [];
    }

    for (final transaction in transactions) {
      final date = DateTime(transaction.transactionDate.year);
      transactionMap[date]!.add(transaction);
    }

    final analysisData = transactionMap.entries.map((entry) {
      final date = entry.key;
      final yearlyTransactions = entry.value;

      final statisticData = calculateCompactStatistic(transactions: yearlyTransactions);
      return AnalysisData(
        date: date,
        compactStatisticData: statisticData,
      );
    }).toList();

    return analysisData;
  }

  /// month from 1 to 12
  /// year is the full year (e.g. 2023)
  StatisticData getMonthlyStatisticData({
    required List<Transaction> transactions,
    required int month,
    required int year,
    List<Category>? categories,
    List<Wallet>? wallets,
  }) {
    final filteredTransactions = transactions.where((transaction) {
      return transaction.transactionDate.month == month &&
          transaction.transactionDate.year == year;
    }).toList();

    final statisticData = calculateStatistic(transactions: filteredTransactions);

    return statisticData;
  }

  StatisticData getQuarterlyStatisticData({
    required List<Transaction> transactions,
    required int quarter,
    required int year,
    List<Category>? categories,
    List<Wallet>? wallets,
  }) {
    final filteredTransactions = transactions.where((transaction) {
      final month = transaction.transactionDate.month;
      final transactionYear = transaction.transactionDate.year;

      if (transactionYear != year) return false;

      switch (quarter) {
        case 1:
          return month >= 1 && month <= 3;
        case 2:
          return month >= 4 && month <= 6;
        case 3:
          return month >= 7 && month <= 9;
        case 4:
          return month >= 10 && month <= 12;
        default:
          return false;
      }
    }).toList();

    final statisticData = calculateStatistic(transactions: filteredTransactions);

    return statisticData;
  }

  /// NEW
  StatisticData calculateStatistic({
    required List<Transaction> transactions,
    bool includeLoanDebt = false,
  }) {
    double totalIncome = 0;
    double totalExpense = 0;

    final byCategoryIncome = <ByCategoryData>[];
    final byCategoryExpense = <ByCategoryData>[];

    final addIncomeCategoryIds = <int>[];
    final addExpenseCategoryIds = <int>[];

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;

        //use parent category id if available, otherwise use the category id
        int categoryId = transaction.category!.id;
        Category category = transaction.category!;

        if (category.parentId != null) {
          categoryId = category.parentId!;
          category = Category.fromContext(categoryId);
        }

        final existIndex = addIncomeCategoryIds.indexOf(categoryId);
        if (existIndex == -1) {
          addIncomeCategoryIds.add(categoryId);

          byCategoryIncome.add(
            ByCategoryData(
              category: category,
              amount: transaction.amount,
              transactions: [transaction],
            ),
          );
        } else {
          ByCategoryData data = byCategoryIncome.firstWhere(
            (element) => element.category.id == categoryId,
          );
          data.amount += transaction.amount;
          data.transactions.add(transaction);
        }
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;

        //use parent category id if available, otherwise use the category id
        int categoryId = transaction.category!.id;
        Category category = transaction.category!;

        if (category.parentId != null) {
          categoryId = category.parentId!;
          category = Category.fromContext(categoryId);
        }

        final existIndex = addExpenseCategoryIds.indexOf(categoryId);
        if (existIndex == -1) {
          addExpenseCategoryIds.add(categoryId);

          byCategoryExpense.add(
            ByCategoryData(
              category: category,
              amount: transaction.amount,
              transactions: [transaction],
            ),
          );
        } else {
          ByCategoryData data = byCategoryExpense.firstWhere(
            (element) => element.category.id == categoryId,
          );
          data.amount += transaction.amount;
          data.transactions.add(transaction);
        }
      } else if (transaction.type == TransactionType.modifyBalance) {
        if (transaction.amount > 0) {
          //handle as income
          totalIncome += transaction.amount;

          //use parent category id if available, otherwise use the category id
          int categoryId = transaction.category!.id;
          Category category = transaction.category!;

          if (category.parentId != null) {
            categoryId = category.parentId!;
            category = Category.fromContext(categoryId);
          }

          final existIndex = addIncomeCategoryIds.indexOf(categoryId);
          if (existIndex == -1) {
            addIncomeCategoryIds.add(categoryId);

            byCategoryIncome.add(
              ByCategoryData(
                category: category,
                amount: transaction.amount,
                transactions: [transaction],
              ),
            );
          } else {
            ByCategoryData data = byCategoryIncome.firstWhere(
              (element) => element.category.id == categoryId,
            );
            data.amount += transaction.amount;
            data.transactions.add(transaction);
          }
        } else {
          totalExpense += transaction.amount.abs();

          //use parent category id if available, otherwise use the category id
          int categoryId = transaction.category!.id;
          Category category = transaction.category!;

          if (category.parentId != null) {
            categoryId = category.parentId!;
            category = Category.fromContext(categoryId);
          }

          final existIndex = addExpenseCategoryIds.indexOf(categoryId);
          if (existIndex == -1) {
            addExpenseCategoryIds.add(categoryId);

            byCategoryExpense.add(
              ByCategoryData(
                category: category,
                amount: transaction.amount.abs(),
                transactions: [transaction],
              ),
            );
          } else {
            ByCategoryData data = byCategoryExpense.firstWhere(
              (element) => element.category.id == categoryId,
            );
            data.amount += transaction.amount.abs();
            data.transactions.add(transaction);
          }
        }
      }
    }

    return StatisticData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      byCategoryIncome: byCategoryIncome,
      byCategoryExpense: byCategoryExpense,
    );
  }

  CompactStatisticData calculateCompactStatistic({
    required List<Transaction> transactions,
  }) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      } else if (transaction.type == TransactionType.modifyBalance) {
        if (transaction.amount > 0) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount.abs();
        }
      }
    }

    return CompactStatisticData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}

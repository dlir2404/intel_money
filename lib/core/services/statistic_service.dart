import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../models/analysis_data.dart';
import '../models/category.dart';
import '../models/statistic_data.dart';
import '../network/api_client.dart';

class StatisticService {
  final StatisticState _state = StatisticState();
  final ApiClient _apiClient = ApiClient.instance;

  static final StatisticService _instance = StatisticService._internal();

  factory StatisticService() => _instance;

  StatisticService._internal();

  Future<void> getTodayStatisticData() async {
    final response = await _apiClient.get('/statistic/today');

    final statisticData = StatisticData.fromJson(response);

    _state.setTodayStatisticData(statisticData);
  }

  Future<void> getTodayStatisticDataV2() async {
    final todayTransactions = TransactionState().transactions.where((transaction) {
      return AppTime.isToday(transaction.transactionDate);
    }).toList();

    final statisticData = calculateStatistic(
      transactions: todayTransactions,
    );

    _state.setTodayStatisticData(statisticData);
  }

  Future<void> getThisWeekStatisticData() async {
    final response = await _apiClient.get('/statistic/this-week');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisWeekStatisticData(statisticData);
  }

  Future<void> getThisWeekStatisticDataV2() async {
    final thisWeekTransactions = TransactionState().transactions.where((transaction) {
      return AppTime.isThisWeek(transaction.transactionDate);
    }).toList();

    final statisticData = calculateStatistic(
      transactions: thisWeekTransactions,
    );

    _state.setThisWeekStatisticData(statisticData);
  }

  Future<void> getThisMonthStatisticData() async {
    final response = await _apiClient.get('/statistic/this-month');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisMonthStatisticData(statisticData);
  }

  Future<void> getThisMonthStatisticDataV2() async {
    final thisMonthTransactions = TransactionState().transactions.where((transaction) {
      return AppTime.isThisMonth(transaction.transactionDate);
    }).toList();

    final statisticData = calculateStatistic(
      transactions: thisMonthTransactions,
    );

    _state.setThisMonthStatisticData(statisticData);
  }

  Future<void> getThisQuarterStatisticData() async {
    final response = await _apiClient.get('/statistic/this-quarter');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisQuarterStatisticData(statisticData);
  }

  Future<void> getThisQuarterStatisticDataV2() async {
    final thisQuarterTransactions = TransactionState().transactions.where((transaction) {
      return AppTime.isThisQuarter(transaction.transactionDate);
    }).toList();

    final statisticData = calculateStatistic(
      transactions: thisQuarterTransactions,
    );

    _state.setThisQuarterStatisticData(statisticData);
  }

  Future<void> getThisYearStatisticData() async {
    final response = await _apiClient.get('/statistic/this-year');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisYearStatisticData(statisticData);
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

    _state.setByMonthAnalysisData(analysisData);

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

    _state.setByYearAnalysisData(analysisData);
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
      }
    }

    return StatisticData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      byCategoryIncome: byCategoryIncome,
      byCategoryExpense: byCategoryExpense,
    );
  }
}

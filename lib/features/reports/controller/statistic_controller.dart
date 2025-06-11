import 'package:intel_money/core/services/statistic_service.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/models/category.dart';
import '../../../core/models/statistic_data.dart';
import '../../../core/models/transaction.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/const/enum/transaction_type.dart';

class StatisticController {
  static final StatisticController _instance = StatisticController._internal();

  factory StatisticController() => _instance;

  StatisticController._internal();

  final StatisticState _state = StatisticState();
  final StatisticService _statisticService = StatisticService();

  Future<List<AnalysisData>> getByDayAnalysisData({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _statisticService.getByDayAnalysisDataV2(from: from, to: to);
  }

  Future<List<AnalysisData>> getByMonthAnalysisData({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _statisticService.getByMonthAnalysisDataV2(from: from, to: to);
  }

  Future<List<AnalysisData>> getByYearAnalysisData({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _statisticService.getByYearAnalysisDataV2(from: from, to: to);
  }

  Future<void> getTodayStatisticDataV2() async {
    final statisticData = await _statisticService.getTodayStatisticDataV2();
    _state.setTodayStatisticData(statisticData);
  }

  Future<void> getThisWeekStatisticDataV2() async {
    final statisticData = await _statisticService.getThisWeekStatisticDataV2();
    _state.setThisWeekStatisticData(statisticData);
  }

  Future<void> getThisMonthStatisticDataV2() async {
    final statisticData = await _statisticService.getThisMonthStatisticDataV2();
    _state.setThisMonthStatisticData(statisticData);
  }

  Future<void> getThisQuarterStatisticDataV2() async {
    final statisticData =
        await _statisticService.getThisQuarterStatisticDataV2();
    _state.setThisQuarterStatisticData(statisticData);
  }

  Future<void> getThisYearStatisticDataV2() async {
    final statisticData = await _statisticService.getThisYearStatisticDataV2();
    _state.setThisYearStatisticData(statisticData);
  }

  Future<StatisticData> getCustomRangeStatisticDataV2({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _statisticService.getCustomRangeStatisticDataV2(from, to);
  }

  static StatisticData calculateNewStatisticDataAfterCreateTransaction({
    required Transaction newTransaction,
    required StatisticData oldData,
  }) {
    final data = oldData.copyWith();

    switch (newTransaction.type) {
      case TransactionType.expense:
        data.totalExpense += newTransaction.amount;

        int categoryId =
            newTransaction.category!.parentId ?? newTransaction.category!.id;
        int categoryIndex = data.byCategoryExpense.indexWhere(
          (element) => element.category.id == categoryId,
        );
        if (categoryIndex != -1) {
          data.byCategoryExpense[categoryIndex].amount += newTransaction.amount;
          data.byCategoryExpense[categoryIndex].transactions.add(
            newTransaction,
          );
        } else {
          data.byCategoryExpense.add(
            ByCategoryData(
              category: Category.fromContext(categoryId),
              amount: newTransaction.amount,
              transactions: [newTransaction],
            ),
          );
        }

      case TransactionType.income:
        data.totalIncome += newTransaction.amount;

        int categoryId =
            newTransaction.category!.parentId ?? newTransaction.category!.id;
        int categoryIndex = data.byCategoryIncome.indexWhere(
          (element) => element.category.id == categoryId,
        );
        if (categoryIndex != -1) {
          data.byCategoryIncome[categoryIndex].amount += newTransaction.amount;
          data.byCategoryIncome[categoryIndex].transactions.add(newTransaction);
        } else {
          data.byCategoryIncome.add(
            ByCategoryData(
              category: Category.fromContext(categoryId),
              amount: newTransaction.amount,
              transactions: [newTransaction],
            ),
          );
        }
      case TransactionType.modifyBalance:
        if (newTransaction.amount > 0) {
          //handle as income
          data.totalIncome += newTransaction.amount;

          int categoryId =
              newTransaction.category!.parentId ?? newTransaction.category!.id;
          int categoryIndex = data.byCategoryIncome.indexWhere(
            (element) => element.category.id == categoryId,
          );
          if (categoryIndex != -1) {
            data.byCategoryIncome[categoryIndex].amount +=
                newTransaction.amount;
            data.byCategoryIncome[categoryIndex].transactions.add(
              newTransaction,
            );
          } else {
            data.byCategoryIncome.add(
              ByCategoryData(
                category: Category.fromContext(categoryId),
                amount: newTransaction.amount,
                transactions: [newTransaction],
              ),
            );
          }
        } else {
          //handle as expense
          data.totalExpense += newTransaction.amount.abs();

          int categoryId =
              newTransaction.category!.parentId ?? newTransaction.category!.id;
          int categoryIndex = data.byCategoryExpense.indexWhere(
            (element) => element.category.id == categoryId,
          );
          if (categoryIndex != -1) {
            data.byCategoryExpense[categoryIndex].amount +=
                newTransaction.amount.abs();
            data.byCategoryExpense[categoryIndex].transactions.add(
              newTransaction,
            );
          } else {
            data.byCategoryExpense.add(
              ByCategoryData(
                category: Category.fromContext(categoryId),
                amount: newTransaction.amount.abs(),
                transactions: [newTransaction],
              ),
            );
          }
        }
      default:
    }

    return data;
  }

  static StatisticData calculateNewStatisticDataAfterRemoveTransaction({
    required Transaction removedTransaction,
    required StatisticData oldData,
  }) {
    final data = oldData.copyWith();

    switch (removedTransaction.type) {
      case TransactionType.expense:
        data.totalExpense -= removedTransaction.amount;

        int categoryId =
            removedTransaction.category!.parentId ??
            removedTransaction.category!.id;
        int categoryIndex = data.byCategoryExpense.indexWhere(
          (element) => element.category.id == categoryId,
        );
        if (categoryIndex != -1) {
          if (data.byCategoryExpense[categoryIndex].transactions.length > 1) {
            data.byCategoryExpense[categoryIndex].amount -=
                removedTransaction.amount;
            data.byCategoryExpense[categoryIndex].transactions.removeWhere(
              (element) => element.id == removedTransaction.id,
            );
          } else {
            data.byCategoryExpense.removeAt(categoryIndex);
          }
        }
      case TransactionType.income:
        data.totalIncome -= removedTransaction.amount;

        int categoryId =
            removedTransaction.category!.parentId ??
            removedTransaction.category!.id;
        int categoryIndex = data.byCategoryIncome.indexWhere(
          (element) => element.category.id == categoryId,
        );
        if (categoryIndex != -1) {
          if (data.byCategoryIncome[categoryIndex].transactions.length > 1) {
            data.byCategoryIncome[categoryIndex].amount -=
                removedTransaction.amount;
            data.byCategoryIncome[categoryIndex].transactions.removeWhere(
              (element) => element.id == removedTransaction.id,
            );
          } else {
            data.byCategoryIncome.removeAt(categoryIndex);
          }
        }
      case TransactionType.modifyBalance:
        if (removedTransaction.amount > 0) {
          //handle as income
          data.totalIncome -= removedTransaction.amount;

          int categoryId =
              removedTransaction.category!.parentId ??
              removedTransaction.category!.id;
          int categoryIndex = data.byCategoryIncome.indexWhere(
            (element) => element.category.id == categoryId,
          );
          if (categoryIndex != -1) {
            if (data.byCategoryIncome[categoryIndex].transactions.length > 1) {
              data.byCategoryIncome[categoryIndex].amount -=
                  removedTransaction.amount;
              data.byCategoryIncome[categoryIndex].transactions.removeWhere(
                (element) => element.id == removedTransaction.id,
              );
            } else {
              data.byCategoryIncome.removeAt(categoryIndex);
            }
          }
        } else {
          //handle as expense
          data.totalExpense -= removedTransaction.amount.abs();

          int categoryId =
              removedTransaction.category!.parentId ??
              removedTransaction.category!.id;
          int categoryIndex = data.byCategoryExpense.indexWhere(
            (element) => element.category.id == categoryId,
          );
          if (categoryIndex != -1) {
            if (data.byCategoryExpense[categoryIndex].transactions.length > 1) {
              data.byCategoryExpense[categoryIndex].amount -=
                  removedTransaction.amount.abs();
              data.byCategoryExpense[categoryIndex].transactions.removeWhere(
                (element) => element.id == removedTransaction.id,
              );
            } else {
              data.byCategoryExpense.removeAt(categoryIndex);
            }
          }
        }
      default:
    }

    return data;
  }
}

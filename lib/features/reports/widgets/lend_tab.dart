import 'package:flutter/material.dart';
import 'package:intel_money/core/models/related_user.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/state/related_user_state.dart';
import '../../../core/state/transaction_state.dart';
import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../../shared/helper/app_time.dart';
import '../../transaction/screens/select_data_source_type_screen.dart';
import '../../transaction/widgets/select_data_source_type_button.dart';

class LendTab extends StatefulWidget {
  const LendTab({super.key});

  @override
  State<LendTab> createState() => _LendTabState();
}

class _LendTabState extends State<LendTab> {
  TransactionDataSourceType type = TransactionDataSourceType.thisMonth;
  Map<String, DateTime>? customTimeRange;

  Map<RelatedUser, LendData> _totalDebtMap = {};
  double _totalLendAmount = 0;
  double _totalCollectedAmount = 0;

  Future<void> _prepareData(
    List<Transaction> allTransactions,
    List<RelatedUser> relatedUsers,
  ) async {
    List<Transaction> sourceTransactions = [];
    if (type == TransactionDataSourceType.allTime) {
      sourceTransactions = allTransactions;
    } else {
      Map<String, DateTime> timeRange = type.timeRange;

      // If the type is custom, use the custom time range
      if (type == TransactionDataSourceType.customDay ||
          type == TransactionDataSourceType.customMonth ||
          type == TransactionDataSourceType.customFromTo) {
        timeRange = customTimeRange!;
      }

      List<Transaction> result = [];
      for (var transaction in allTransactions) {
        // Include transactions on or after 'from' date and on or before 'to' date
        if ((transaction.transactionDate.isAtSameMomentAs(timeRange['from']!) ||
                transaction.transactionDate.isAfter(timeRange['from']!)) &&
            (transaction.transactionDate.isAtSameMomentAs(timeRange['to']!) ||
                transaction.transactionDate.isBefore(timeRange['to']!))) {
          result.add(transaction);
        }
      }

      sourceTransactions = result;
    }

    Map<RelatedUser, LendData> totalDebtMap = {};
    double totalCollectedAmount = 0;
    double totalLendAmount = 0;
    for (var transaction in sourceTransactions) {
      if (transaction.type != TransactionType.lend) continue;

      if (!totalDebtMap.containsKey(
        (transaction as LendTransaction).borrower,
      )) {
        totalDebtMap[transaction.borrower] = LendData(
          total: 0,
          collected: 0,
          transactions: [],
        );
      }
      totalDebtMap[transaction.borrower]!.total += transaction.amount;
      totalDebtMap[transaction.borrower]!.transactions.add(transaction);
      totalLendAmount += transaction.amount;
    }

    _totalDebtMap = totalDebtMap;
    _totalLendAmount = totalLendAmount;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionState, RelatedUserState>(
      builder: (context, transactionState, relatedUserState, _) {
        final allTransactions = transactionState.transactions;
        final allRelatedUsers = relatedUserState.relatedUsers;

        return FutureBuilder(
          future: _prepareData(allTransactions, allRelatedUsers),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            String buttonDisplayText = type.name;
            if (type == TransactionDataSourceType.customDay) {
              buttonDisplayText = AppTime.format(
                time: customTimeRange!['from']!,
              );
            } else if (type == TransactionDataSourceType.customMonth) {
              buttonDisplayText = AppTime.format(
                time: customTimeRange!['from']!,
                pattern: "MM/YYYY",
              );
            } else if (type == TransactionDataSourceType.customFromTo) {
              buttonDisplayText =
                  "${AppTime.format(time: customTimeRange!['from']!)} - ${AppTime.format(time: customTimeRange!['to']!)}";
            }

            return Column(
              children: [
                SelectDataSourceTypeButton(
                  displayText: buttonDisplayText,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => SelectDataSourceTypeScreen(
                              type: type,
                              customTimeRange: customTimeRange,
                              onSelect: (
                                selectedType, {
                                Map<String, DateTime>? timeRange,
                              }) {
                                if (timeRange != null) {
                                  customTimeRange = timeRange;
                                }

                                setState(() {
                                  type = selectedType;
                                });
                              },
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tổng tiền đã cho vay",
                            style: TextStyle(fontSize: 16),
                          ),
                          CurrencyDoubleText(
                            value: _totalLendAmount,
                            fontSize: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tổng tiền đã thu",
                            style: TextStyle(fontSize: 16),
                          ),
                          CurrencyDoubleText(
                            value: _totalCollectedAmount,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ..._totalDebtMap.entries.map((item) {
                            final user = item.key;
                            final lendData = item.value;

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        radius: 20,
                                        child: Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          CurrencyDoubleText(
                                            value: lendData.total,
                                            fontSize: 16,
                                          ),
                                          CurrencyDoubleText(
                                            value: lendData.collected,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class LendData {
  double total;
  double collected;
  List<Transaction> transactions;

  LendData({
    required this.total,
    required this.collected,
    required this.transactions,
  });
}

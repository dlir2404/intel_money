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

class BorrowTab extends StatefulWidget {
  const BorrowTab({super.key});

  @override
  State<BorrowTab> createState() => _BorrowTabState();
}

class _BorrowTabState extends State<BorrowTab> {
  TransactionDataSourceType type = TransactionDataSourceType.allTime;
  Map<String, DateTime>? customTimeRange;

  Map<RelatedUser, BorrowData> _totalDebtMap = {};
  double _totalBorowAmount = 0;
  double _totalPaidAmount = 0;

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

    Map<RelatedUser, BorrowData> totalDebtMap = {};
    double totalCollectedAmount = 0;
    double totalLendAmount = 0;
    for (var transaction in sourceTransactions) {
      if (transaction.type != TransactionType.borrow) continue;

      if (!totalDebtMap.containsKey(
        (transaction as BorrowTransaction).lender,
      )) {
        totalDebtMap[transaction.lender] = BorrowData(
          total: 0,
          paid: 0,
          transactions: [],
        );
      }
      totalDebtMap[transaction.lender]!.total += transaction.amount;
      totalDebtMap[transaction.lender]!.transactions.add(transaction);
      totalLendAmount += transaction.amount;
    }

    _totalDebtMap = totalDebtMap;
    _totalBorowAmount = totalLendAmount;
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
                      type == TransactionDataSourceType.allTime
                          ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Phải trả",
                                style: TextStyle(fontSize: 16),
                              ),
                              CurrencyDoubleText(
                                value: _totalBorowAmount - _totalPaidAmount,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _totalPaidAmount / _totalBorowAmount,
                            backgroundColor: Colors.grey[300],
                            color: Colors.red, // Progress color
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                          : const SizedBox.shrink(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tổng tiền đã vay",
                            style: TextStyle(fontSize: 16),
                          ),
                          CurrencyDoubleText(
                            value: _totalBorowAmount,
                            fontSize: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tổng tiền đã trả",
                            style: TextStyle(fontSize: 16),
                          ),
                          CurrencyDoubleText(
                            value: _totalPaidAmount,
                            color: Colors.red,
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
                                            value: lendData.paid,
                                            color: Colors.red,
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

class BorrowData {
  double total;
  double paid;
  List<Transaction> transactions;

  BorrowData({
    required this.total,
    required this.paid,
    required this.transactions,
  });
}

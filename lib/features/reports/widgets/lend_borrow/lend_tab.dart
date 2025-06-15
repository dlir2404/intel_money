import 'package:flutter/material.dart';
import 'package:intel_money/core/models/related_user.dart';
import 'package:intel_money/features/reports/widgets/lend_borrow/borrower.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/transaction.dart';
import '../../../../core/state/related_user_state.dart';
import '../../../../core/state/transaction_state.dart';
import '../../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../../shared/const/enum/transaction_type.dart';
import '../../../../shared/helper/app_time.dart';
import '../../../transaction/screens/select_data_source_type_screen.dart';
import '../../../transaction/widgets/select_data_source_type_button.dart';
import '../../screens/lend_detail_screen.dart';

class LendTab extends StatefulWidget {
  const LendTab({super.key});

  @override
  State<LendTab> createState() => _LendTabState();
}

class _LendTabState extends State<LendTab> {
  TransactionDataSourceType type = TransactionDataSourceType.allTime;
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
      if (transaction.type == TransactionType.lend) {
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
      } else if (transaction.type == TransactionType.collectingDebt) {
        if (!totalDebtMap.containsKey(
          (transaction as CollectingDebtTransaction).borrower,
        )) {
          totalDebtMap[transaction.borrower] = LendData(
            total: 0,
            collected: 0,
            transactions: [],
          );
        }

        totalDebtMap[transaction.borrower]!.collected += transaction.amount;
        totalDebtMap[transaction.borrower]!.transactions.add(transaction);
        totalCollectedAmount += transaction.amount;
      }
    }

    _totalDebtMap = totalDebtMap;
    _totalLendAmount = totalLendAmount;
    _totalCollectedAmount = totalCollectedAmount;
    setState(() {});
  }

  Widget _buildAllTimeLendData() {
    final followingDebts = [];
    final completedDebts = [];

    for (var item in _totalDebtMap.entries) {
      final lendData = item.value;

      if (lendData.total > lendData.collected) {
        followingDebts.add(item);
      } else {
        completedDebts.add(item);
      }
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cần thu", style: TextStyle(fontSize: 16)),
                      CurrencyDoubleText(
                        value: _totalLendAmount - _totalCollectedAmount,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _totalLendAmount == 0 ? 0 : _totalCollectedAmount / _totalLendAmount,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green, // Progress color
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã cho vay", style: TextStyle(fontSize: 16)),
                  CurrencyDoubleText(value: _totalLendAmount, fontSize: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã thu", style: TextStyle(fontSize: 16)),
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
                  ExpansionTile(
                    initiallyExpanded: true,
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    backgroundColor: Colors.white,
                    title: Text(
                      "Đang theo dõi (${followingDebts.length})",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    children: [
                      if (followingDebts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Không có khoản vay nào đang theo dõi."),
                        ),
                      ...followingDebts.map((item) {
                        final user = item.key;
                        final lendData = item.value;

                        return Borrower(
                          borrower: user,
                          lendData: lendData,
                          type: type,
                        );
                      }),
                    ],
                  ),
                  ExpansionTile(
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    backgroundColor: Colors.white,
                    title: Text(
                      "Đã hoàn thành (${completedDebts.length})",
                      style: TextStyle(color: Colors.green),
                    ),
                    children: [
                      if (completedDebts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Không có khoản vay nào đã hoàn thành."),
                        ),
                      ...completedDebts.map((item) {
                        final user = item.key;
                        final lendData = item.value;

                        return Borrower(
                          borrower: user,
                          lendData: lendData,
                          type: type,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLendDataForSelectedType() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã cho vay", style: TextStyle(fontSize: 16)),
                  CurrencyDoubleText(value: _totalLendAmount, fontSize: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã thu", style: TextStyle(fontSize: 16)),
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

                    return Borrower(
                      borrower: user,
                      lendData: lendData,
                      type: type,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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

                Expanded(
                  child:
                      type == TransactionDataSourceType.allTime
                          ? _buildAllTimeLendData()
                          : _buildLendDataForSelectedType(),
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

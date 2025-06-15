import 'package:flutter/material.dart';
import 'package:intel_money/core/models/related_user.dart';
import 'package:intel_money/features/reports/widgets/lend_borrow/lender.dart';
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

class BorrowTab extends StatefulWidget {
  const BorrowTab({super.key});

  @override
  State<BorrowTab> createState() => _BorrowTabState();
}

class _BorrowTabState extends State<BorrowTab> {
  TransactionDataSourceType type = TransactionDataSourceType.allTime;
  Map<String, DateTime>? customTimeRange;

  Map<RelatedUser, BorrowData> _totalDebtMap = {};
  double _totalBorrowAmount = 0;
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
      if (transaction.type == TransactionType.borrow) {
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
      } else if (transaction.type == TransactionType.repayment) {
        if (!totalDebtMap.containsKey(
          (transaction as RepaymentTransaction).lender,
        )) {
          totalDebtMap[transaction.lender] = BorrowData(
            total: 0,
            paid: 0,
            transactions: [],
          );
        }
        totalDebtMap[transaction.lender]!.paid += transaction.amount;
        totalDebtMap[transaction.lender]!.transactions.add(transaction);
        totalCollectedAmount += transaction.amount;
      }
    }

    _totalDebtMap = totalDebtMap;
    _totalBorrowAmount = totalLendAmount;
    _totalPaidAmount = totalCollectedAmount;
    setState(() {});
  }

  Widget _buildAllTimeBorrowData() {
    final followingBorrows = [];
    final completedBorrows = [];

    for (var entry in _totalDebtMap.entries) {
      final lendData = entry.value;

      if (lendData.total > lendData.paid) {
        followingBorrows.add(entry);
      } else {
        completedBorrows.add(entry);
      }
    }

    return Column(
      children: [
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
                          Text("Phải trả", style: TextStyle(fontSize: 16)),
                          CurrencyDoubleText(
                            value: _totalBorrowAmount - _totalPaidAmount,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalPaidAmount / _totalBorrowAmount,
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
                  Text("Tổng tiền đã vay", style: TextStyle(fontSize: 16)),
                  CurrencyDoubleText(value: _totalBorrowAmount, fontSize: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã trả", style: TextStyle(fontSize: 16)),
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
                      "Đang theo dõi (${followingBorrows.length})",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    children: [
                      if (followingBorrows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Không có khoản nợ nào đang theo dõi."),
                        ),
                      ...followingBorrows.map((item) {
                        final user = item.key;
                        final borrowData = item.value;

                        return Lender(
                          lender: user,
                          borrowData: borrowData,
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
                      "Đã hoàn thành (${completedBorrows.length})",
                      style: TextStyle(color: Colors.green),
                    ),
                    children: [
                      if (completedBorrows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Không có khoản nợ nào đã hoàn thành."),
                        ),
                      ...completedBorrows.map((item) {
                        final user = item.key;
                        final borrowData = item.value;

                        return Lender(
                          lender: user,
                          borrowData: borrowData,
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

  Widget _buildBorrowDataForType() {
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
                  CurrencyDoubleText(value: _totalBorrowAmount, fontSize: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền đã thu", style: TextStyle(fontSize: 16)),
                  CurrencyDoubleText(
                    value: _totalBorrowAmount,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._totalDebtMap.entries.map((item) {
                  final user = item.key;
                  final borrowData = item.value;

                  return Lender(
                    lender: user,
                    borrowData: borrowData,
                    type: type,
                  );
                }),
              ],
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
                          ? _buildAllTimeBorrowData()
                          : _buildBorrowDataForType(),
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

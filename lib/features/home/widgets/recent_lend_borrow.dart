import 'package:flutter/material.dart';
import 'package:intel_money/core/state/related_user_state.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:provider/provider.dart';

import '../../../core/models/related_user.dart';
import '../../../shared/component/typos/currency_double_text.dart';

class RecentLendBorrow extends StatefulWidget {
  const RecentLendBorrow({super.key});

  @override
  State<RecentLendBorrow> createState() => _RecentLendBorrowState();
}

class _RecentLendBorrowState extends State<RecentLendBorrow> {
  Widget _buildLendItem(RelatedUser user) {
    final amount = user.totalDebt - user.totalCollected;

    if (amount <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TransactionType.lend.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                TransactionType.lend.icon,
                color: TransactionType.lend.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Loan", style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  "Lent money to ${user.name}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  "Collected date: Uncategorized",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Expanded(child: const SizedBox()),

            CurrencyDoubleText(value: amount, color: Colors.red, fontSize: 14),
          ],
        ),
        Divider(color: Colors.grey[200], thickness: 0.5),
      ],
    );
  }

  Widget _buildBorrowItem(RelatedUser user) {
    final amount = user.totalLoan - user.totalPaid;

    if (amount <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TransactionType.borrow.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                TransactionType.borrow.icon,
                color: TransactionType.borrow.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Loan", style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  "Borrow money from ${user.name}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  "Collected date: Uncategorized",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Expanded(child: const SizedBox()),

            CurrencyDoubleText(value: amount, color: Colors.green, fontSize: 14),
          ],
        ),
        Divider(color: Colors.grey[200], thickness: 0.5),
      ],
    );
  }

  Widget _buildItem(RelatedUser user) {
    return Column(
      children: [
        _buildLendItem(user),
        _buildBorrowItem(user),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RelatedUserState>(
      builder: (context, state, _) {
        final relatedUsers = state.relatedUsers;

        final relatedUsersHaveLendBorrow =
            relatedUsers
                .where(
                  (user) =>
                      user.totalLoan - user.totalPaid > 0 ||
                      user.totalDebt - user.totalCollected > 0,
                )
                .toList();

        if (relatedUsersHaveLendBorrow.isEmpty) {
          return SizedBox(
            height: 80,
            child: Center(
              child: Text("No recent lend/borrow transactions found.", style: TextStyle(color: Colors.grey),),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              ...relatedUsersHaveLendBorrow.map((user) {
                return _buildItem(user);
              }),

              InkWell(
                onTap: () {
                  // Navigate to lend / borrow screen
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "More",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';

import '../../../../core/models/related_user.dart';
import '../../../../shared/component/typos/currency_double_text.dart';
import '../../screens/lend_detail_screen.dart';
import 'lend_tab.dart';

class Borrower extends StatelessWidget {
  final RelatedUser borrower;
  final LendData lendData;
  final TransactionDataSourceType type;
  const Borrower({super.key, required this.borrower, required this.lendData, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => LendDetailScreen(
              borrower: borrower,
              data: lendData,
              type: type,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor:
                  Theme.of(context).primaryColor,
                  radius: 20,
                  child: Text(
                    borrower.name.isNotEmpty
                        ? borrower.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  borrower.name,
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
      ),
    );
  }
}

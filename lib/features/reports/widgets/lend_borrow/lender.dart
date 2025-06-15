import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/lend_borrow/borrow_tab.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';

import '../../../../core/models/related_user.dart';
import '../../../../shared/component/typos/currency_double_text.dart';
import '../../screens/borrow_detail_screen.dart';

class Lender extends StatelessWidget {
  final RelatedUser lender;
  final BorrowData borrowData;
  final TransactionDataSourceType type;
  const Lender({super.key, required this.lender, required this.borrowData, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => BorrowDetailScreen(
              lender: lender,
              data: borrowData,
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
                    lender.name.isNotEmpty
                        ? lender.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  lender.name,
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
                      value: borrowData.total,
                      fontSize: 16,
                    ),
                    CurrencyDoubleText(
                      value: borrowData.paid,
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

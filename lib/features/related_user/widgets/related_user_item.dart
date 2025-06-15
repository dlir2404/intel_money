import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/related_user.dart';

class RelatedUserItem extends StatelessWidget {
  final RelatedUser relatedUser;

  const RelatedUserItem({super.key, required this.relatedUser});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Handle tap action
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 24,
                    child: Text(
                      relatedUser.name.isNotEmpty
                          ? relatedUser.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      relatedUser.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      if (relatedUser.totalDebt - relatedUser.totalCollected > 0)
                        Row(
                          children: [
                            Text("Cần thu: "),
                            CurrencyDoubleText(
                              value: relatedUser.totalDebt - relatedUser.totalCollected,
                              color: Colors.green,
                              fontSize: 16,
                            )
                          ],
                        ),
                      if (relatedUser.totalLoan - relatedUser.totalPaid > 0)
                        Row(
                          children: [
                            Text("Cần trả: "),
                            CurrencyDoubleText(
                              value: relatedUser.totalLoan - relatedUser.totalPaid,
                              color: Colors.red,
                              fontSize: 16,
                            )
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

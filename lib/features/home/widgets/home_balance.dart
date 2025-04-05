import 'package:flutter/material.dart';

class HomeBalance extends StatefulWidget {
  final double? totalBalance;
  const HomeBalance({super.key, required this.totalBalance});

  @override
  State<HomeBalance> createState() => _HomeBalanceState();
}

class _HomeBalanceState extends State<HomeBalance> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _showBalance ? "\$${widget.totalBalance}" : '******',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(16),
              icon: Icon(
                _showBalance ? Icons.visibility : Icons.visibility_off,
                size: 30,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _showBalance = !_showBalance;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../shared/component/typos/currency_double_text.dart';

class FinancialStatementScreen extends StatefulWidget {
  const FinancialStatementScreen({super.key});

  @override
  State<FinancialStatementScreen> createState() =>
      _FinancialStatementScreenState();
}

class _FinancialStatementScreenState extends State<FinancialStatementScreen> {
  Widget _buildAssets() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.user;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.2, color: Color(0xFFBDBDBD)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Assets", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Column(
                      children: [
                        Text(
                          "(1)",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    Expanded(child: const SizedBox(height: 1)),

                    CurrencyDoubleText(
                      value: (user?.totalBalance ?? 0) + (user?.totalLoan ?? 0),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              Consumer<WalletState>(
                builder: (context, state, _) {
                  final wallets = state.wallets;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        wallets.map((wallet) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.2,
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: wallet.icon.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    wallet.icon.icon,
                                    color: wallet.icon.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(wallet.name),
                                Expanded(child: const SizedBox(height: 1)),
                                const SizedBox(width: 16),
                                CurrencyDoubleText(
                                  value: wallet.balance,
                                  color:
                                      wallet.balance >= 0
                                          ? Colors.green[600]
                                          : Colors.red[600],
                                  fontSize: 16,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.2, color: Color(0xFFBDBDBD)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        MdiIcons.cashMinus,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text("Loan"),
                    Expanded(child: const SizedBox(height: 1)),
                    const SizedBox(width: 16),
                    CurrencyDoubleText(value: user?.totalLoan ?? 0, fontSize: 16),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildLiabilities() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.user;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.2, color: Color(0xFFBDBDBD)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Liabilities", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Column(
                      children: [
                        Text(
                          "(2)",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    Expanded(child: const SizedBox(height: 1)),

                    CurrencyDoubleText(
                      value: user?.totalDebt ?? 0,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.2, color: Color(0xFFBDBDBD)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        MdiIcons.cashPlus,
                        color: Colors.greenAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text("Money Borrowed"),
                    Expanded(child: const SizedBox(height: 1)),
                    const SizedBox(width: 16),
                    CurrencyDoubleText(value: user?.totalDebt ?? 0, fontSize: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Statement'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Consumer<AppState>(
              builder: (context, state, _) {
                final user = state.user;

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Financial statement",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          Text(
                            "(1) - (2)",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                      Expanded(child: const SizedBox(height: 1)),

                      CurrencyDoubleText(
                        value: user?.totalBalance ?? 0,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 30),

            _buildAssets(),
            const SizedBox(height: 30),

            _buildLiabilities(),
          ],
        ),
      ),
    );
  }
}

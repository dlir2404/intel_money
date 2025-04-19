import 'package:flutter/material.dart';

import '../../../core/models/app_icon.dart';

class WalletIcon {
  static List<AppIcon> icons = [
    AppIcon(name: 'wallet', icon: Icons.account_balance_wallet, label: 'Wallet', color: Colors.blue),
    AppIcon(name: 'savings', icon: Icons.savings, label: 'Savings', color: Colors.amber),
    AppIcon(name: 'credit_card', icon: Icons.credit_card, label: 'Credit Card', color: Colors.purple),
    AppIcon(name: 'exchange', icon: Icons.currency_exchange, label: 'Exchange', color: Colors.green),
    AppIcon(name: 'shopping', icon: Icons.shopping_bag, label: 'Shopping', color: Colors.orange),
    AppIcon(name: 'bank', icon: Icons.account_balance, label: 'Bank', color: Colors.blueGrey),
    AppIcon(name: 'cash', icon: Icons.money, label: 'Cash', color: Colors.greenAccent),
    AppIcon(name: 'money', icon: Icons.attach_money, label: 'Money', color: Colors.teal),
  ];

  static AppIcon getIcon(String name) {
    return icons.firstWhere((icon) => icon.name == name, orElse: () => icons[0]);
  }

  static AppIcon defaultIcon() {
    return icons[0];
  }
}
import 'package:flutter/material.dart';

class WalletController {
  static List<Map<String, dynamic>> iconOptions = [
    {'name': 'wallet', 'icon': Icons.account_balance_wallet, 'label': 'Wallet'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Savings'},
    {'name': 'card', 'icon': Icons.credit_card, 'label': 'Card'},
    {'name': 'exchange', 'icon': Icons.currency_exchange, 'label': 'Exchange'},
    {'name': 'shopping', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'money', 'icon': Icons.attach_money, 'label': 'Money'},
  ];

  static IconData getWalletIcon(String iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'card':
        return Icons.credit_card;
      case 'exchange':
        return Icons.currency_exchange;
      case 'shopping':
        return Icons.shopping_bag;
      case 'money':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  static Color getIconColor(String iconName) {
    switch (iconName) {
      case 'wallet':
        return Colors.blue;
      case 'savings':
        return Colors.green;
      case 'card':
        return Colors.orange;
      case 'exchange':
        return Colors.purple;
      case 'shopping':
        return Colors.red;
      case 'money':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
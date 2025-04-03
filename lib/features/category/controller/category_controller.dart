import 'package:flutter/material.dart';

class CategoryController {
  static IconData getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'bills':
        return Icons.receipt;
      case 'salary':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'card':
        return Icons.credit_card;
      case 'exchange':
        return Icons.currency_exchange;
      case 'money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String iconName) {
    // Using the icon name to determine color for visual consistency
    switch (iconName) {
      case 'food':
        return const Color(0xFFFF5252);
      case 'shopping':
        return const Color(0xFFFF9800);
      case 'transport':
        return const Color(0xFF42A5F5);
      case 'entertainment':
        return const Color(0xFF7C4DFF);
      case 'health':
        return const Color(0xFF26A69A);
      case 'education':
        return const Color(0xFF5C6BC0);
      case 'bills':
        return const Color(0xFFEC407A);
      case 'salary':
        return const Color(0xFF4CAF50);
      case 'investment':
        return const Color(0xFF26A69A);
      case 'wallet':
        return const Color(0xFF8D6E63);
      case 'savings':
        return const Color(0xFF66BB6A);
      case 'card':
        return const Color(0xFF42A5F5);
      case 'exchange':
        return const Color(0xFFAB47BC);
      case 'money':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF757575);
    }
  }
}

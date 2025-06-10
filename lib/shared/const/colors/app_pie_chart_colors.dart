import 'package:flutter/material.dart';

class AppPieChartColor {
  static List<Color> defaultExpenseColorList = [
    Color(0xFFff6b6b),
    Color(0xFFff9f43),
    Color(0xFFf368e0),
    Color(0xFFff4757),
    Color(0xFF747d8c),
    Color(0xFFff7f50),
    Color(0xFFec407a),
    Color(0xFFe84118),
    Color(0xFF6c5ce7),
    Color(0xFF2f3542),
  ];

  static List<Color> defaultIncomeColorList = [
    Color(0xFF00b894),
    Color(0xFF00cec9),
    Color(0xFF0984e3),
    Color(0xFF6c5ce7),
    Color(0xFFdfe6e9),
    Color(0xFF00a8ff),
    Color(0xFF74b9ff),
    Color(0xFF81ecec),
  ];

  static Color getExpenseColor(int index) {
    if (index > (defaultExpenseColorList.length - 1)) {
      final newIndex = index % (defaultExpenseColorList.length - 1);
      return defaultExpenseColorList.elementAt(newIndex);
    }
    return defaultExpenseColorList.elementAt(index);
  }

  static Color getIncomeColor(int index) {
    if (index > (defaultIncomeColorList.length - 1)) {
      final newIndex = index % (defaultIncomeColorList.length - 1);
      return defaultIncomeColorList.elementAt(newIndex);
    }
    return defaultIncomeColorList.elementAt(index);
  }
}

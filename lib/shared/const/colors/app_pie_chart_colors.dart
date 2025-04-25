import 'package:flutter/material.dart';

class AppPieChartColor {
  static List<Color> defaultColorList = [
    Color(0xFFff7675),
    Color(0xFF74b9ff),
    Color(0xFF55efc4),
    Color(0xFFffeaa7),
    Color(0xFFa29bfe),
    Color(0xFFfd79a8),
    Color(0xFFe17055),
    Color(0xFF00b894),
  ];

  static Color getColor(int index) {
    if (index > (defaultColorList.length - 1)) {
      final newIndex = index % (defaultColorList.length - 1);
      return defaultColorList.elementAt(newIndex);
    }
    return defaultColorList.elementAt(index);
  }
}

class AppTime {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    // Get start of current week (Monday)
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    // Get end of current week (Sunday)
    final endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Include start and end dates in the comparison
    return (date.isAtSameMomentAs(startOfWeek) || date.isAfter(startOfWeek)) &&
        (date.isAtSameMomentAs(endOfWeek) || date.isBefore(endOfWeek));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisQuarter(DateTime date) {
    final now = DateTime.now();
    final currentQuarter = (now.month - 1) ~/ 3 + 1;
    final dateQuarter = (date.month - 1) ~/ 3 + 1;
    return date.year == now.year && dateQuarter == currentQuarter;
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  static int getMonth(DateTime date) {
    return date.month;
  }

  static getQuarter(DateTime date) {
    return (date.month - 1) ~/ 3 + 1;
  }
}
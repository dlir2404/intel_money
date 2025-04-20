class AppDate {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day - 1;
  }

  static String monthYearFormat(DateTime date) {
    return "${date.month}/${date.year}";
  }
}
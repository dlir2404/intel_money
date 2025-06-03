import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intel_money/core/state/app_state.dart';

class AppTime {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    // Get start of current week (Monday)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    // Get end of current week (Sunday)
    final endOfWeek = startOfWeek.add(
      Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

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

  static String format({
    required DateTime time,
    String pattern = "dd/MM/YYYY",
  }) {
    String result = pattern;

    // Year formatting
    result = result.replaceAll("YYYY", time.year.toString());
    result = result.replaceAll("YY", time.year.toString().substring(2));

    // Month formatting
    result = result.replaceAll("MM", time.month.toString().padLeft(2, '0'));
    result = result.replaceAll("M", time.month.toString());

    // Day formatting
    result = result.replaceAll("dd", time.day.toString().padLeft(2, '0'));
    result = result.replaceAll("d", time.day.toString());

    // Hour formatting
    result = result.replaceAll("HH", time.hour.toString().padLeft(2, '0'));
    result = result.replaceAll("H", time.hour.toString());

    // Minute formatting
    result = result.replaceAll("mm", time.minute.toString().padLeft(2, '0'));
    result = result.replaceAll("m", time.minute.toString());

    // Second formatting
    result = result.replaceAll("ss", time.second.toString().padLeft(2, '0'));
    result = result.replaceAll("s", time.second.toString());

    return result;
  }

  static DateTime startOfMonth({DateTime? date}) {
    final dateToUse = date ?? startOfToday();
    return DateTime(dateToUse.year, dateToUse.month, 1);
  }

  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 0, 0, 0);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  static DateTime startOfThisWeek() {
    final now = DateTime.now();
    // Get start of current week (Monday)
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
  }

  static DateTime endOfThisWeek() {
    final now = DateTime.now();
    // Get start of current week (Monday)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    // Get end of current week (Sunday)
    return startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  static DateTime startOfThisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime endOfThisMonth() {
    final now = DateTime.now();
    //day 0 is tricky it will represent the last day of now.month
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  static DateTime startOfLastMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  static DateTime endOfLastMonth() {
    final now = DateTime.now();
    //day 0 is tricky it will represent the last day of (now.month - 1)
    return DateTime(now.year, now.month, 0, 23, 59, 59);
  }

  static DateTime startOfYear({DateTime? date}) {
    final dateToUse = date ?? DateTime.now();
    return DateTime(dateToUse.year, 1, 1);
  }

  static DateTime endOfYear({DateTime? date}) {
    final dateToUse = date ?? DateTime.now();
    return DateTime(dateToUse.year, 12, 31, 23, 59, 59);
  }

  static DateTime endOfMonth({DateTime? date}) {
    final dateToUse = date ?? DateTime.now();
    //day 0 is tricky it will represent the last day of dateToUse.month
    return DateTime(dateToUse.year, dateToUse.month + 1, 0, 23, 59, 59);
  }

  static int getCurrentQuarter() {
    final now = DateTime.now();
    return (now.month - 1) ~/ 3 + 1; // 1 for Jan-Mar, 2 for Apr-Jun, etc.
  }

  /// isoString from API is in UTC already
  static DateTime parseFromApi(String isoString) {
    return DateTime.parse(isoString).toLocal();
  }

  /// convert DateTime to UTC ISO 8601 String format, must call this before send to API
  static String toUtcIso8601String(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  /// get user timezone
  static Future<String> getUserTimeZone() async {
    return await FlutterTimezone.getLocalTimezone();
  }

  static Future<List<String>> getAvailableTimezones() async {
    return await FlutterTimezone.getAvailableTimezones();
  }

  static void initialize() async {
    List<String> timezones = await getAvailableTimezones();
    AppState().setTimezones(timezones);

    String userTimezone = await getUserTimeZone();
    AppState().setUserTimezone(userTimezone);
  }
}

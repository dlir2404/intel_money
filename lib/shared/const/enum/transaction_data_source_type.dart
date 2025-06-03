import '../../helper/app_time.dart';

enum TransactionDataSourceType {
  yesterday,
  today,
  customDay,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  customMonth,
  quarter1,
  quarter2,
  quarter3,
  quarter4,
  thisYear,
  customFromTo,
  allTime,
}

extension TransactionDataSourceTypeExtension on TransactionDataSourceType {
  String get name {
    switch (this) {
      case TransactionDataSourceType.yesterday:
        return "Yesterday";
      case TransactionDataSourceType.today:
        return "Today";
      case TransactionDataSourceType.customDay:
        return "Custom day";
      case TransactionDataSourceType.thisWeek:
        return "This week";
      case TransactionDataSourceType.lastWeek:
        return "Last week";
      case TransactionDataSourceType.thisMonth:
        return "This month";
      case TransactionDataSourceType.lastMonth:
        return "Last month";
      case TransactionDataSourceType.customMonth:
        return "Custom month";
      case TransactionDataSourceType.quarter1:
        return "Quarter I";
      case TransactionDataSourceType.quarter2:
        return "Quarter II";
      case TransactionDataSourceType.quarter3:
        return "Quarter III";
      case TransactionDataSourceType.quarter4:
        return "Quarter IV";
      case TransactionDataSourceType.thisYear:
        return "This year";
      case TransactionDataSourceType.allTime:
        return "All time";
      case TransactionDataSourceType.customFromTo:
        return "Custom From To";
    }
  }

  String get keyStore {
    switch (this) {
      case TransactionDataSourceType.yesterday:
        return "yesterday";
      case TransactionDataSourceType.today:
        return "today";
      case TransactionDataSourceType.customDay:
        return "custom_day";
      case TransactionDataSourceType.thisWeek:
        return "this_week";
      case TransactionDataSourceType.lastWeek:
        return "last_week";
      case TransactionDataSourceType.thisMonth:
        return "this_month";
      case TransactionDataSourceType.lastMonth:
        return "last_month";
      case TransactionDataSourceType.customMonth:
        return "custom_month";
      case TransactionDataSourceType.quarter1:
        return "quarter_1";
      case TransactionDataSourceType.quarter2:
        return "quarter_2";
      case TransactionDataSourceType.quarter3:
        return "quarter_3";
      case TransactionDataSourceType.quarter4:
        return "quarter_4";
      case TransactionDataSourceType.thisYear:
        return "this_year";
      case TransactionDataSourceType.allTime:
        return "all_time";
      case TransactionDataSourceType.customFromTo:
        return "custom_from_to";
    }
  }

  Map<String, DateTime> get timeRange {
    final now = DateTime.now();
    int year = now.year;
    int startMonth;
    int endMonth;

    switch (this) {
      case TransactionDataSourceType.yesterday:
        return {
          'from': AppTime.startOfToday().subtract(Duration(days: 1)),
          'to': AppTime.endOfToday().subtract(Duration(days: 1)),
        };
      case TransactionDataSourceType.today:
        return {
          'from': AppTime.startOfToday(),
          'to': AppTime.endOfToday(),
        };
      case TransactionDataSourceType.customDay:
        return {
          'start': DateTime(2000, 1, 1), // Example start date
          'end': DateTime(2000, 1, 2), // Example end date
        };
      case TransactionDataSourceType.thisWeek:
        return {
          'from': AppTime.startOfThisWeek(),
          'to': AppTime.endOfThisWeek(),
        };
      case TransactionDataSourceType.lastWeek:
        return {
          'from': AppTime.startOfThisWeek().subtract(Duration(days: 7)),
          'to': AppTime.endOfThisWeek().subtract(Duration(days: 7)),
        };
      case TransactionDataSourceType.thisMonth:
        return {
          'from': AppTime.startOfThisMonth(),
          'to': AppTime.endOfThisMonth(),
        };
      case TransactionDataSourceType.lastMonth:
        return {
          'from': AppTime.startOfLastMonth(),
          'to': AppTime.endOfLastMonth(),
        };
      case TransactionDataSourceType.customMonth:
        return {
          'start': DateTime(2000, 1, 1), // Example start date
          'end': DateTime(2000, 1, 2), // Example end date
        };
      case TransactionDataSourceType.quarter1:
        startMonth = 1;
        endMonth = 3;
        break;
      case TransactionDataSourceType.quarter2:
        startMonth = 4;
        endMonth = 6;
        break;
      case TransactionDataSourceType.quarter3:
        startMonth = 7;
        endMonth = 9;
        break;
      case TransactionDataSourceType.quarter4:
        startMonth = 10;
        endMonth = 12;
        break;
      case TransactionDataSourceType.thisYear:
        return {
          'from': AppTime.startOfYear(),
          'to': AppTime.endOfYear(),
        };
      case TransactionDataSourceType.customFromTo:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransactionDataSourceType.allTime:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return {
      'from': DateTime(year, startMonth, 1),
      'to': DateTime(year, endMonth + 1, 0), // Last day of the quarter
    };
  }
}

import '../../../helper/app_time.dart';

enum Month {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december
}

extension MonthExtension on Month{
  int get value {
    switch (this) {
      case Month.january:
        return 1;
      case Month.february:
        return 2;
      case Month.march:
        return 3;
      case Month.april:
        return 4;
      case Month.may:
        return 5;
      case Month.june:
        return 6;
      case Month.july:
        return 7;
      case Month.august:
        return 8;
      case Month.september:
        return 9;
      case Month.october:
        return 10;
      case Month.november:
        return 11;
      case Month.december:
        return 12;
    }
  }

  String get name {
    switch (this) {
      case Month.january:
        return 'Tháng 1';
      case Month.february:
        return 'Tháng 2';
      case Month.march:
        return 'Tháng 3';
      case Month.april:
        return 'Tháng 4';
      case Month.may:
        return 'Tháng 5';
      case Month.june:
        return 'Tháng 6';
      case Month.july:
        return 'Tháng 4';
      case Month.august:
        return 'Tháng 8';
      case Month.september:
        return 'Tháng 9';
      case Month.october:
        return 'Tháng 10';
      case Month.november:
        return 'Tháng 11';
      case Month.december:
        return 'Tháng 12';
    }
  }

  String get shortName {
    switch (this) {
      case Month.january:
        return 'Jan';
      case Month.february:
        return 'Feb';
      case Month.march:
        return 'Mar';
      case Month.april:
        return 'Apr';
      case Month.may:
        return 'May';
      case Month.june:
        return 'Jun';
      case Month.july:
        return 'Jul';
      case Month.august:
        return 'Aug';
      case Month.september:
        return 'Sep';
      case Month.october:
        return 'Oct';
      case Month.november:
        return 'Nov';
      case Month.december:
        return 'Dec';
    }
  }
}

enum MonthRelative {
  thisMonth,
  lastMonth,
  other,
}

extension MonthRelativeExtension on MonthRelative {
  String get name {
    switch (this) {
      case MonthRelative.thisMonth:
        return 'This Month';
      case MonthRelative.lastMonth:
        return 'Last Month';
      case MonthRelative.other:
        return 'Other';
    }
  }

  Map<String, DateTime> get timeRange {
    switch (this) {
      case MonthRelative.thisMonth:
        return {
          'from': AppTime.startOfThisMonth(),
          'to': AppTime.endOfThisMonth(),
        };
      case MonthRelative.lastMonth:
        return {
          'from': AppTime.startOfLastMonth(),
          'to': AppTime.endOfLastMonth(),
        };
      case MonthRelative.other:
        return {
          'start': DateTime(2000, 1, 1), // Example start date
          'end': DateTime(2000, 1, 2), // Example end date
        };
    }
  }
}
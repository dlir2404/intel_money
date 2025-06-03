import '../../../helper/app_time.dart';

enum Day {
  today,
  yesterday,
  other,
}

extension DayExtension on Day {
  String get name {
    switch (this) {
      case Day.today:
        return 'Today';
      case Day.yesterday:
        return 'Yesterday';
      case Day.other:
        return 'Other';
    }
  }

  Map<String, DateTime> get timeRange {
    switch (this) {
      case Day.today:
        return {
          'from': AppTime.startOfToday(),
          'to': AppTime.endOfToday(),
        };
      case Day.yesterday:
        return {
          'from': AppTime.startOfToday().subtract(Duration(days: 1)),
          'to': AppTime.endOfToday().subtract(Duration(days: 1)),
        };
      case Day.other:
        return {
          'start': DateTime(2000, 1, 1), // Example start date
          'end': DateTime(2000, 1, 2), // Example end date
        };
    }
  }
}
import 'package:intel_money/shared/helper/app_time.dart';

enum Week {
  thisWeek,
  lastWeek,
}

extension WeekExtension on Week {
  String get name {
    switch (this) {
      case Week.thisWeek:
        return 'This Week';
      case Week.lastWeek:
        return 'Last Week';
    }
  }

  Map<String, DateTime> get timeRange {
    switch (this) {
      case Week.thisWeek:
        return {
          'from': AppTime.startOfThisWeek(),
          'to': AppTime.endOfThisWeek(),
        };
      case Week.lastWeek:
        return {
          'from': AppTime.startOfThisWeek().subtract(Duration(days: 7)),
          'to': AppTime.endOfThisWeek().subtract(Duration(days: 7)),
        };
    }
  }
}
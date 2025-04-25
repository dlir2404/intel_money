import '../../../core/models/statistic_data.dart';
import '../../../core/state/app_state.dart';

enum StatisticType { daily, weekly, monthly, quarterly, yearly }

extension StatisticTypeExtension on StatisticType {
  String get value {
    switch (this) {
      case StatisticType.daily:
        return 'DAILY';
      case StatisticType.weekly:
        return 'WEEKLY';
      case StatisticType.monthly:
        return 'MONTHLY';
      case StatisticType.quarterly:
        return 'QUARTERLY';
      case StatisticType.yearly:
        return 'YEARLY';
    }
  }

  String get name {
    switch (this) {
      case StatisticType.daily:
        return 'Daily';
      case StatisticType.weekly:
        return 'Weekly';
      case StatisticType.monthly:
        return 'Monthly';
      case StatisticType.quarterly:
        return 'Quarterly';
      case StatisticType.yearly:
        return 'Yearly';
    }
  }
}

enum StatisticThisTime { today, thisWeek, thisMonth, thisQuarter, thisYear }

extension StatisticThisTimeExtension on StatisticThisTime {
  String get value {
    switch (this) {
      case StatisticThisTime.today:
        return 'TODAY';
      case StatisticThisTime.thisWeek:
        return 'THIS_WEEK';
      case StatisticThisTime.thisMonth:
        return 'THIS_MONTH';
      case StatisticThisTime.thisQuarter:
        return 'THIS_QUARTER';
      case StatisticThisTime.thisYear:
        return 'THIS_YEAR';
    }
  }

  String get name {
    switch (this) {
      case StatisticThisTime.today:
        return 'Today';
      case StatisticThisTime.thisWeek:
        return 'This Week';
      case StatisticThisTime.thisMonth:
        return 'This Month';
      case StatisticThisTime.thisQuarter:
        return 'This Quarter';
      case StatisticThisTime.thisYear:
        return 'This Year';
    }
  }
}

enum TimeType {
  day,
  week,
  month,
  quarter,
  year,
  custom,
}

extension TimeTypeExtension on TimeType {
  String get name {
    switch (this) {
      case TimeType.day:
        return 'Day';
      case TimeType.week:
        return 'Week';
      case TimeType.month:
        return 'Month';
      case TimeType.quarter:
        return 'Quarter';
      case TimeType.year:
        return 'Year';
      case TimeType.custom:
        return 'Custom';
    }
  }
}
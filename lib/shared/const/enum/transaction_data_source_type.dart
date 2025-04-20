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
      case TransactionDataSourceType.allTime:
        return "All time";
      case TransactionDataSourceType.customFromTo:
        return "Custom From To";
    }
  }
}

enum Quarter {
  first,
  second,
  third,
  fourth,
}

extension QuarterExtension on Quarter {
  int get value {
    switch (this) {
      case Quarter.first:
        return 1;
      case Quarter.second:
        return 2;
      case Quarter.third:
        return 3;
      case Quarter.fourth:
        return 4;
    }
  }

  String get name {
    switch (this) {
      case Quarter.first:
        return 'Quý I';
      case Quarter.second:
        return 'Quý II';
      case Quarter.third:
        return 'Quý III';
      case Quarter.fourth:
        return 'Quý IV';
    }
  }

  Map<String, DateTime> get timeRange {
    final now = DateTime.now();
    int year = now.year;
    int startMonth;
    int endMonth;

    switch (this) {
      case Quarter.first:
        startMonth = 1;
        endMonth = 3;
        break;
      case Quarter.second:
        startMonth = 4;
        endMonth = 6;
        break;
      case Quarter.third:
        startMonth = 7;
        endMonth = 9;
        break;
      case Quarter.fourth:
        startMonth = 10;
        endMonth = 12;
        break;
    }

    return {
      'from': DateTime(year, startMonth, 1),
      'to': DateTime(year, endMonth + 1, 0), // Last day of the quarter
    };
  }
}
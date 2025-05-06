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
        return 'January';
      case Month.february:
        return 'February';
      case Month.march:
        return 'March';
      case Month.april:
        return 'April';
      case Month.may:
        return 'May';
      case Month.june:
        return 'June';
      case Month.july:
        return 'July';
      case Month.august:
        return 'August';
      case Month.september:
        return 'September';
      case Month.october:
        return 'October';
      case Month.november:
        return 'November';
      case Month.december:
        return 'December';
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
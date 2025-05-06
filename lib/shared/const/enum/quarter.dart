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
        return 'Quarter I';
      case Quarter.second:
        return 'Quarter II';
      case Quarter.third:
        return 'Quarter III';
      case Quarter.fourth:
        return 'Quarter IV';
    }
  }
}
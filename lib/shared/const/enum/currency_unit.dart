enum CurrencyUnit { k, m, b, t }

extension CurrencyUnitExtension on CurrencyUnit {
  String get symbol {
    switch (this) {
      case CurrencyUnit.k:
        return 'K';
      case CurrencyUnit.m:
        return 'M';
      case CurrencyUnit.b:
        return 'B';
      case CurrencyUnit.t:
        return 'T';
    }
  }

  String get name {
    switch (this) {
      case CurrencyUnit.k:
        return 'Nghìn';
      case CurrencyUnit.m:
        return 'Triệu';
      case CurrencyUnit.b:
        return 'Tỉ';
      case CurrencyUnit.t:
        return 'Nghìn tỉ';
    }
  }

  double get multiplier {
    switch (this) {
      case CurrencyUnit.k:
        return 1000;
      case CurrencyUnit.m:
        return 1000000;
      case CurrencyUnit.b:
        return 1000000000;
      case CurrencyUnit.t:
        return 1000000000000;
    }
  }
}
class Formatter {
  static String formatCurrency(double value) {
    String valueText = value.toString();
    if (valueText.endsWith(".0")){
      valueText = valueText.substring(0, valueText.length - 2);
    }

    //here should be 10000 or 10000.02 or 10000.1
    if (valueText == '0'){
      return '0';
    }

    bool isNegative = false;
    if (valueText.contains("-")) {
      isNegative = true;
      valueText = valueText.replaceAll("-", "");
    }

    if (valueText.contains(".")){
      List<String> parts = valueText.split('.');
      String integerPart = parts[0];
      String decimalPart = parts[1];

      integerPart = formatWithThousandSeparator(integerPart);
      if (decimalPart.length > 2) {
        //cut to 2 decimal places
        decimalPart = decimalPart.substring(0, 2);
      }

      if (isNegative) {
        integerPart = "-$integerPart";
      }

      return '$integerPart,$decimalPart';
    } else {
      //no contain decimal point
      String integerPart = formatWithThousandSeparator(valueText);

      if (isNegative) {
        integerPart = "-$integerPart";
      }
      return integerPart;
    }
  }

  static String formatWithThousandSeparator(String value) {
    int count = value.length;

    int numberOfCommas = (count - 1) ~/ 3;

    for (var i = 0; i < numberOfCommas; i++) {
      int index = count - (i + 1) * 3;
      if (index > 0) {
        value = value.replaceRange(index, index, '.');
      }
    }

    return value;
  }
}
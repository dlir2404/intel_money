import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_text.dart';

import '../../helper/formatter.dart';

class CurrencyDoubleText extends StatelessWidget {
  final double? value;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CurrencyDoubleText({
    super.key,
    this.value,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final text = Formatter.formatCurrency(value ?? 0);

    return CurrencyText(
      text: text,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}

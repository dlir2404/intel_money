import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';

class CurrencyText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const CurrencyText({super.key, required this.text, this.fontSize, this.color, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final currency = appState.currency;

        return Text(
          "$text ${currency?.symbol ?? ''}",
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
        );
      }
    );
  }
}
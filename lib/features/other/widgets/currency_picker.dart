import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import 'general_setting_select_input.dart';

class CurrencyPicker extends StatelessWidget {
  const CurrencyPicker({super.key});

  void _showCurrencyPicker(BuildContext context) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        AppState().setCurrency(currency);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final selectedCurrency = appState.currency;

        return GeneralSettingSelectInput(
          title: "Đơn vị tiền",
          selectedValue:
              selectedCurrency != null
                  ? "${selectedCurrency.name} (${selectedCurrency.symbol})"
                  : "VND",
          onTap: () {
            _showCurrencyPicker(context);
          },
        );
      },
    );
  }
}

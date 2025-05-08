import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/currency_picker.dart';
import '../widgets/general_setting_group.dart';
import '../widgets/general_setting_select_input.dart';
import '../widgets/timezone_picker.dart';

class GeneralSettingScreen extends StatelessWidget {
  const GeneralSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: const Text(
            'General setting',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        actions: [const SizedBox(width: 50)],
      ),
      body: Column(
        children: [
          GeneralSettingGroup(
            title: "Display",
            widgets: [
              GeneralSettingSelectInput(
                title: "Theme",
                selectedValue: "Light",
                onTap: () {
                  // Handle theme selection
                },
              ),
              CurrencyPicker(),
              TimezonePicker()
            ],
          ),
        ],
      ),
    );
  }
}

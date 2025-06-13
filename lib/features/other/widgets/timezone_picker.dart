import 'package:flutter/material.dart';
import 'package:intel_money/core/services/user_service.dart';
import 'package:intel_money/features/other/widgets/general_setting_select_input.dart';
import 'package:intel_money/features/other/widgets/timezone_list.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';

class TimezonePicker extends StatelessWidget {
  const TimezonePicker({super.key});

  void _showConfirmationDialog(
    BuildContext context,
    String timezone,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chọn múi giờ"),
          content: Text(
            'Bạn có chắc muốn đổi múi giờ thành $timezone?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  void _showTimezonePicker(BuildContext context, List<String> tzs) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Theme.of(context).cardColor,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return TimezoneList(
          timezones: tzs,
          onTimezoneSelected: (timezone) {
            _showConfirmationDialog(context, timezone, () {
              UserService().updateUserTimezone(timezone);
              Navigator.pop(context);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final selectedTimezone = state.userTimezone;
        final timezones = state.timezones;

        return GeneralSettingSelectInput(
          title: "Múi giờ",
          onTap: () => _showTimezonePicker(context, timezones),
          selectedValue: selectedTimezone ?? "UTC",
        );
      },
    );
  }
}

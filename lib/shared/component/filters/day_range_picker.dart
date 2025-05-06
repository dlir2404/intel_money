import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DayRangePicker extends StatefulWidget {
  const DayRangePicker({super.key});

  @override
  State<DayRangePicker> createState() => _DayRangePickerState();
}

class _DayRangePickerState extends State<DayRangePicker> {
  DateTimeRange? _selectedDateRange;
  
  Future<void> _showDateRangePicker(BuildContext context) async {
    DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        PickerDateRange? tempRange;
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              showActionButtons: true,
              onSubmit: (Object? value) {
                if (tempRange != null &&
                    tempRange!.startDate != null &&
                    tempRange!.endDate != null) {
                  Navigator.pop(
                    context,
                    DateTimeRange(
                      start: tempRange!.startDate!,
                      end: tempRange!.endDate!,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              onCancel: () {
                Navigator.pop(context);
              },
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                tempRange = args.value as PickerDateRange;
              },
            ),
          ),
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: () => _showDateRangePicker(context), child: const Text("Click me"))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../helper/app_time.dart';

class DateInput extends StatelessWidget {
  final String placeholder;
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  const DateInput({
    super.key,
    required this.placeholder,
    required this.onDateSelected,
    this.selectedDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
        final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

        final ThemeData theme = Theme.of(context);
        final bool useMaterial3 = theme.useMaterial3;

        final DialogThemeData dialogTheme = theme.dialogTheme;

        return Dialog(
          backgroundColor:
              datePickerTheme.backgroundColor ?? defaults.backgroundColor,
          elevation:
              useMaterial3
                  ? datePickerTheme.elevation ?? defaults.elevation!
                  : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24,
          shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
          surfaceTintColor:
              datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
          shape:
              useMaterial3
                  ? datePickerTheme.shape ?? defaults.shape
                  : datePickerTheme.shape ??
                      dialogTheme.shape ??
                      defaults.shape,
          clipBehavior: Clip.antiAlias,
          child: MainTimePicker(
              initialTime: selectedDate ?? DateTime.now(),
              onDateSelected: (DateTime selected) {
                onDateSelected(selected);
              }
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? AppTime.format(time: selectedDate!, pattern: "dd/MM/YYYY - HH:mm")
                  : placeholder,
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class MainTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onDateSelected;

  const MainTimePicker({super.key, required this.initialTime, required this.onDateSelected});

  @override
  State<MainTimePicker> createState() => _MainTimePickerState();
}

class _MainTimePickerState extends State<MainTimePicker> {
  DateTime _finalTime = DateTime.now();
  MainTimePickerMode _mode = MainTimePickerMode.date;

  @override
  void initState() {
    super.initState();
    _finalTime = widget.initialTime;
  }

  Widget _buildActions() {
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: OverflowBar(
          spacing: 8,
          children: <Widget>[
            TextButton(
              style:
                  datePickerTheme.cancelButtonStyle ??
                  defaults.cancelButtonStyle,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                (useMaterial3
                    ? localizations.cancelButtonLabel
                    : localizations.cancelButtonLabel.toUpperCase()),
              ),
            ),
            TextButton(
              style:
                  datePickerTheme.confirmButtonStyle ??
                  defaults.confirmButtonStyle,
              onPressed: () {
                Navigator.pop(context);
                _handleOk();
              },
              child: Text(localizations.okButtonLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOk() {
    // Notify the parent widget with the selected date and time
    widget.onDateSelected(_finalTime);
  }

  @override
  Widget build(BuildContext context) {
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _mode = MainTimePickerMode.date;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTime.format(time: _finalTime),
                        style: TextStyle(
                          color:
                              _mode == MainTimePickerMode.date
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _mode = MainTimePickerMode.time;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTime.format(time: _finalTime, pattern: "HH:mm"),
                        style: TextStyle(
                          color:
                              _mode == MainTimePickerMode.time
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        _mode == MainTimePickerMode.date
            ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                view: DateRangePickerView.month,
                allowViewNavigation: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor:
                      datePickerTheme.backgroundColor ??
                      defaults.backgroundColor,
                ),
                backgroundColor:
                    datePickerTheme.backgroundColor ?? defaults.backgroundColor,
                initialSelectedDate: _finalTime,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    final result = args.value as DateTime;
                    // keep the time
                    _finalTime = DateTime(
                      result.year,
                      result.month,
                      result.day,
                      _finalTime.hour,
                      _finalTime.minute,
                    );
                  });
                },
              ),
            )
            : SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: TimePickerSpinner(
                time: _finalTime,
                normalTextStyle: TextStyle(fontSize: 24, color: Colors.grey),
                highlightedTextStyle: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
                spacing: 50,
                itemHeight: 80,
                isForce2Digits: true,
                onTimeChange: (time) {
                  setState(() {
                    _finalTime = DateTime(
                      _finalTime.year,
                      _finalTime.month,
                      _finalTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
              ),
            ),

        _buildActions(),
      ],
    );
  }
}

enum MainTimePickerMode { date, time }

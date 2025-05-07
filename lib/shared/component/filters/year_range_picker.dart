import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../helper/app_time.dart';

class YearRangePicker extends StatefulWidget {
  final Function(PickerDateRange?)? onChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const YearRangePicker({super.key, this.onChanged, this.startDate, this.endDate});

  @override
  State<YearRangePicker> createState() => _YearRangePickerState();
}

class _YearRangePickerState extends State<YearRangePicker> {
  PickerDateRange? _selectedRange;
  PickerDateRange? _tempDateRange;

  void _handleOk() {
    if (_tempDateRange != null &&
        _tempDateRange!.startDate != null &&
        _tempDateRange!.endDate != null) {

      setState(() {
        _selectedRange = _tempDateRange;
      });

      if (widget.onChanged != null) {
        widget.onChanged!(_selectedRange);
      }
    }
  }

  Future<void> _showYearRangePicker(BuildContext context) async {
    showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final bool useMaterial3 = theme.useMaterial3;
        final MaterialLocalizations localizations = MaterialLocalizations.of(
          context,
        );
        final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
        final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

        final Widget actions = Padding(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 24, bottom: 16),
                child: Text(
                  'Select Year Range',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: SfDateRangePicker(
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor:
                        datePickerTheme.backgroundColor ??
                        defaults.backgroundColor,
                  ),
                  backgroundColor:
                      datePickerTheme.backgroundColor ??
                      defaults.backgroundColor,
                  selectionMode: DateRangePickerSelectionMode.range,
                  view: DateRangePickerView.decade,
                  allowViewNavigation: false,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      _tempDateRange = args.value as PickerDateRange;
                    });
                  },
                ),
              ),

              actions,
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.startDate != null && widget.endDate != null) {
      _selectedRange = PickerDateRange(widget.startDate, widget.endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showYearRangePicker(context);
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.grey[400]),
            const SizedBox(width: 8),

            Text(
              (_selectedRange != null &&
                  _selectedRange!.startDate != null &&
                  _selectedRange!.endDate != null)
                  ? '${AppTime.format(time: _selectedRange!.startDate!, pattern: "YYYY")} - ${AppTime.format(time: _selectedRange!.endDate!, pattern: "YYYY")}'
                  : 'Select year range',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(child: const SizedBox()),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

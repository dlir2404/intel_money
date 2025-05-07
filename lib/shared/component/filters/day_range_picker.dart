import 'package:flutter/material.dart';
import 'package:intel_money/shared/helper/app_time.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DayRangePicker extends StatefulWidget {
  final Function(PickerDateRange?)? onChanged;
  final DateTime? startDate;
  final DateTime? endDate;

  const DayRangePicker({
    super.key,
    this.onChanged,
    this.startDate,
    this.endDate,
  });

  @override
  State<DayRangePicker> createState() => _DayRangePickerState();
}

class _DayRangePickerState extends State<DayRangePicker> {
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

  Future<void> _showDateRangePicker(BuildContext context) async {
    showDialog<PickerDateRange>(
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
                  'Select Date Range',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: SfDateRangePicker(
                  initialSelectedRange: _selectedRange,
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
                  view: DateRangePickerView.month,
                  allowViewNavigation: false,
                  onSelectionChanged: (
                    DateRangePickerSelectionChangedArgs args,
                  ) {
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
        _showDateRangePicker(context);
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
                  ? '${AppTime.format(time: _selectedRange!.startDate!)} - ${AppTime.format(time: _selectedRange!.endDate!)}'
                  : 'Select date range',
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

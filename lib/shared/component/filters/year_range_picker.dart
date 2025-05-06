import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class YearRangePicker extends StatefulWidget {
  final Function(PickerDateRange?)? onChanged;
  const YearRangePicker({super.key, this.onChanged});

  @override
  State<YearRangePicker> createState() => _YearRangePickerState();
}

class _YearRangePickerState extends State<YearRangePicker> {
  PickerDateRange? _selectedMonthRange;

  void _handleOk() {
    if (widget.onChanged != null) {
      widget.onChanged!(_selectedMonthRange);
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
                  onPressed: () {},
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
                  onPressed: _handleOk,
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
                      _selectedMonthRange = args.value as PickerDateRange;
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
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _showYearRangePicker(context),
            child: const Text("Select year range"),
          ),
        ],
      ),
    );
  }
}

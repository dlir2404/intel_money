import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../shared/helper/app_time.dart';

class SelectDataSourceTypeScreen extends StatefulWidget {
  final TransactionDataSourceType type;
  final Map<String, DateTime>? customTimeRange;
  final Function(
    TransactionDataSourceType type, {
    Map<String, DateTime>? timeRange,
  })?
  onSelect;

  const SelectDataSourceTypeScreen({
    super.key,
    required this.type,
    this.customTimeRange,
    this.onSelect,
  });

  @override
  State<SelectDataSourceTypeScreen> createState() =>
      _SelectDataSourceTypeScreenState();
}

class _SelectDataSourceTypeScreenState extends State<SelectDataSourceTypeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    int initialIndex = _getInitialTabIndex();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  int _getInitialTabIndex() {
    switch (widget.type) {
      case TransactionDataSourceType.today:
      case TransactionDataSourceType.yesterday:
      case TransactionDataSourceType.customDay:
        return 0;
      case TransactionDataSourceType.thisWeek:
      case TransactionDataSourceType.lastWeek:
        return 1;
      case TransactionDataSourceType.thisMonth:
      case TransactionDataSourceType.lastMonth:
      case TransactionDataSourceType.customMonth:
        return 2;
      case TransactionDataSourceType.quarter1:
      case TransactionDataSourceType.quarter2:
      case TransactionDataSourceType.quarter3:
      case TransactionDataSourceType.quarter4:
        return 3;
      case TransactionDataSourceType.allTime:
      case TransactionDataSourceType.customFromTo:
        return 4;
      case TransactionDataSourceType.thisYear:
        return 0; // Default to Day tab for thisYear
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: const [
                Tab(text: "Day"),
                Tab(text: "Week"),
                Tab(text: "Month"),
                Tab(text: "Quarter"),
                Tab(text: "Custom"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DayDataSourceType(
                    type: widget.type,
                    customTimeRange: widget.customTimeRange,
                    onSelect: (type, {Map<String, DateTime>? timeRange}) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type, timeRange: timeRange);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  WeekDataSourceType(
                    type: widget.type,
                    onSelect: (type) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  MonthDataSourceType(
                    type: widget.type,
                    customTimeRange: widget.customTimeRange,
                    onSelect: (type, {Map<String, DateTime>? timeRange}) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type, timeRange: timeRange);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  QuarterDataSourceType(
                    type: widget.type,
                    onSelect: (type) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  CustomDataSourceType(
                    type: widget.type,
                    customTimeRange: widget.customTimeRange,
                    onSelect: (type, {Map<String, DateTime>? timeRange}) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type, timeRange: timeRange);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class DayDataSourceType extends StatelessWidget {
  final TransactionDataSourceType type;
  final Map<String, DateTime>? customTimeRange;
  final Function(
    TransactionDataSourceType type, {
    Map<String, DateTime>? timeRange,
  })?
  onSelect;

  const DayDataSourceType({
    super.key,
    required this.type,
    this.onSelect,
    this.customTimeRange,
  });

  Future<void> _selectCustomDay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          customTimeRange != null ? customTimeRange!['from']! : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (onSelect != null) {
        onSelect!(
          TransactionDataSourceType.customDay,
          timeRange: {
            "from": picked,
            "to": picked.add(const Duration(days: 1)),
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.today);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today"),
                if (type == TransactionDataSourceType.today)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.yesterday);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Yesterday"),
                if (type == TransactionDataSourceType.yesterday)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _selectCustomDay(context);
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (type == TransactionDataSourceType.customDay &&
                          customTimeRange != null)
                      ? "Other: ${AppTime.format(time: customTimeRange!['from']!)}"
                      : "Other",
                ),
                if (type == TransactionDataSourceType.customDay)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WeekDataSourceType extends StatelessWidget {
  final TransactionDataSourceType type;
  final Function(TransactionDataSourceType type)? onSelect;

  const WeekDataSourceType({super.key, required this.type, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.thisWeek);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.thisWeek.name),
                if (type == TransactionDataSourceType.thisWeek)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.lastWeek);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.lastWeek.name),
                if (type == TransactionDataSourceType.lastWeek)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MonthDataSourceType extends StatelessWidget {
  final TransactionDataSourceType type;
  final Map<String, DateTime>? customTimeRange;
  final Function(
    TransactionDataSourceType type, {
    Map<String, DateTime>? timeRange,
  })?
  onSelect;

  const MonthDataSourceType({
    super.key,
    required this.type,
    this.onSelect,
    this.customTimeRange,
  });

  Future<void> _selectCustomMonth(BuildContext context) async {
    DateTime? selectedDate;

    await showDialog(
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
                    Navigator.pop(context, selectedDate);
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
                  'Select Month',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: SfDateRangePicker(
                  initialSelectedDate: customTimeRange != null ? customTimeRange!['from']! :  DateTime.now(),
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor:
                        datePickerTheme.backgroundColor ??
                        defaults.backgroundColor,
                  ),
                  backgroundColor:
                      datePickerTheme.backgroundColor ??
                      defaults.backgroundColor,
                  selectionMode: DateRangePickerSelectionMode.single,
                  view: DateRangePickerView.year,
                  allowViewNavigation: false,
                  onSelectionChanged: (
                    DateRangePickerSelectionChangedArgs args,
                  ) {
                    if (args.value is DateTime) {
                      selectedDate = args.value;
                    }
                  },
                ),
              ),
              actions,
            ],
          ),
        );
      },
    );

    if (selectedDate != null && onSelect != null) {
      // Calculate the first and last day of the selected month
      DateTime firstDayOfMonth = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        1,
      );
      DateTime lastDayOfMonth = DateTime(
        selectedDate!.year,
        selectedDate!.month + 1,
        0,
      );

      onSelect!(
        TransactionDataSourceType.customMonth,
        timeRange: {"from": firstDayOfMonth, "to": lastDayOfMonth},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.thisMonth);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("This month"),
                if (type == TransactionDataSourceType.thisMonth)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.lastMonth);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Last month"),
                if (type == TransactionDataSourceType.lastMonth)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _selectCustomMonth(context);
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (type == TransactionDataSourceType.customMonth &&
                          customTimeRange != null)
                      ? "Other: ${AppTime.format(time: customTimeRange!['from']!, pattern: "MM/YYYY")}"
                      : "Other",
                ),
                if (type == TransactionDataSourceType.customMonth)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class QuarterDataSourceType extends StatelessWidget {
  final TransactionDataSourceType type;
  final Function(TransactionDataSourceType type)? onSelect;

  const QuarterDataSourceType({super.key, required this.type, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.quarter1);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.quarter1.name),
                if (type == TransactionDataSourceType.quarter1)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.quarter2);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.quarter2.name),
                if (type == TransactionDataSourceType.quarter2)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.quarter3);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.quarter3.name),
                if (type == TransactionDataSourceType.quarter3)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.quarter4);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TransactionDataSourceType.quarter4.name),
                if (type == TransactionDataSourceType.quarter4)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDataSourceType extends StatelessWidget {
  final TransactionDataSourceType type;
  final Map<String, DateTime>? customTimeRange;
  final Function(TransactionDataSourceType type, {Map<String, DateTime> timeRange})? onSelect;

  const CustomDataSourceType({super.key, required this.type, this.onSelect, this.customTimeRange});

  Future<void> _selectCustomRange(BuildContext context) async {
    PickerDateRange? dateRange;
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

                    if (dateRange != null) {
                      final from = AppTime.startOfDay(dateRange!.startDate!);
                      final to = AppTime.endOfDay(dateRange!.endDate!);

                      onSelect!(
                        TransactionDataSourceType.customFromTo,
                        timeRange: {
                          "from": from,
                          "to": to,
                        },
                      );
                    }
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
                  initialSelectedRange: PickerDateRange(
                      customTimeRange != null ? customTimeRange!['from'] : DateTime.now(),
                      customTimeRange != null ? customTimeRange!['to'] : DateTime.now(),
                  ),
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
                    dateRange = args.value as PickerDateRange;
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
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.allTime);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("All time"),
                if (type == TransactionDataSourceType.allTime)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _selectCustomRange(context);
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text((type == TransactionDataSourceType.customFromTo && customTimeRange != null)
                    ? "Other: ${AppTime.format(time: customTimeRange!['from']!)} - ${AppTime.format(time: customTimeRange!['to']!)}"
                    : "Other"),
                if (type == TransactionDataSourceType.customFromTo)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

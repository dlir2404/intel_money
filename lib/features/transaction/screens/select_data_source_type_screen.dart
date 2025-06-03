import 'package:flutter/material.dart';

import '../../../shared/const/enum/transaction_data_source_type.dart';

class SelectDataSourceTypeScreen extends StatefulWidget {
  final TransactionDataSourceType type;
  final Function(
    TransactionDataSourceType type, {
    Map<String, DateTime>? timeRange,
  })?
  onSelect;

  const SelectDataSourceTypeScreen({
    super.key,
    required this.type,
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
                    onSelect: (type) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type);
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
                    onSelect: (type) {
                      if (widget.onSelect != null) {
                        widget.onSelect!(type);
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
  final Function(
    TransactionDataSourceType type, {
    Map<String, DateTime>? timeRange,
  })?
  onSelect;

  const DayDataSourceType({super.key, required this.type, this.onSelect});

  Future<void> _selectCustomDay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
                const Text("Custom Day"),
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
  final Function(TransactionDataSourceType type)? onSelect;

  const MonthDataSourceType({super.key, required this.type, this.onSelect});

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
            if (onSelect != null) {
              onSelect!(TransactionDataSourceType.customMonth);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Other"),
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
  final Function(TransactionDataSourceType type)? onSelect;

  const CustomDataSourceType({super.key, required this.type, this.onSelect});

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
      ],
    );
  }
}

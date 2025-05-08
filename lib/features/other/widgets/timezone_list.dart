import 'package:flutter/material.dart';

class TimezoneList extends StatefulWidget {
  final Function(String)? onTimezoneSelected;
  final List<String> timezones;

  const TimezoneList({
    super.key,
    this.onTimezoneSelected,
    required this.timezones,
  });

  @override
  State<TimezoneList> createState() => _TimezoneListState();
}

class _TimezoneListState extends State<TimezoneList> {
  List<String> _suggestions = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _suggestions = widget.timezones;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search Timezone',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _suggestions =
                    widget.timezones
                        .where(
                          (tz) =>
                              tz.toLowerCase().contains(value.toLowerCase()),
                        )
                        .toList();
              });
            },
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._suggestions.map(
                      (tz) => ListTile(
                    title: Text(tz),
                    onTap: () {
                      if (widget.onTimezoneSelected != null) {
                        widget.onTimezoneSelected!(tz);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

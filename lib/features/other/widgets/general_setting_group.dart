import 'package:flutter/material.dart';

class GeneralSettingGroup extends StatelessWidget {
  final String title;
  final List<Widget> widgets;

  const GeneralSettingGroup({
    super.key,
    required this.widgets,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          color: Colors.grey[200],
          width: double.infinity,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ...widgets,
      ],
    );
  }
}

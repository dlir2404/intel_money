import 'package:flutter/material.dart';

class GeneralSettingSelectInput extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final Function() onTap;

  const GeneralSettingSelectInput({
    super.key,
    required this.title,
    this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //border top
        Container(color: Colors.grey[300], height: 0.5),

        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),

                Row(
                  children: [
                    Text(
                      selectedValue ?? 'Select',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ),

        //border bottom
        Container(color: Colors.grey[300], height: 0.5),
      ],
    );
  }
}

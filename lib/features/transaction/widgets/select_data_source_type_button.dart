import 'package:flutter/material.dart';

class SelectDataSourceTypeButton extends StatelessWidget {
  final Function() onTap;
  final String displayText;

  const SelectDataSourceTypeButton({
    super.key,
    required this.displayText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

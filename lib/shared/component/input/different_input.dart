import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

class DifferentInput extends StatefulWidget {
  final double oldValue;
  final double newValue;
  final String oldLabel;
  final String newLabel;
  final Function(double) onValueChanged;

  const DifferentInput({
    super.key,
    required this.oldValue,
    required this.newValue,
    required this.oldLabel,
    required this.newLabel,
    required this.onValueChanged,
  });

  @override
  State<DifferentInput> createState() => _DifferentInputState();
}

class _DifferentInputState extends State<DifferentInput> {
  late double _oldValue;
  late double _newValue;
  late String _oldLabel;
  late String _newLabel;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.oldValue;
    _newValue = widget.newValue;
    _oldLabel = widget.oldLabel;
    _newLabel = widget.newLabel;
  }

  @override
  void didUpdateWidget(covariant DifferentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.oldValue != widget.oldValue) {
      _oldValue = widget.oldValue;
      _oldLabel = widget.oldLabel;
    }
    if (oldWidget.newValue != widget.newValue) {
      _newValue = widget.newValue;
      _newLabel = widget.newLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difference = _newValue - _oldValue;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_oldLabel), CurrencyDoubleText(value: _oldValue)],
            ),
          ),
          Divider(thickness: 0.5, height: 0),
          MainInput(
            initialValue: _newValue,
            label: _newLabel,
            onChanged: (value) {
              setState(() {
                _newValue = value;
                widget.onValueChanged(value);
              });
            },
            mode: MainInputMode.inline,
          ),
          Divider(thickness: 0.5, height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Difference"),
                difference > 0
                    ? CurrencyDoubleText(value: difference, color: Colors.green)
                    : difference == 0
                    ? const CurrencyDoubleText(value: 0)
                    : CurrencyDoubleText(value: difference, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

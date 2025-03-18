import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;
  final String currency;
  final bool showDecimals;

  const MainInput({
    Key? key,
    this.label,
    this.hint,
    required this.controller,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
    this.currency = '\$',
    this.showDecimals = false,
  }) : super(key: key);

  @override
  State<MainInput> createState() => _MainInputState();
}

class _MainInputState extends State<MainInput> {
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  String _displayText = '';
  String _calculationBuffer = '';
  bool _isCalculating = false;
  String _currentOperation = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(_handleFocusChange);
    });

    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
      _formatDisplayText();
    } else {
      // Initialize with 0 if no initial value
      widget.controller.text = '0';
      _formatDisplayText();
    }
  }

  void _handleFocusChange() {
    debugPrint("Focus changed: ${_focusNode.hasFocus}");
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _formatDisplayText() {
    if (widget.controller.text.isEmpty) {
      _displayText = '';
      return;
    }

    try {
      double value = double.parse(widget.controller.text);

      // Format with or without decimal places based on settings
      final formatter = widget.showDecimals
          ? NumberFormat('#,##0.00')
          : NumberFormat('#,###');

      _displayText = '${widget.currency} ${formatter.format(value)}';
    } catch (e) {
      _displayText = widget.controller.text;
    }

    setState(() {});
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (!mounted) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = _isCalculating ? _createCalculatorOverlay() : _createOverlay();
    overlay.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        child: Material(
          elevation: 4.0,
          child: EnhancedMoneyKeyboard(
            onKeyPressed: _handleKeyPress,
            showEquals: false,
            operation: _currentOperation,
          ),
        ),
      ),
    );
  }

  OverlayEntry _createCalculatorOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        child: Material(
          elevation: 4.0,
          child: EnhancedMoneyKeyboard(
            onKeyPressed: _handleKeyPress,
            showEquals: true,
            operation: _currentOperation,
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleKeyPress(String key) {
    if (key == 'C') {
      // Clear everything and set to 0
      widget.controller.text = '0';
      _calculationBuffer = '';
      _isCalculating = false;
      _currentOperation = '';
    } else if (key == 'backspace') {
      if (widget.controller.text.length <= 1) {
        // If only one digit or empty, set to 0
        widget.controller.text = '0';
      } else {
        // Remove last character
        widget.controller.text = widget.controller.text.substring(
            0, widget.controller.text.length - 1);
      }
    } else if (key == 'Done') {
      _performCalculation(); // Calculate any pending operation
      _focusNode.unfocus(); // Close the keyboard
    } else if (['+', '-', '×', '÷'].contains(key)) {
      // Start calculation mode
      if (widget.controller.text.isNotEmpty) {
        _calculationBuffer = widget.controller.text;
        _currentOperation = key;
        _isCalculating = true;
        widget.controller.text = '0'; // Reset input for next number

        // Change "Done" button to "="
        _overlayEntry?.remove();
        _overlayEntry = _createCalculatorOverlay();
        Overlay.of(context).insert(_overlayEntry!);
      }
    } else if (key == '=') {
      _performCalculation();
      _focusNode.unfocus(); // Close keyboard after calculation
    } else if (key == '+/-') {
      // Toggle sign of current input
      if (widget.controller.text.isNotEmpty && widget.controller.text != '0') {
        try {
          double value = double.parse(widget.controller.text);
          value = -value;
          widget.controller.text = value.toString();
        } catch (e) {
          // Handle parsing error
          debugPrint("Error toggling sign: $e");
        }
      }
    } else if (key == '000') {
      if (widget.controller.text == '0') {
        // If current value is 0, keep it 0
        widget.controller.text = '0';
      } else {
        // Append 000
        widget.controller.text = widget.controller.text + '000';
      }
    } else if (key == ',') {
      if (!widget.controller.text.contains('.')) {
        widget.controller.text = widget.controller.text + '.';
      }
    } else {
      // Handle numeric input
      if (widget.controller.text == '0') {
        // Replace 0 with the new digit
        widget.controller.text = key;
      } else {
        // Append the digit
        widget.controller.text = widget.controller.text + key;
      }
    }

    _formatDisplayText();
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  void _performCalculation() {
    if (_isCalculating && _calculationBuffer.isNotEmpty) {
      try {
        double firstNum = double.parse(_calculationBuffer);
        double secondNum = double.parse(widget.controller.text);
        double result = 0;

        switch (_currentOperation) {
          case '+':
            result = firstNum + secondNum;
            break;
          case '-':
            result = firstNum - secondNum;
            break;
          case '×':
            result = firstNum * secondNum;
            break;
          case '÷':
            if (secondNum != 0) {
              result = firstNum / secondNum;
            } else {
              // Handle division by zero
              result = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot divide by zero')),
              );
            }
            break;
        }

        widget.controller.text = result.toString();
        _calculationBuffer = '';
        _isCalculating = false;
        _currentOperation = '';
      } catch (e) {
        // Handle calculation error
        debugPrint("Calculation error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayText.isEmpty ? (widget.hint ?? 'Enter amount') : _displayText,
                    style: TextStyle(
                      color: _displayText.isEmpty ? Colors.grey : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.attach_money, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EnhancedMoneyKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final bool showEquals;
  final String operation;

  const EnhancedMoneyKeyboard({
    Key? key,
    required this.onKeyPressed,
    this.showEquals = false,
    this.operation = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildKeyboardRow(['C', '÷', '×', 'backspace']),
          buildKeyboardRow(['7', '8', '9', '-']),
          buildKeyboardRow(['4', '5', '6', '+']),
          buildKeyboardRow(['1', '2', '3', '+/-']),
          buildKeyboardRow(['0', '000', ',', showEquals ? '=' : 'Done']),
        ],
      ),
    );
  }

  Widget buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        Color backgroundColor = Colors.white;
        Color textColor = Colors.black87;
        IconData? icon;

        // Style different types of keys
        if (key == 'backspace') {
          icon = Icons.backspace_outlined;
          backgroundColor = Colors.grey.shade300;
        } else if (key == 'Done' || key == '=') {
          backgroundColor = Colors.blue;
          textColor = Colors.white;
        } else if (key == 'C') {
          backgroundColor = Colors.red.shade100;
          textColor = Colors.red.shade700;
        } else if (['+', '-', '×', '÷', '+/-'].contains(key)) {
          bool isActive = key == operation;
          backgroundColor = isActive ? Colors.blue : Colors.blue.shade100;
          textColor = isActive ? Colors.white : Colors.blue.shade800;
        }

        return Expanded(
          child: Container(
            height: 60,
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => onKeyPressed(key),
                child: Center(
                  child: icon != null
                      ? Icon(icon, color: textColor)
                      : Text(
                    key,
                    style: TextStyle(
                      fontSize: (key == 'Done' || key == '=') ? 16 : 20,
                      fontWeight: (key == 'Done' || key == '=') ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
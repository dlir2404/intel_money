import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_text.dart';
import 'package:intl/intl.dart';

import '../../helper/toast.dart';

class MainInput extends StatefulWidget {
  final String? label;
  final Function(double)? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? initialValue;

  final MainInputMode mode;

  const MainInput({
    super.key,
    this.label,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
    this.mode = MainInputMode.vertical,
  });

  @override
  State<MainInput> createState() => _MainInputState();
}

class _MainInputState extends State<MainInput> {
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  String _calculationBuffer = '';
  bool _isCalculating = false;
  String _currentOperation = '';

  double _value = 0;
  String _displayText = '0';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(_handleFocusChange);
    });

    if (widget.initialValue != null) {
      _value = widget.initialValue!;

      String valueText = _value.toString();
      if (valueText.endsWith('.0')) {
        valueText = valueText.substring(0, valueText.length - 2);
      }

      valueText = valueText.replaceAll(".", ",");
      _displayText = _getDisplayText(valueText);

      //try parse again in case of too much decimal places
      _value = _getValueFromDisplayText(_displayText);
    }
  }

  @override
  void didUpdateWidget(covariant MainInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initialValue has changed
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null) {
      _value = widget.initialValue!;

      String valueText = _value.toString();
      if (valueText.endsWith('.0')) {
        valueText = valueText.substring(0, valueText.length - 2);
      }

      valueText = valueText.replaceAll(".", ",");
      _displayText = _getDisplayText(valueText);

      //try parse again in case of too much decimal places
      _value = _getValueFromDisplayText(_displayText);
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;

    try {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      debugPrint("Error in focus change handler: $e");
    }
  }

  @override
  @override
  void dispose() {
    // First cancel any pending operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This ensures we're not in the middle of a build when removing the overlay
      _removeOverlay();
    });

    // Safely remove the listener - using try/catch to handle potential issues
    try {
      if (_focusNode.hasListeners) {
        _focusNode.removeListener(_handleFocusChange);
      }
    } catch (e) {
      debugPrint("Error removing focus listener: $e");
    }

    // Only dispose the FocusNode if we created it
    if (widget.focusNode == null) {
      try {
        // _focusNode.dispose();
      } catch (e) {
        debugPrint("Error disposing focus node: $e");
      }
    }

    super.dispose();
  }

  double _getValueFromDisplayText(String displayText) {
    bool isNegative = false;
    if (displayText.contains("-")) {
      isNegative = true;
      displayText = displayText.replaceAll("-", "");
    }

    // Remove thousand separators & replace decimal point
    String sanitizedText = displayText.replaceAll('.', '').replaceAll(',', '.');

    if (isNegative) {
      sanitizedText = "-$sanitizedText";
    }

    // Parse the sanitized text to double
    return double.tryParse(sanitizedText) ?? 0;
  }

  String _getDisplayText(String value) {
    //remove thousand separators
    value = value.replaceAll('.', '');
    if (value == '0') {
      return '0';
    }

    bool isNegative = false;
    if (value.contains("-")) {
      isNegative = true;
      value = value.replaceAll("-", "");
    }

    if (value.contains(",")) {
      List<String> parts = value.split(',');
      String integerPart = parts[0];
      String decimalPart = parts[1];

      integerPart = _formatWithThousandSeparator(integerPart);
      if (decimalPart.length > 2) {
        //cut to 2 decimal places
        decimalPart = decimalPart.substring(0, 2);
      }

      if (isNegative) {
        integerPart = "-$integerPart";
      }

      return '$integerPart,$decimalPart';
    } else {
      //no contain decimal point
      String integerPart = _formatWithThousandSeparator(value);

      if (isNegative) {
        integerPart = "-$integerPart";
      }
      return integerPart;
    }
  }

  String _formatWithThousandSeparator(String value) {
    int count = value.length;

    int numberOfCommas = (count - 1) ~/ 3;

    for (var i = 0; i < numberOfCommas; i++) {
      int index = count - (i + 1) * 3;
      if (index > 0) {
        value = value.replaceRange(index, index, '.');
      }
    }

    return value;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (!mounted) return;

    final overlay = Overlay.of(context);

    _overlayEntry =
        _isCalculating ? _createCalculatorOverlay() : _createOverlay();
    overlay.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder:
          (context) => Positioned(
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
      builder:
          (context) => Positioned(
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
      _displayText = '0';
      _calculationBuffer = '';
      _isCalculating = false;
      _currentOperation = '';

      _overlayEntry?.remove();
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else if (key == 'backspace') {
      if (_displayText.length <= 1) {
        // If only one digit or empty, set to 0
        _displayText = '0';
      } else {
        // Remove last character
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    } else if (key == 'Done') {
      _performCalculation(); // Calculate any pending operation
      _focusNode.unfocus(); // Close the keyboard
    } else if (['+', '-', '×', '÷'].contains(key)) {
      if (_isCalculating) {
        _performCalculation();
      }

      // Start calculation mode
      _calculationBuffer = _displayText;
      _currentOperation = key;
      _isCalculating = true;
      _displayText = '0'; // Reset input for next number

      // Change "Done" button to "="
      _overlayEntry?.remove();
      _overlayEntry = _createCalculatorOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else if (key == '=') {
      _performCalculation();
      _focusNode.unfocus(); // Close keyboard after calculation
    } else if (key == '+/-') {
      // Toggle sign of current input
      if (_displayText != '0' && _displayText != '0,') {
        _value = -_value;

        String valueText = _value.toString();
        if (valueText.endsWith('.0')) {
          valueText = valueText.substring(0, valueText.length - 2);
        }

        valueText = valueText.replaceAll(".", ",");
        _displayText = _getDisplayText(valueText);
      }
    } else if (key == '000') {
      if (_displayText == '0' || !_checkLimit(_displayText)) {
        //do nothing
      } else if (_displayText.endsWith(",")) {
        _displayText = '${_displayText}00';
      } else {
        if (_displayText.length + 3 > 16) {
          int needed = 16 - _displayText.length;
          _displayText = _displayText + '0' * needed;
        } else {
          // Add three zeros
          _displayText = '${_displayText}000';
        }
      }
    } else if (key == ',') {
      // Add decimal point if not already present
      if (!_displayText.contains(',')) {
        //insert comma
        _displayText = '$_displayText,';
      } else if (_displayText.endsWith(',')) {
        // If it ends with a comma, remove it
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    } else {
      // Handle numeric input
      if (_displayText == '0') {
        // Replace 0 with the new digit
        _displayText = key;
      } else if (!_checkLimit(_displayText)) {
        return;
      } else {
        // Check if adding would exceed decimal limit
        if (_displayText.contains(',')) {
          List<String> parts = _displayText.split(',');
          if (parts.length > 1 && parts[1].length >= 2) {
            return;
          }
        }
        // Append the digit
        _displayText = _displayText + key;
      }
    }

    _displayText = _getDisplayText(_displayText);
    _value = _getValueFromDisplayText(_displayText);
    if (widget.onChanged != null) {
      widget.onChanged!(_value);
    }
  }

  /// return true if limit is reached
  bool _checkLimit(String value) {
    if (value.contains(",")) {
      value = value.split(",")[0];
    }

    if (value.length > 16) {
      return false;
    }

    return true;
  }

  void _performCalculation() {
    if (_isCalculating) {
      try {
        double firstNum = _getValueFromDisplayText(_calculationBuffer);
        double secondNum = _getValueFromDisplayText(_displayText);
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
              AppToast.showError(context, 'Cannot divide by zero');
            }
            break;
        }

        String resultText = result.toString();
        String integerPart = resultText.split(".")[0];
        String decimalPart = resultText.split(".")[1];
        if (decimalPart.length == 1 && decimalPart == "0") {
          resultText = integerPart;
        } else if (decimalPart.length >= 2) {
          decimalPart = decimalPart.substring(0, 2);

          if (decimalPart == "00") {
            resultText = integerPart;
          } else {
            resultText = "$integerPart,$decimalPart";
          }
        }

        _displayText = _getDisplayText(resultText);
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
    return widget.mode == MainInputMode.vertical
        ? Column(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    CurrencyText(
                      text: _displayText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        : InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CurrencyText(
                  text: _displayText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
  }
}

class EnhancedMoneyKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final bool showEquals;
  final String operation;

  const EnhancedMoneyKeyboard({
    super.key,
    required this.onKeyPressed,
    this.showEquals = false,
    this.operation = '',
  });

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
      children:
          keys.map((key) {
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
                      child:
                          icon != null
                              ? Icon(icon, color: textColor)
                              : Text(
                                key,
                                style: TextStyle(
                                  fontSize:
                                      (key == 'Done' || key == '=') ? 16 : 20,
                                  fontWeight:
                                      (key == 'Done' || key == '=')
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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

enum MainInputMode { vertical, inline }

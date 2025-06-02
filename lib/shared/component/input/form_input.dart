import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final String? label;
  final Widget? prefixIcon;

  const FormInput({
    super.key,
    this.controller,
    this.placeholder,
    this.validator, this.maxLines, this.label, this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        labelText: label,
        hintStyle: TextStyle(color: Colors.grey),
        filled: false,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        prefixIcon: prefixIcon
      ),
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }
}

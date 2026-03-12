import 'package:flutter/material.dart';
import 'package:stably_app/shared/widgets/app_text_field.dart';

class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    required this.controller,
    required this.label,
    this.placeholder,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      placeholder: placeholder,
      validator: validator,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

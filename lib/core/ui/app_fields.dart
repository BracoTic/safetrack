import 'package:flutter/material.dart';

const kOrange = Color(0xFFFF5F00);

InputDecoration appInputDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Colors.white),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(47),
    borderSide: const BorderSide(color: kOrange),
  ),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(47)),
);

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int? maxLines; // 👈 nuevo
  final int? minLines; // 👈 opcional

  const AppTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.validator,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = obscure ? 1 : (maxLines ?? 1); // si es password, forzar 1
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: lines,
      minLines: obscure ? 1 : minLines,
      style: const TextStyle(color: Colors.white),
      decoration: appInputDecoration(label).copyWith(suffixIcon: suffixIcon),
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const AppDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: appInputDecoration(label),
      dropdownColor: const Color(0xFF1A1D29),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      items: items,
      onChanged: onChanged,
    );
  }
}

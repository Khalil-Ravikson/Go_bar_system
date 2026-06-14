import 'package:flutter/material.dart';
import '../spacing.dart';
import '../colors.dart';

class CleanTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const CleanTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          autofocus: autofocus,
          enabled: enabled,
        ),
      ],
    );
  }
}

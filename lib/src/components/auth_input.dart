import 'package:flutter/material.dart';


class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

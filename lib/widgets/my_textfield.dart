import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const MyTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.obscureText,
    this.keyboardType = TextInputType.text,
    this.suffixIcon, // Default to text input
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
          labelStyle: const TextStyle(fontSize: 18),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

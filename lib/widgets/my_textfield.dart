import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Key? fieldKey;
  final VoidCallback? onVisibilityToggle;
  final bool showVisibilityToggle;

  const MyTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.obscureText,
    this.fieldKey,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onVisibilityToggle,
    this.showVisibilityToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        key: fieldKey,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
          labelStyle: const TextStyle(fontSize: 18),
          suffixIcon: suffixIcon ??
              (showVisibilityToggle
                  ? IconButton(
                      key: Key('visibility_toggle_$title'),
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null),
        ),
      ),
    );
  }
}

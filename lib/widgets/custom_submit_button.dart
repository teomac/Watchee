import 'package:flutter/material.dart';

class CustomSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double? fontSize;

  const CustomSubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.deepPurple,
    this.foregroundColor = Colors.white,
    this.width = 280,
    this.height = 60,
    this.fontSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        fixedSize: Size(width!, height!),
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

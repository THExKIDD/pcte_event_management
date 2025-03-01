import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.white,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        maximumSize: Size(85, 50)
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
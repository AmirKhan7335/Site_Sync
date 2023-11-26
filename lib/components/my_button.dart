import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  final IconData? icon;
  final double containerHeight; // Added containerHeight property

  const MyButton({
    Key? key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
    required this.onTap,
    this.containerHeight = 60.0, // Default height if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: containerHeight, // Use the provided or default height
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: textColor,
                ),
              // Icon
              SizedBox(width: icon != null ? 10.0 : 0),
              // Add space only if icon is present
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              // Text
            ],
          ), // Row
        ), // Center
      ), // Container
    ); // GestureDetector
  }
}

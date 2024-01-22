import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData icon; // Add icon property

  const MyTextField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.icon,
    required TextInputType
        keyboardType, // Required icon parameter in constructor
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          isFocused = hasFocus;
        });
      },
      child: Container(
        height: 58,
        width: 376,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: isFocused ? Colors.yellow : Colors.transparent,
          ),
          color: const Color(0xFF6B8D9F), // Set the background color
        ),
        child: TextFormField(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              
            ),
            filled: true, // Ensure that the fillColor is applied
            fillColor: const Color(
                0xFF6B8D9F), // Set the fillColor to the same background color
            prefixIcon: Icon(
              widget.icon,
              color: Colors.white, // Set icon color to white
            ),
          ),
        ),
      ),
    );
  }
}
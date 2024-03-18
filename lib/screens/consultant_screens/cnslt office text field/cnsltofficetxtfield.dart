import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class MyTextFieldConsultant extends StatefulWidget {
  final String hintText;
  final VoidCallback onTapIcon;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const MyTextFieldConsultant({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.keyboardType,
    required this.onTapIcon,
  });

  @override
  MyTextFieldConsultantState createState() => MyTextFieldConsultantState();
}

class MyTextFieldConsultantState extends State<MyTextFieldConsultant> {
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
        height: 50,
        width: 376,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: isFocused ? Colors.green : Colors.transparent,
          ),
          color: const Color(0xFFF3F3F3),
        ),
        child: TextFormField(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            filled: false,
            fillColor: const Color(0xFFF3F3F3),
            prefixIcon: GestureDetector(
              onTap: widget.onTapIcon,
              child: Icon(
                widget.icon,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

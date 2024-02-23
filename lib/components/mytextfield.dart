import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class MyTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData icon; // Add icon property
  final TextInputType keyboardType;
  MyTextField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.icon,
    required this.
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
          keyboardType: widget.keyboardType,
         // inputFormatters: [ThousandsSeparatorInputFormatter()],
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

//  TextFormField(
//                         readOnly: true,
//                         onTap: () => _selectDate(context),
//                         decoration: InputDecoration(
//                           focusColor: Colors.yellow,
//                           icon: const Icon(Icons.calendar_month),
//                           labelText: 'startDate',
//                           hintText: selectedDate == null
//                               ? 'Select a date'
//                               : '${selectedDate!.toLocal()}'.split(' ')[0],
//                         ),
//                       ),

class MyDateField extends StatefulWidget {
  final String hintText;

  final Function callback;

  // Add icon property

  MyDateField({
    Key? key,
    required this.hintText,
    required this.callback,
    // Required icon parameter in constructor
  }) : super(key: key);

  @override
  MyDateFieldState createState() => MyDateFieldState();
}

class MyDateFieldState extends State<MyDateField> {
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
          readOnly: true,
          onTap: () => widget.callback(context),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.hintText == 'Select a date'
                  ? Colors.grey
                  : widget.hintText == 'End Date'
                      ? Colors.grey
                      : widget.hintText == 'Start Date'
                          ? Colors.grey
                          : Colors.white,
            ),
            filled: true, // Ensure that the fillColor is applied
            fillColor: const Color(
                0xFF6B8D9F), // Set the fillColor to the same background color
            prefixIcon: Icon(
              Icons.calendar_month,
              color: Colors.white, // Set icon color to white
            ),
          ),
        ),
      ),
    );
  }
}

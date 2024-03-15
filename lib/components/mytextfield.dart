import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  bool obscureText;
  final TextEditingController controller;
  final IconData icon; // Add icon property
  final TextInputType keyboardType;
  MyTextField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.icon,
    required this.keyboardType, // Required icon parameter in constructor
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  bool isFocused = false;
  bool obscure = true;
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
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: isFocused ? Colors.green : Colors.transparent,
          ),
          color: const Color(0xFFF3F3F3), // Set the background color
        ),
        child: TextFormField(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          controller: widget.controller,
          obscureText:  widget.hintText == 'Enter your password'||widget.hintText == 'Confirm your password'?obscure:false,
          keyboardType: widget.keyboardType,
          // inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            filled: false, // Ensure that the fillColor is applied
            fillColor: const Color(
                0xFFF3F3F3), // Set the fillColor to the same background color
            prefixIcon: Icon(
              widget.icon,
              color: Colors.grey, // Set icon color to white
            ),
            suffixIcon: widget.hintText == 'Enter your password'||widget.hintText == 'Confirm your password'
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off
                          : Icons.visibility, // Based on obscure state choose the icon
                      color: Colors.grey, // Set icon color to white
                    ),
                  )
                : null,
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
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isFocused ? Colors.green : Colors.transparent,
          ),
          color: const Color(0xFFF3F3F3), // Set the background color
        ),
        child: TextFormField(
          readOnly: true,
          onTap: () => widget.callback(context),
          style: const TextStyle(
            color: Colors.black,
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
                          : Colors.black,
            ),
            filled: false, // Ensure that the fillColor is applied
            fillColor: const Color(
                0xFFF3F3F3), // Set the fillColor to the same background color
            prefixIcon: Icon(
              Icons.calendar_month,
              color: Colors.grey, // Set icon color to white
            ),
          ),
        ),
      ),
    );
  }
}

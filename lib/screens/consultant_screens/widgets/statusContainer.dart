import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatusContainer extends StatefulWidget {
  StatusContainer(
      {required this.icon, required this.count, required this.text, super.key});
  final IconData icon;
  final int count;
  final String text;

  @override
  State<StatusContainer> createState() => _StatusContainserState();
}

class _StatusContainserState extends State<StatusContainer> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 130,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Icon(widget.icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            widget.count.toString(),
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          SizedBox(height: 10),
          Container(
            height: 1.5,
            width: 30,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            widget.text,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

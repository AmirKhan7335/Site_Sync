import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class StatusContainer extends StatefulWidget {
  StatusContainer(
      {required this.icon, required this.count, required this.text, required this.callback, super.key});
  final IconData icon;
  final int count;
  final String text;
  Callback callback;

  @override
  State<StatusContainer> createState() => _StatusContainserState();
}

class _StatusContainserState extends State<StatusContainer> {
  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: widget.callback,
      child: Container(
        height: 130,
        width: 100,
        decoration: BoxDecoration(
          color: Color(0xFF3EED88),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Icon(widget.icon,color: Colors.black, ),
            const SizedBox(height: 10),
            Text(
              widget.count.toString(),
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            SizedBox(height: 10),
            Container(
              height: 1.5,
              width: 30,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            Text(
              widget.text,
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

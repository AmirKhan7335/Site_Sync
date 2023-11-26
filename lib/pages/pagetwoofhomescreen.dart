import 'package:flutter/material.dart';

import '../components/arcpainter.dart';


class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2935),
        // Adjusted color here
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.0, 0.0, 0.0, 0, 255,
                // red channel
                0.0, 0.0, 0.0, 0, 255,
                // green channel
                0.0, 0.0, 0.0, 0, 0,
                // blue channel to minimum
                0.0, 0.0, 0.0, 1, 0,
                // alpha channel
              ]),
              child: Image.asset(
                  'assets/images/budget_icon.png'),
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // Move "Status: On Time" text upwards
                  Transform.translate(
                    offset: const Offset(2, 0),
                    // Adjust the vertical offset as needed
                    child: const Text(
                        "Total Budget:\n105,649,534",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                  Transform.translate(
                    offset: const Offset(2, 7),
                    // Adjust the vertical offset as needed
                    child: const Text(
                        "Received:\n 65,649,534",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(width: 50),
              SizedBox(
                height: 90,
                width: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ellipse with a thin border
                    Container(
                      height: 89,
                      width: 89,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.grey,
                          width: 5,
                        ),
                      ),
                    ),
                    // Inner Ellipse with custom paint
                    SizedBox(
                      height: 126,
                      width: 127,
                      child: CustomPaint(
                        painter: ArcPainter(),
                      ),
                    ),
                    const Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text("75%",
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

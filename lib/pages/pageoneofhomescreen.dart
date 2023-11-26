import 'package:flutter/material.dart';

import '../components/arcpainter.dart';


class PageOne extends StatefulWidget {
  const PageOne({super.key});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 10.0,
          top: 10.0,
          bottom: 10.0,
          right: 10.0),
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
                  'assets/images/progress_image.png'),
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
                    offset: const Offset(2, 2),
                    // Adjust the vertical offset as needed
                    child: const Text("Status: On Time",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                  Transform.translate(
                    offset: const Offset(4, 7),
                    // Adjust the vertical offset as needed
                    child: const Text(
                        "Start Date: 21 May, 2022",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                  Transform.translate(
                    offset: const Offset(6, 12),
                    // Adjust the horizontal offset as needed
                    child: const Text(
                        "End Date: 21 March, 2023",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              SizedBox(
                height: 90, // Adjust the height as needed
                width: 90, // Adjust the width as needed
                child: Stack(
                  alignment: Alignment.centerLeft,
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
                            style:
                            TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
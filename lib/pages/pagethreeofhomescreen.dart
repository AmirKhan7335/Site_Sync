import 'package:flutter/material.dart';



class PageThree extends StatefulWidget {
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 8.0, top: 2.0, bottom: 2.0, right: 0.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2935),
        // Adjusted color here
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          const Center(
              child: Text(
                'Weather',
                style: TextStyle(fontSize: 20),
              )),
          Row(
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ColorFiltered(
                      colorFilter:
                      const ColorFilter.matrix([
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
                          'assets/images/cloud_icon.png'),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(2, 7),
                    // Adjust the vertical offset as needed
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: 'Heavy Rain',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors
                                      .white) // Increased size to 40
                          ),
                          TextSpan(
                              text: '\nTomorrow 11 PM',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Transform.translate(
                offset: const Offset(2, 7),
                // Adjust the vertical offset as needed
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: ' 26°',
                          style: TextStyle(
                              fontSize: 80,
                              color: Colors.white) // Increased size to 40
                      ),
                      TextSpan(
                          text: '\nCurrent Weather',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
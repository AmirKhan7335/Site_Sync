import 'package:flutter/material.dart';
import '../components/arcpainter.dart';

class PageOne extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final int activityProgress;
  final String title;

  const PageOne(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.activityProgress,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 10.0, bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          children: [
            // SizedBox(
            //   width: 50,
            //   height: 50,
            //   child: ColorFiltered(
            //     colorFilter: const ColorFilter.mode(
            //       Colors.green,
            //       BlendMode.saturation,
            //     ),
            //     child: Image.asset('assets/images/progress_image.png'),
            //   ),
            // ),
            // const SizedBox(height: 5),

            // const SizedBox(height: 5),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Start : $startDate",
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "End : $endDate",
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const SizedBox(height: 60),
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Outer Ellipse with a thin border
                          Container(
                            //89
                            height: 160,
                            width: 160,
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
                          Container(
                            color: Colors.transparent,
                            height:160,
                            // 126,
                            width: 160,

                            //127,
                            child: CustomPaint(
                              painter: ArcPainter(
                                progress: activityProgress.toDouble(),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                "${activityProgress.toInt()}%",
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

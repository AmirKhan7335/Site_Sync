import 'package:flutter/material.dart';
import '../components/arcpainter.dart';

class PageOne extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final double activityProgress;

  const PageOne({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.activityProgress,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2935),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.yellow,
                  BlendMode.saturation,
                ),
                child: Image.asset('assets/images/progress_image.png'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Status: On Time",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "Start Date: $startDate",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "End Date: $endDate",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SizedBox(
                  height: 90,
                  width: 90,
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
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

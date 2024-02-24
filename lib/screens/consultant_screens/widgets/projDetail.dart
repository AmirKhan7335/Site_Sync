import 'package:amir_khan1/components/arcpainter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProjectDetail extends StatefulWidget {
  ProjectDetail({required this.projectDataList, super.key});

  List projectDataList;

  @override
  State<ProjectDetail> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<ProjectDetail> {
  calculateProgress(DateTime startDate, DateTime endDate) {
    try {
      final now = DateTime.now();
      final totalDuration = endDate.difference(startDate).inSeconds;
      final elapsedDuration = now.difference(startDate).inSeconds;

      if (elapsedDuration < 0) {
        return 0.0;
      } else if (endDate.isBefore(startDate)) {
        return 0.0;
      } else if (elapsedDuration >= totalDuration) {
        return 100.0;
      } else {
        final progress = elapsedDuration / totalDuration * 100.0;
        return progress.roundToDouble();
      }

      // Calculate progress as a perce
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Detail'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.projectDataList[0]}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 32, left: 32),
              child: Container(
                height: 1.5,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                              progress: calculateProgress(
                                  widget.projectDataList[1].toDate(),
                                  widget.projectDataList[2].toDate()),
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
                              "${calculateProgress(
                                  widget.projectDataList[1].toDate(),
                                  widget.projectDataList[2].toDate())} %",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Title:  ',
                          ),
                          Text(
                            '${widget.projectDataList[0]}',
                            softWrap: true,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Total Cost:  ',
                          ),
                          Text(
                            widget.projectDataList[3],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Retention Money :  ',
                          ),
                          Text(
                            '${widget.projectDataList[4]}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Funding :  ',
                          ),
                          Text(
                            '${widget.projectDataList[5]}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Location :  ',
                          ),
                          Text(
                            '${widget.projectDataList[6]}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Start Date:  ',
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(widget.projectDataList[1].toDate())}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'End Date:  ',
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(widget.projectDataList[2].toDate())}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

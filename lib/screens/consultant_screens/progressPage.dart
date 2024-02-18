import 'package:amir_khan1/screens/consultant_screens/ConsultantSchedule.dart';
import 'package:amir_khan1/screens/consultant_screens/widgets/progressWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ScheduleProjectsState();
}

class _ScheduleProjectsState extends State<ProgressPage> {
  final user = FirebaseAuth.instance.currentUser;
     calculateProgress(DateTime startDate, DateTime endDate) {
  try{if (endDate.isBefore(startDate)) {
    throw ArgumentError('End date cannot be before start date.');
  }
  final now = DateTime.now();
  final totalDuration = endDate.difference(startDate).inSeconds;
  final elapsedDuration = now.difference(startDate).inSeconds;

  if (elapsedDuration < 0) {
    return 0.0;
  } else if (elapsedDuration >= totalDuration) {
    return 100.0;
  }

  // Calculate progress as a percentage
  final progress = elapsedDuration / totalDuration * 100.0;
  return progress.roundToDouble();}catch(e){Get.snackbar('Error', e.toString());}
}

  Future<List> fetchOngoingProjects() async {
//..
    try {
      DateTime currentDate = DateTime.now();

      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
          .where('endDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
          .get();
      final userData = collectionData.docs.map(
        (doc) {
          return [
            doc['title'],
            doc['budget'],
            doc['funding'],
            doc['startDate'],
            doc['endDate'],
            doc['location'],
            doc['creationDate']
          ];
        },
      ).toList();

      return userData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  Future<List> fetchCompletedProjects() async {
//..
    try {
      DateTime currentDate = DateTime.now();

      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
          .where('endDate', isLessThan: Timestamp.fromDate(currentDate))
          .get();
      final userData = collectionData.docs.map(
        (doc) {
          return [
            doc['title'],
            doc['budget'],
            doc['funding'],
            doc['startDate'],
            doc['endDate'],
            doc['location'],
            doc['creationDate'],
            doc.id
          ];
        },
      ).toList();

      return userData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  Widget Ongoing() {
    return FutureBuilder(
        future: fetchOngoingProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            final data = snapshot.data;

            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () => {},
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  radius: 30,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data[index][0]}'),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 160,
                                child: LinearProgressIndicator(
                                  minHeight: 7,
                                  borderRadius: BorderRadius.circular(5),
                                  value: calculateProgress(
                                          data[index][3].toDate(),
                                          data[index][4].toDate()) /
                                      100,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.yellow),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('${ calculateProgress(data[index][3].toDate(), data[index][4].toDate())}%'),
                            ],
                          )
                        ],
                      ),
                    )),
              ),
            );
          } else {
            return Center(
              child: Text('No Ongoing Projects'),
            );
          }
        });
  }

  Widget Completed() {
    return FutureBuilder(
        future: fetchCompletedProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () {},
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  radius: 30,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data[index][0]}'),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 160,
                                child: LinearProgressIndicator(
                                  minHeight: 7,
                                  borderRadius: BorderRadius.circular(5),
                                  value: 1,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.yellow),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('100%'),
                            ],
                          )
                        ],
                      ),
                    )),
              ),
            );
          } else {
            return Center(
              child: Text('No Completed Projects'),
            );
          }
        });
  }

  bool isOngoing = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isOngoing ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isOngoing == false) {
                          setState(() {
                            isOngoing = true;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Ongoing',
                          style: TextStyle(
                            fontSize: 20,
                            color: isOngoing ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: !isOngoing ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isOngoing == true) {
                          setState(() {
                            isOngoing = false;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 20,
                            color: !isOngoing ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(right: 8, left: 8, bottom: 0),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.68,
                  child: isOngoing ? Ongoing() : Completed(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

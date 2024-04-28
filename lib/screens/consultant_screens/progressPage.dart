  // import 'package:amir_khan1/models/activity.dart';
  // import 'package:amir_khan1/screens/consultant_screens/cnsltSchedule.dart';
  // import 'package:amir_khan1/screens/consultant_screens/widgets/progressWidgets.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  // import 'package:excel/excel.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  // import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

import '../../controllers/progressTrackingController.dart';
  // import 'package:intl/intl.dart';

  class ProgressPage extends StatefulWidget {
    const ProgressPage({super.key});

    @override
    State<ProgressPage> createState() => _ScheduleProjectsState();
  }

  class _ScheduleProjectsState extends State<ProgressPage> {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, double> projectProgress = {};



    Future<List<dynamic>> fetchOngoingProjects() async {
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
            final overallPercentExists = doc.data().containsKey('overallPercent');
            return [
              doc['title'],
              doc['budget'],
              doc['funding'],
              doc['startDate'],
              doc['endDate'],
              doc['location'],
              doc['creationDate'],
              overallPercentExists ? doc['overallPercent'] : 0,
              doc.id
            ];
          },
        ).toList();


        return userData;
      } catch (e) {
        print(e.toString());
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
        return [];
      }
    }
    Future<List<dynamic>> fetchAllProjects() async {
      try {
        final collectionData = await FirebaseFirestore.instance
            .collection('Projects')
            .where('email', isEqualTo: user!.email)
            .get();

        final allProjects = collectionData.docs.map((doc) {
          final overallPercentExists = doc.data().containsKey('overallPercent');
          return [
            doc['title'],
            doc['budget'],
            doc['funding'],
            doc['startDate'],
            doc['endDate'],
            doc['location'],
            doc['creationDate'],
            overallPercentExists ? doc['overallPercent'] : 0,
            doc.id
          ];
        }).toList();

        return allProjects;
      } catch (e) {
        print(e.toString());
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
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
            final overallPercentExists = doc.data().containsKey('overallPercent');
            return [
              doc['title'],
              doc['budget'],
              doc['funding'],
              doc['startDate'],
              doc['endDate'],
              doc['location'],
              doc['creationDate'],
              overallPercentExists ? doc['overallPercent'] : 0,
              doc.id
            ];
          },
        ).toList();

        return userData;
  //..
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
        return [];
      }
    }

    Widget Ongoing(List<dynamic> projectsData) {
      return ListView.builder(
        itemCount: projectsData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
            child: Card(
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                onTap: () => {},
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
                  ),
                ),
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${projectsData[index][0]}',
                            style: const TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(5),
                                value: projectsData[index][7]/100,
                                backgroundColor: Colors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${projectsData[index][7]}%',
                                style: const TextStyle(color: Colors.black)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }


    Widget Completed(List<dynamic> projectsData) {
      return ListView.builder(
        itemCount: projectsData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
            child: Card(
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                onTap: () => {},
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
                  ),
                ),
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${projectsData[index][0]}',
                            style: const TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(5),
                                value: projectsData[index][7] / 100, // Use correct index
                                backgroundColor: Colors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${projectsData[index][7]}%', // Use correct index
                                style: const TextStyle(color: Colors.black)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    bool isOngoing = true;
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          color: const Color(0xFFFBFBFB),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isOngoing ? const Color(0xFF3EED88) : Colors.white,
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
                            child: const Center(
                              child: Text(
                                'Ongoing',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black ,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            color: !isOngoing ? const Color(0xFF3EED88) : Colors.white,
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
                            child: const Center(
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8, bottom: 0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: FutureBuilder(
                        future: fetchAllProjects(),
                        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()));
                          } else {
                            final allProjects = snapshot.data!;

                            final ongoingProjects = allProjects.where((project) => project[7] < 100).toList();
                            final completedProjects = allProjects.where((project) => project[7] == 100).toList();
                            print('Ongoing Projects: $ongoingProjects');
                            print('Completed Projects: $completedProjects');

                            return isOngoing
                                ? Ongoing(ongoingProjects)
                                : Completed(completedProjects);
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  import 'package:amir_khan1/controllers/progressTrackingController.dart';
  // import 'package:amir_khan1/models/activity.dart';
  // import 'package:amir_khan1/screens/consultant_screens/cnsltSchedule.dart';
  // import 'package:amir_khan1/screens/consultant_screens/widgets/progressWidgets.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  // import 'package:excel/excel.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  // import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  // import 'package:intl/intl.dart';

  class ProgressPage extends StatefulWidget {
    const ProgressPage({super.key});

    @override
    State<ProgressPage> createState() => _ScheduleProjectsState();
  }

  class _ScheduleProjectsState extends State<ProgressPage> {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, double> projectProgress = {};

    @override
    void initState() {
      super.initState();
      fetchProgress(); // Call fetchProgress when the widget initializes
    }

    Future<void> fetchProgress() async {
      try {
        final projectsSnapshot = await FirebaseFirestore.instance.collection('Projects').get();

        for (var projectDoc in projectsSnapshot.docs) {
          final projectId = projectDoc.id;
          final projectData = projectDoc.data();
          final overallPercent = projectData.containsKey('overallPercent')
              ? (projectData['overallPercent'] as num).toDouble()
              : 0.0;
          projectProgress[projectId] = overallPercent;
          print("Project ID: $projectId, Progress: $overallPercent");
        }

        setState(() {}); // Update the state after fetching progress values
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }



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

    Widget Ongoing(List<dynamic> projectsData) {
      return ListView.builder(
        itemCount: projectsData.length,
        itemBuilder: (context, index) {
          final projectId = projectsData[index][7];
          final progress = projectProgress[projectId] ?? 0.0;
          return Card(
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
                      fontWeight: FontWeight.bold, color: Colors.black),
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
                              value: progress/100,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('$progress%',
                              style: const TextStyle(color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }




    Widget Completed() {
      return FutureBuilder(
          future: fetchCompletedProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.white,
                  elevation: 5,
                  child: ListTile(
                    onTap: () {},
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data[index][0]}',style: const TextStyle(color: Colors.black)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: LinearProgressIndicator(
                                      minHeight: 7,
                                      borderRadius: BorderRadius.circular(5),
                                      value: 1,
                                      backgroundColor: Colors.white,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('100%',style: TextStyle(color: Colors.black)),
                                ],
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              );
            } else {
              return const Center(
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.0, bottom: 8.0, right: 8.0, left: 8.0),
                    child: Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
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
                        color: isOngoing ? Colors.green : Colors.grey,
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
                    const SizedBox(width: 10),
                    Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        color: !isOngoing ? Colors.green : Colors.grey,
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
                      future: fetchOngoingProjects(),
                      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else {
                          final projectsData = snapshot.data!;
                          return isOngoing ? Ongoing(projectsData) : Completed();
                        }
                      },
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      );
    }
  }

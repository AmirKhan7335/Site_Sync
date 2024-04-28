import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContrProgressPage extends StatefulWidget {
  const ContrProgressPage({super.key});

  @override
  State<ContrProgressPage> createState() => _ScheduleProjectsState();
}

class _ScheduleProjectsState extends State<ContrProgressPage> {
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future<List> fetchOngoingProjects() async {
//..
    try {
      DateTime currentDate = DateTime.now();
// Contractor Contributions..--..--..--..--..--..--..--..--..

      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();

      final contrProjId = contractorQuery.docs.map((e) => e['projectId']);

      final contrProj = await FirebaseFirestore.instance
          .collection('Projects')
          .where('overallPercent', isLessThan: 100)
          .get();

      final contrResult = await contrProj.docs
          .where((doc) => contrProjId.contains(doc.id))
          .map((doc) {
        final overallPercentExists = doc.data().containsKey('overallPercent');
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location'],
          doc['creationDate'],
          doc.id,
          'enrolledByContr',
          overallPercentExists ? doc['overallPercent'] : 0,
        ];
      }).toList();
//===========================================================

      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
          .where('overallPercent', isLessThan: 100)
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
            doc.id,
            'createdByContr',
            overallPercentExists ? doc['overallPercent'] : 0,
          ];
        },
      ).toList();

      userData.addAll(contrResult);
      return userData;
//..
    } catch (e) {
      print("Error: $e");
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  Future<List<dynamic>> fetchAllProjects() async {
    try {
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();

      final contrProjId = contractorQuery.docs.map((e) => e['projectId']);

      final contrProj = await FirebaseFirestore.instance
          .collection('Projects')
          .get();

      final contrResult = await contrProj.docs
          .where((doc) => contrProjId.contains(doc.id))
          .map((doc) {
        final overallPercentExists = doc.data().containsKey('overallPercent');
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location'],
          doc['creationDate'],
          doc.id,
          'enrolledByContr',
          overallPercentExists ? doc['overallPercent'] : 0,
        ];
      }).toList();
//===========================================================

      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
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
            doc.id,
            'createdByContr',
            overallPercentExists ? doc['overallPercent'] : 0,
          ];
        },
      ).toList();

      userData.addAll(contrResult);
      return userData;
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

// Contractor Contributions..--..--..--..--..--..--..--..--..

      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();

      final contrProjId = contractorQuery.docs.map((e) => e['projectId']);

      final contrProj = await FirebaseFirestore.instance
          .collection('Projects')
          .where('overallPercent', isEqualTo: 100)
          .get();

      final contrResult = await contrProj.docs
          .where((doc) => contrProjId.contains(doc.id))
          .map((doc) {
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
        ];
      }).toList();
//===========================================================
      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
          .where('overallPercent', isEqualTo: 100)
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
      userData.addAll(contrResult);
      return userData;
//..
    } catch (e) {
      print("Error1: $e");
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  Widget Ongoing() {

    return FutureBuilder(
        future: fetchOngoingProjects(),
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
                itemBuilder: (context, index) {
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
                              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      title: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left:8.0, bottom: 8.0, top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data[index][0]}',
                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: LinearProgressIndicator(
                                        minHeight: 7,
                                        borderRadius: BorderRadius.circular(5),
                                        value:  data[index][9]/100,
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${data[index][9]}%',
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ),
                  );
                });
          } else {
            return const Center(
              child: Text(
                'No Ongoing Projects',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
        });
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
                elevation: 5,
                color: Colors.white,
                child: ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:8.0, bottom: 8.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data[index][0]}',
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: LinearProgressIndicator(
                                    minHeight: 7,
                                    borderRadius: BorderRadius.circular(5),
                                    value:data[index][7]/100,
                                    backgroundColor: Colors.white,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('${data[index][7]}%',
                                  style: TextStyle(color: Colors.black),
                                ),
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
              child: Text(
                'No Completed Projects',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
        });
  }

  bool isOngoing = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Progress',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Use the back icon here
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to previous screen
          },
        ),
      ),
      body: SafeArea(
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
                        color: isOngoing ? const Color(0xff3EED88) : Colors.white,
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
                              color: Colors.black,
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
                        color: !isOngoing ? const Color(0xff3EED88) : Colors.white,
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
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 0),
              child: SingleChildScrollView(
                child: SizedBox(
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

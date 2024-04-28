import 'package:amir_khan1/screens/contractor_screen/tabs/contrSchedule/schedDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContrScheduleProjects extends StatefulWidget {
  const ContrScheduleProjects({super.key});

  @override
  State<ContrScheduleProjects> createState() => _ScheduleProjectsState();
}

class _ScheduleProjectsState extends State<ContrScheduleProjects> {
  final user = FirebaseAuth.instance.currentUser;

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
          // .where(FieldPath.documentId, whereIn: contrProjId)
          .where('endDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
          .get();

      final contrResult = await contrProj.docs
          .where((doc) => contrProjId.contains(doc.id))
          .map((doc) {
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location'],
          doc['creationDate'],
          doc.id,
          'consultant'
        ];
      }).toList();
//===========================================================
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
            doc.id,
            'contractor'
          ];
        },
      ).toList();

      userData.addAll(contrResult);
      return userData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  // calculateProgress(DateTime startDate, DateTime endDate) {
  //   try {
  //     if (endDate.isBefore(startDate)) {
  //       throw ArgumentError('End date cannot be before start date.');
  //     }
  //     final now = DateTime.now();
  //     final totalDuration = endDate.difference(startDate).inSeconds;
  //     final elapsedDuration = now.difference(startDate).inSeconds;
  //
  //     if (elapsedDuration < 0) {
  //       return 0.0;
  //     } else if (elapsedDuration >= totalDuration) {
  //       return 100.0;
  //     }
  //
  //     // Calculate progress as a percentage
  //     final progress = elapsedDuration / totalDuration * 100.0;
  //     return progress.roundToDouble();
  //   } catch (e) {
  //     Get.snackbar('Error', e.toString());
  //   }
  // }

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
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5, // Add elevation for the card
                  color: Colors.white, // Set card color to white
                  child: ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContrScheduleDetail(
                                projId: data[index][7],
                                title: data[index][0],
                                projType: data[index][8]))),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                    title: Padding(
                      // Add padding around the title content
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${data[index][0]}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black)),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: Text('No Ongoing Projects'),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Schedule',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Container(
          //         width: Get.width * 0.9,
          //         height: 50,
          //         decoration: BoxDecoration(
          //           color: Colors.green,
          //           borderRadius: BorderRadius.circular(5),
          //         ),
          //         child: InkWell(
          //           onTap: () {},
          //           child: const Center(
          //             child: Text(
          //               'Ongoing',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 color: Colors.black,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 10),
          //     ],
          //   ),
          // ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.68,
                child: Ongoing(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

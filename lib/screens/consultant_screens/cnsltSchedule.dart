import 'package:amir_khan1/screens/consultant_screens/activityGallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConsultantSchedule extends StatefulWidget {
  ConsultantSchedule({required this.projId, required this.title, super.key});
  String projId;
  String title;
  @override
  State<ConsultantSchedule> createState() => _ConsultantScheduleState();
}

class _ConsultantScheduleState extends State<ConsultantSchedule> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<dynamic> getActivities() async {
    try {
      final activitiesQuery = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: widget.projId)
          .get();
      final engEmail = await activitiesQuery.docs.first.id;
      // data.add(engEmail);
      final activitiesData = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('activities')
          .orderBy('order')
          .get();

      List dataList = await activitiesData.docs.map((doc) {
        return [
          doc['order'],
          doc['name'],
          doc['image'],
          doc['startDate'],
          doc['finishDate'],
          doc.id
        ];
      }).toList();
      return [engEmail, dataList];
    } catch (e) {
      print(e);
      Get.snackbar('Error', '${e}');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_outlined,color: Colors.black,)),
                  const Text(
                    'Activities',
                    style: TextStyle(fontSize: 20,color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.title}',
                    style: const TextStyle(fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 32, left: 32),
              child: Container(
                height: 1.5,
                color: Colors.grey,
              ),
            ),
            FutureBuilder(
                future: getActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        CircularProgressIndicator(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Text(snapshot.error.toString()),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final engEmail = snapshot.data[0];

                    final data = snapshot.data[1];

                    return Container(
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, right: 24, top: 0, bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ActivityGallery(
                                                    engEmail: engEmail,
                                                    activityId: data[index]
                                                        [5]))),
                                    title: Text(
                                      '${data[index][1]}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        '${DateFormat('dd/MM/yyyy').format(data[index][3].toDate())} - ${DateFormat('dd/MM/yyyy').format(data[index][4].toDate())}',
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                              );
                            }),
                      ),
                    );
                  } else {
                    return const Center(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Text('No Activities Scheduled'),
                      ],
                    ));
                  }
                }),
          ],
        ),
      ),
    );
  }
}

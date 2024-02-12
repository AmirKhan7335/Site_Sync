import 'package:amir_khan1/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityGallery extends StatefulWidget {
  const ActivityGallery({super.key});

  @override
  State<ActivityGallery> createState() => _ActivityGalleryState();
}

class _ActivityGalleryState extends State<ActivityGallery> {
  @override
  void initState() {
    super.initState();
  }

  var email = FirebaseAuth.instance.currentUser!.email;
  Future fetchPendingActivities() async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc('mhabib.bese21seecs@seecs.edu.pk')
          .collection('activities')
          .where('imgApproved', isEqualTo: false) // Sort by order
          .get();
      final tempActivities =
          activitiesSnapshot.docs.map((doc) => doc.data()).toList();

      return tempActivities;
    } catch (e) {
      Get.snackbar('Error', '${e}');
    }
  }

  Future fetchApprovedActivities() async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc('mhabib.bese21seecs@seecs.edu.pk')
          .collection('activities')
          .where('imgApproved', isEqualTo: true) // Sort by order
          .get();
      final tempActivities =
          activitiesSnapshot.docs.map((doc) => doc.data()).toList();

      return tempActivities;
    } catch (e) {
      Get.snackbar('Error', '${e}');
    }
  }

  Future<void> approvePicture(
    id,
  ) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('engineers')
        .doc('mhabib.bese21seecs@seecs.edu.pk')
        .collection('activities')
        .doc(id)
        .update({'imgApproved': true});
    Get.snackbar('Approved', 'Image Approved');
    Navigator.pop(context);
  }

  bool isPending = true;
  @override
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
                    icon: Icon(Icons.arrow_back_ios_outlined)),
                Text(
                  'Concreting',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {}, icon: Icon(Icons.add_box_outlined)),
              ],
            ),
          ),
          SizedBox(
            height: 10,
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
                    color: isPending ? Colors.yellow : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isPending == false) {
                        setState(() {
                          isPending = true;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 20,
                          color: isPending ? Colors.black : Colors.white,
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
                    color: !isPending ? Colors.yellow : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isPending == true) {
                        setState(() {
                          isPending = false;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Approved',
                        style: TextStyle(
                          fontSize: 20,
                          color: !isPending ? Colors.black : Colors.white,
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
          isPending
              ? FutureBuilder(
                  future: fetchPendingActivities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 500,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 300,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.brown),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                        snapshot.data![index]['image']),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: MyButton(
                                        text: 'Approve',
                                        bgColor: Colors.yellow,
                                        textColor: Colors.black,
                                        icon: Icons.cloud_done_outlined,
                                        onTap: () {
                                          approvePicture(
                                              snapshot.data[index]['id']);
                                        }),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(child: Text('No Images Found'));
                    }
                  })
              : FutureBuilder(
                  future: fetchApprovedActivities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 32.0, left: 32),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    2, // Number of columns in the grid
                                crossAxisSpacing:
                                    16.0, // Spacing between columns
                                mainAxisSpacing: 16.0, // Spacing between rows
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.brown),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                      snapshot.data![index]['image']),
                                );
                              }),
                        ),
                      );
                    } else {
                      return Center(child: Text('No Images Found'));
                    }
                  }),
        ],
      )),
    );
  }
}

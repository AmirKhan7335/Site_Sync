import 'package:amir_khan1/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityGallery extends StatefulWidget {
  ActivityGallery(
      {required this.engEmail,
      required this.activityId,
      required this.activityName,
      super.key});

  String engEmail;
  String activityId;
  String activityName;

  @override
  State<ActivityGallery> createState() => _ActivityGalleryState();
}

class _ActivityGalleryState extends State<ActivityGallery> {
  @override
  void initState() {
    super.initState();
  }

  var consultantEmail = FirebaseAuth.instance.currentUser!.email;

  Future fetchPendingActivities(engEmail, activityId) async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('activities')
          .doc(activityId) // Sort by order
          .get();
      List tempActivities = activitiesSnapshot.data()!['image'];
      return tempActivities;
    } catch (e) {
      Get.snackbar('Error', '$e', backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future fetchApprovedActivities(engEmail, activityId) async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('activities')
          .doc(activityId) // Sort by order
          .get();
      List tempActivities = activitiesSnapshot.data()!['approvedImage'];
      return tempActivities;
    } catch (e) {
      // print("Error 11 $e");
      // Get.snackbar('Error11', '$e');
    }
  }

  Future<void> approvePicture(id, engEmail, imgList) async {
    try {
      var instance = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('activities')
          .doc(id);
      for (String i in imgList) {
        await instance.update({
          'approvedImage': FieldValue.arrayUnion([i])
        });
      }
      await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('activities')
          .doc(id)
          .update({'image': []});
      Get.snackbar('Approved', 'Images Approved', backgroundColor: Colors.white, colorText: Colors.black);
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
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
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.black,
                    )),
                const Expanded(child: SizedBox()),
                Text(
                  widget.activityName,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 30),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
                      color: isPending ? const Color(0xff3EED88) : Colors.white,
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
                      child: const Center(
                        child: Text(
                          'Pending',
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
                      color:
                          !isPending ? const Color(0xff3EED88) : Colors.white,
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
                      child: const Center(
                        child: Text(
                          'Approved',
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
          isPending
              ? SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height *
                        0.6, // Set a finite height constraint
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: fetchPendingActivities(
                              widget.engEmail, widget.activityId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.blue));
                            } else if (snapshot.hasData) {
                              return Column(
                                children: [
                                  if (snapshot.data!.length != 0)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 300,
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) =>
                                              Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Scaffold(
                                                        backgroundColor:
                                                            Colors.white,
                                                        body: Center(
                                                          child: Image.network(
                                                              snapshot.data![
                                                                  index]),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    height: 300,
                                                    width: 300,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.network(
                                                        snapshot.data![index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (snapshot.data!.length != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 64.0, left: 64.0, top: 32),
                                      child: MyButton(
                                        text: 'Approve',
                                        bgColor: const Color(0xff3EED88),
                                        textColor: Colors.black,
                                        icon: Icons.cloud_done_outlined,
                                        onTap: () {
                                          approvePicture(widget.activityId,
                                              widget.engEmail, snapshot.data);
                                        },
                                      ),
                                    ),
                                  if (snapshot.data!.length == 0)
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                        ),
                                        const Center(
                                          child: Text(
                                            'No Images Found',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                  ),
                                  const Center(
                                    child: Text(
                                      'No Images Found',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: FutureBuilder(
                      future: fetchApprovedActivities(
                          widget.engEmail, widget.activityId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue));
                        } else if (snapshot.hasData) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 32.0, left: 32),
                            child: SingleChildScrollView(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2, // Number of columns in the grid
                                      crossAxisSpacing:
                                          16.0, // Spacing between columns
                                      mainAxisSpacing:
                                          16.0, // Spacing between rows
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                    backgroundColor:
                                                        Colors.white,
                                                    appBar: AppBar(
                                                      title: Text(
                                                        widget.activityName,
                                                        style: const TextStyle(
                                                            color: Colors.black),
                                                      ),
                                                      iconTheme:
                                                          const IconThemeData(
                                                              color: Colors.black),
                                                      backgroundColor:
                                                          Colors.white,
                                                      centerTitle: true,
                                                    ),
                                                    body: Center(
                                                        child: Image.network(
                                                            snapshot.data![
                                                                index]))))),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              snapshot.data![index],
                                              fit: BoxFit
                                                  .cover, // Adjusts image to cover full container size
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              const Center(
                                  child: Text('No Images Found',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black))),
                            ],
                          );
                        }
                      }),
                ),
        ],
      )),
    );
  }
}

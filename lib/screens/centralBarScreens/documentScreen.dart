import 'dart:io';
import 'package:amir_khan1/controllers/centralTabController.dart';
import 'package:amir_khan1/screens/centralBarScreens/summaryscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../notifications/notificationCases.dart';
import 'dailyprogressreport.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({required this.isClient, super.key});

  final bool isClient;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final controller = Get.put(CentralTabController());
  int totalDayCount = 0;

  uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'pdf', 'mpp'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Upload the file to Firebase Storage
      try {
        await uploadFileToFirebase(file);

        controller.isDocumentLoading.value = false;
        Get.snackbar('Success', 'File Uploaded', backgroundColor: Colors.white, colorText: Colors.black);
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      }
    }
  }

  projectId() async {
    // For Engineer
    //

    try {
      final currentUserEmail = await FirebaseAuth.instance.currentUser!.email;
      final query = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(currentUserEmail)
          .get();
      final projectId = query.data()!['projectId'];
      return projectId;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  projectId1() async {
    // For Engineer
    //

    try {
      final currentUserEmail = await FirebaseAuth.instance.currentUser!.email;
      final query = await FirebaseFirestore.instance
          .collection('clients')
          .doc(currentUserEmail)
          .get();
      final projectId = query.data()!['projectId'];
      return projectId;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future<void> uploadFileToFirebase(File file) async {
    try {
      controller.isDocumentLoading.value = true;
      String fileName = file.path.split('/').last;

      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);
      String downloadUrl = await ref.getDownloadURL();
      final projId = await projectId();
      FirebaseFirestore.instance.collection('Projects').doc(projId).update({
        'documents': FieldValue.arrayUnion([
          [
            fileName,
            downloadUrl,
          ].toString()
        ]),
      });
      //---------Send Notification-----------
      NotificationCases().docUploadedByEngineerNotification('Document');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    // Use downloadUrl as needed, e.g., save to Firestore database
    // print('File uploaded to: $downloadUrl');
  }

  Future<List> getDocuments() async {
    final projId = widget.isClient ? await projectId1() : await projectId();
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projId)
        .get();
    return query.data()!['documents'];
  }

  getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory(tempDir!.path);
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  Future<void> _checkFileAndOpen(fileUrl, fileName) async {
    try {
      var storePath = await getPath();
      bool isExist = await File('$storePath/$fileName').exists();
      if (isExist) {
        OpenFile.open('$storePath/$fileName');
      } else {
        var filePath = '$storePath/$fileName';
        // setState(() {
        //   dowloading = true;
        //   progress = 0;
        // });

        await Dio().download(
          fileUrl,
          filePath,
          onReceiveProgress: (count, total) {
            // setState(() {
            //   progress = (count / total);
            // });
          },
        );
        OpenFile.open(filePath);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    calculateDayNo();
  }

  Future<int> calculateDayNo() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var role = (await firestore.collection('users').doc(email).get()).data()!['role'];
    try {
      role == 'Engineer'
          ? totalDayCount = await _calculateForNonClient()
          : totalDayCount = await _calculateForClient();
    } catch (e) {
      Get.snackbar('Error', '$e', backgroundColor: Colors.white, colorText: Colors.black);
    }
    return totalDayCount;
  }

  Future<int> _calculateForClient() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var projId = (await firestore.collection('clients').doc(email).get()).data()!['projectId'];
    final engineerQuerySnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .where('projectId',isEqualTo: projId)// Sort by order
        .get();
    final engineerDoc = engineerQuerySnapshot.docs.first;
    var engEmail = engineerDoc.id;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(engEmail)
        .collection('activities')
        .orderBy('order') // Sort by order
        .get();

    // Get yesterday's date
    DateTime currentDate = DateTime.now();
    int totalDaysCount = 0;

    for (var doc in activitiesSnapshot.docs) {
      DateTime startDate = doc['startDate'].toDate();
      DateTime finishDate = doc['finishDate'].toDate();

      // Ensure that the activity's finish date is on or before today's date
      if (finishDate.isBefore(currentDate) ||
          finishDate.isAtSameMomentAs(currentDate)) {
        // Calculate the total days from start date till finish date excluding Sundays
        int totalDays = finishDate.difference(startDate).inDays + 1;
        print(
            "start date = $startDate, finish date = $finishDate, total days = $totalDays, current date = $currentDate");
        int dayCount = totalDays;

        // Add the calculated day count to the total
        totalDaysCount += dayCount;
      }

      // Ensure that the activity's start date is the same as today's date
      if (startDate.year == currentDate.year &&
          startDate.month == currentDate.month &&
          startDate.day == currentDate.day) {
        totalDaysCount += 1; // Increment by 1 if start date is today
      }
    }
    totalDayCount = totalDaysCount;

    return totalDayCount;
  }

  Future<int> _calculateForNonClient() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .orderBy('order') // Sort by order
        .get();

    // Get yesterday's date
    DateTime currentDate = DateTime.now();
    int totalDaysCount = 0;

    for (var doc in activitiesSnapshot.docs) {
      DateTime startDate = doc['startDate'].toDate();
      DateTime finishDate = doc['finishDate'].toDate();

      // Ensure that the activity's finish date is on or before today's date
      if (finishDate.isBefore(currentDate) ||
          finishDate.isAtSameMomentAs(currentDate)) {
        // Calculate the total days from start date till finish date excluding Sundays
        int totalDays = finishDate.difference(startDate).inDays + 1;
        print(
            "start date = $startDate, finish date = $finishDate, total days = $totalDays, current date = $currentDate");
        int dayCount = totalDays;

        // Add the calculated day count to the total
        totalDaysCount += dayCount;
      }

      // Ensure that the activity's start date is the same as today's date
      if (startDate.year == currentDate.year &&
          startDate.month == currentDate.month &&
          startDate.day == currentDate.day) {
        totalDaysCount += 1; // Increment by 1 if start date is today
      }
    }
    totalDayCount = totalDaysCount;

    return totalDayCount;
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones(); // Load time zone database
  }

  @override
  Widget build(BuildContext context) {
    final control = Get.put(CentralTabController());
    final pakistanTimeZone = tz.getLocation('Asia/Karachi');
    final currentDateTimeInPakistan = tz.TZDateTime.now(pakistanTimeZone);
    final String monthYear = DateFormat('MMMM yyyy').format(currentDateTimeInPakistan);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const Expanded(child: SizedBox()),
            const Text('Documents', style: TextStyle(color: Colors.black)),
            const Expanded(child: SizedBox()),
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                )),
          ],
        ),
        backgroundColor: const Color(0xFF42F98F),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,// Adjust height as needed
            color: const Color(0xFF42F98F),
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        monthYear, // Replace with dynamic date
                        style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        "Day ${totalDayCount.toString()}", // Replace with dynamic day number
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40,),
                  Image.asset('assets/images/box with documents.png', height: 150, width: 150),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16), // Add spacing
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: widget.isClient ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SummaryScreen()),
                    );
                  },
                  child: Column( // Removed Card widget
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Image.asset('assets/images/Vector2.png', height: 30, width: 30),
                      const SizedBox(height: 10),
                      const Center(child: Text('Record\n', style: TextStyle(fontSize: 12, color: Colors.black))),
                    ],
                  ),
                ),
              ],
            ):
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const DailyProgressReportScreen()),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10,),
                          Image.asset('assets/images/Vector 1.png', height: 30, width: 30),
                          const SizedBox(height: 10,),
                          const Center(child: Text('Progress\n  Report', style: TextStyle(fontSize: 12, color: Colors.black))),
                        ],
                      ),
                    )
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SummaryScreen()),
                    );
                  },
                  child: Card(
                      color: Colors.white,
                      elevation: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Image.asset('assets/images/Vector2.png', height: 30, width: 30),
                            const SizedBox(height: 10,),
                            const Center(child: Text('Record\n', style: TextStyle(fontSize: 12, color: Colors.black))),
                          ],
                        ),
                      )
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    uploadFile();
                    control.isDocumentLoading.value = false;
                  },
                  child: Card(
                      color: Colors.white,
                      elevation: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Image.asset('assets/images/Vector 3.png', height: 30, width: 30),
                            const SizedBox(height: 10,),
                            const Center(child: Text('Upload\n', style: TextStyle(fontSize: 12, color: Colors.black))),
                          ],
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // Add spacing
          Expanded(
              child: Obx(
                  () => Stack(
                    children: [
                      FutureBuilder(
                        future: getDocuments(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center();
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.black)),
                            );
                          } else {
                            final List data = snapshot.data!;
                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: ((context, index) {
                                final listString = data[index];
                                final list =
                                    listString.substring(1, listString.length - 1);
                                final getlist =
                                    list.split(',').map((e) => e.trim()).toList();
                                final fileName = getlist[0];
                                final fileUrl = getlist[1];

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 5.0,
                                    child: ListTile(
                                      onTap: () async {
                                        try {
                                          controller.isDocumentLoading.value = true;
                                          _checkFileAndOpen(fileUrl, fileName);
                                          controller.isDocumentLoading.value = false;
                                        } catch (e) {
                                          Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
                                        }
                                      },
                                      leading: const ClipOval(
                                        child: Icon(Icons.file_copy, color: Colors.black),
                                      ),
                                      title: Text(fileName,
                                          style: const TextStyle(color: Colors.black)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          try {
                                            // Remove the document from the UI
                                            setState(() {
                                              data.removeAt(index);
                                            });

                                            // Delete the document from the database
                                            final projId = await projectId();
                                            FirebaseFirestore.instance
                                                .collection('Projects')
                                                .doc(projId)
                                                .update({
                                              'documents':
                                                  FieldValue.arrayRemove([listString]),
                                            });
                                          } catch (e) {
                                            Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          }
                        },
                      ),
                      control.isDocumentLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.green,
                            ))
                          : const Center()
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

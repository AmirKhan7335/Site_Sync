  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'monthlyprogressscreen.dart';

  class SummaryScreen extends StatefulWidget {
    const SummaryScreen({Key? key}) : super(key: key);

    @override
    State<SummaryScreen> createState() => _SummaryScreenState();
  }

  class _SummaryScreenState extends State<SummaryScreen> {
    late List<dynamic> data = [];
    late Map<String, List<dynamic>> groupedData;
    String? projectId = "";
    bool isLoading = true;

    @override
    void initState() {
      super.initState();
      getData();
    }

    Future<int> calculateDayNo() async {
      int totalDayCount = 0;
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

      return totalDaysCount;
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

      return totalDaysCount;
    }

    Future<void> getData() async {
      User? user = FirebaseAuth.instance.currentUser;
      String? currentUserEmail = user?.email!;
      var email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var role = (await firestore.collection('users').doc(email).get()).data()!['role'];
      print('Role: $role');
       if(role != 'Engineer')
            {
              DocumentSnapshot engineerDoc1 = await FirebaseFirestore.instance
                  .collection('clients')
                  .doc(currentUserEmail)
                  .get();
              // Check if data exists before casting
              if (engineerDoc1.exists) {
                projectId = (engineerDoc1.data() as Map<String, dynamic>)['projectId'];
                print('Project ID: $projectId');
              } else {
                // Handle the case where document is empty or doesn't exist
                print('Engineer document is empty or does not exist');
                 // Or handle it differently as needed
              }
            }
            else
            {
              DocumentSnapshot engineerDoc = await FirebaseFirestore.instance
                  .collection('engineers')
                  .doc(currentUserEmail)
                  .get();
              if (engineerDoc.exists) {
              projectId =
              (engineerDoc.data() as Map<String, dynamic>)['projectId'];
              } else {
                // Handle the case where document is empty or doesn't exist
                print('Engineer document is empty or does not exist');
                // Or handle it differently as needed
              }
            }


      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(projectId!)
          .get();

      List<Map<String, dynamic>> dataList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print('Fetched ${dataList.length} progress reports');
      print('Data list: $dataList');

      // Group progress reports by month
      groupedData = groupByMonth(dataList);
      print('Grouped data by month: $groupedData');

      // Extract unique months and sort them
      List<String> months =
      groupedData.keys.toList()..sort((a, b) => b.compareTo(a));
      print('Unique months: $months');

      // Flatten the grouped data into a list to display in ListView
      List<dynamic> flattenedData = [];
      for (String month in months) {
        flattenedData.add(month);
        flattenedData.addAll(groupedData[month]!);
      }

      setState(() {
        data = flattenedData;
        isLoading = false;
      });
    }



    Map<String, List<dynamic>> groupByMonth(List<Map<String, dynamic>> dataList) {
      Map<String, List<dynamic>> groupedData = {};

      for (var data in dataList) {
        String? dateString = data['today-date'];
        print('Date: $dateString');

        DateTime? reportDate;
        try {
          // Parse the date using the format 'dd-MM-yyyy'
          reportDate = DateFormat('dd-MM-yyyy').parse(dateString!);
        } catch (e) {
          print('Failed to parse date: $dateString');
          continue; // Skip this data entry if date parsing fails
        }

        print('Report date: $reportDate');

        String monthYear = DateFormat('MMMM yyyy').format(reportDate);

        if (!groupedData.containsKey(monthYear)) {
          groupedData[monthYear] = [];
        }
        groupedData[monthYear]!.add(data);
      }

      return groupedData;
    }







    // Build UI based on grouped data
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Record Screen',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
            ? const Center(
          child: Text('No documents uploaded yet',
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ):ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            // Display progress report
            if (item is String) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 5.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonthProgressScreen(
                            monthYear: item,
                            progressReports: groupedData[item],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: const ClipOval(
                        child: Icon(Icons.file_copy, color: Colors.black),
                      ),
                      title: Text(
                        item, // Assuming `item` is the header (month and year)
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox(); // Placeholder for other types of items
            }
          },
        ),
      );
    }
  }







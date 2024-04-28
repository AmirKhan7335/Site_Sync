import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'monthlyprogressscreen.dart';

class SummaryScreenClient extends StatefulWidget {
  const SummaryScreenClient({Key? key}) : super(key: key);

  @override
  State<SummaryScreenClient> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreenClient> {
  late List<dynamic> data = [];
  late Map<String, List<dynamic>> groupedData;
  String? projectId = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? currentUserEmail = user?.email!;

    DocumentSnapshot engineerDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(currentUserEmail)
        .get();

    projectId =
    (engineerDoc.data() as Map<String, dynamic>)['projectId'];

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
        title: const Center(
          child: Text(
            'Summary Screen',
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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







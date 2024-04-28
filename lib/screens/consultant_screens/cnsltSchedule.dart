  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
  import 'package:syncfusion_flutter_pdf/pdf.dart';
  import 'package:timezone/data/latest.dart' as tz;
  import 'package:timezone/timezone.dart' as tz;
  import 'dart:io';

  import '../../models/activity.dart';
  import '../engineer_screens/detailsscreen.dart';
import 'activityGallery.dart';

  enum ExportFormat1 {
    excel,
    pdf,
  }

  class ConsultantSchedule extends StatefulWidget {
    ConsultantSchedule({required this.projId, required this.title, super.key});

    String projId;
    String title;

    @override
    State<ConsultantSchedule> createState() => _ConsultantScheduleState();
  }

  class _ConsultantScheduleState extends State<ConsultantSchedule> {
    static List<Activity> loadedActivities = [];
    String engEmail = '';

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      getActivities();
      _initializeTimeZone();
    }
    @override
    void dispose() {
      // Dispose resources here (e.g., clear loadedActivities list)
      loadedActivities.clear();
      super.dispose();
    }

    Future<void> _initializeTimeZone() async {
      tz.initializeTimeZones(); // Load time zone database
    }

    Future<dynamic> getActivities() async {
      try {
        final activitiesQuery = await FirebaseFirestore.instance
            .collection('engineers')
            .where('projectId', isEqualTo: widget.projId)
            .get();
        engEmail = await activitiesQuery.docs.first.id;
        // data.add(engEmail);
        final activitiesData = await FirebaseFirestore.instance
            .collection('engineers')
            .doc(engEmail)
            .collection('activities')
            .orderBy('order')
            .get();

        List<Activity> tempActivities = [];
        for (var doc in activitiesData.docs) {
          var data = doc.data();
          tempActivities.add(Activity(
              id: data['id'], // Use the Firestore document ID as the activity ID
              name: data['name'],
              startDate:
              DateFormat('dd/MM/yyyy').format(doc['startDate'].toDate()),
              finishDate:
              DateFormat('dd/MM/yyyy').format(doc['finishDate'].toDate()),
              order: data['order'],
              image: data['image']));
        }

        setState(() {
          loadedActivities = tempActivities;
        });

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
        // Get.snackbar('Error', '${e}', backgroundColor: Colors.white, colorText: Colors.black);
      }
    }

    Future<void> _exportActivities(ExportFormat1 format) async {
      try {
        String fileName = 'activities_export.${format.toString().toLowerCase()}';
        List<Activity> activities = loadedActivities;
        String filePath;

        switch (format) {
          case ExportFormat1.excel:
            filePath = await _generateExcelExportData(activities);
            break;
          case ExportFormat1.pdf:
            filePath = await _generatePDFExportData(activities);
            break;
        }

        if (filePath.isEmpty) {
          throw Exception('Export data is empty');
        }

        if (kDebugMode) {
          print('File saved at: $filePath');
        }
        Get.snackbar('Export Successful', 'File downloaded as $fileName', backgroundColor: Colors.white, colorText: Colors.black);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('Export Error: $e');
        }
        if (kDebugMode) {
          print('Stack Trace: $stackTrace');
        }
        // Get.snackbar('Export Error', 'An error occurred during export: $e', backgroundColor: Colors.white, colorText: Colors.black);
      }
    }

    Future<String> _generateExcelExportData(List<Activity> activities) async {
      try {
        final xlsio.Workbook workbook = xlsio.Workbook();
        final xlsio.Worksheet sheet = workbook.worksheets[0];

        // Add headers
        sheet.getRangeByIndex(1, 1).setText('Activity Name');
        sheet.getRangeByIndex(1, 2).setText('Start Date');
        sheet.getRangeByIndex(1, 3).setText('Finish Date');

        // Add activity data
        for (int i = 0; i < activities.length; i++) {
          final activity = activities[i];
          sheet.getRangeByIndex(i + 2, 1).setText(activity.name);
          DateTime startDate = DateTime.tryParse(activity.startDate) ?? DateTime.now();
          DateTime finishDate = DateTime.tryParse(activity.finishDate) ?? DateTime.now();
          sheet.getRangeByIndex(i + 2, 2).setDateTime(startDate);
          sheet.getRangeByIndex(i + 2, 3).setDateTime(finishDate);
        }

        // Construct the file path
        final String? downloadsDirectory = (await getExternalStorageDirectory())?.path;
        if (downloadsDirectory != null) {
          final String filePath = '$downloadsDirectory/activities_export.xlsx';

          // Save the document
          final List<int> bytes = workbook.saveAsStream();
          await File(filePath).writeAsBytes(bytes);

          // Dispose the workbook
          workbook.dispose();

          // Return the file path
          return filePath;
        } else {
          throw Exception('Unable to access the downloads directory.');
        }
      } catch (e, stackTrace) {
        print('Export Error: $e');
        print('Stack Trace: $stackTrace');
        throw Exception('An error occurred during export: $e');
      }
    }

    Future<String> _generatePDFExportData(List<Activity> activities) async {
      try {
        final PdfDocument document = PdfDocument();

        // Add a new page to the document.
        final PdfPage page = document.pages.add();

        // Create a PDF grid class to add tables.
        final PdfGrid grid = PdfGrid();

        // Specify the grid column count.
        grid.columns.add(count: 3);

        // Add a grid header row.
        final PdfGridRow headerRow = grid.headers.add(1)[0];
        headerRow.cells[0].value = 'Activity Name';
        headerRow.cells[1].value = 'Start Date';
        headerRow.cells[2].value = 'Finish Date';

        // Set header font.
        headerRow.style.font =
            PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

        // Add rows to the grid.
        for (int i = 0; i < activities.length; i++) {
          final activity = activities[i];
          PdfGridRow row = grid.rows.add();
          row.cells[0].value = activity.name;
          row.cells[1].value = activity.startDate;
          row.cells[2].value = activity.finishDate;
        }

        // Set grid format.
        grid.style.cellPadding = PdfPaddings(left: 5, top: 5);

        // Draw table in the PDF page.
        grid.draw(
          page: page,
          bounds: Rect.fromLTWH(
            0,
            0,
            page.getClientSize().width,
            page.getClientSize().height,
          ),
        );

        // Get the downloads directory path
        final String? downloadsDirectory = (await getExternalStorageDirectory())?.path;
        if (downloadsDirectory != null) {
          final String filePath = '$downloadsDirectory/activities_export.pdf';

          // Save the document.
          await File(filePath).writeAsBytes(await document.save());

          // Dispose the document.
          document.dispose();

          // Return the file path
          return filePath;
        } else {
          throw Exception('Unable to access the downloads directory.');
        }
      } catch (e, stackTrace) {
        print('Export Error: $e');
        print('Stack Trace: $stackTrace');
        throw Exception('An error occurred during PDF export: $e');
      }
    }

    Future<int> calculateDayNo() async {
      int totalDayCount = 0;
      try {
        var activitiesSnapshot1 = await FirebaseFirestore.instance
            .collection('engineers')
            .where('projectId', isEqualTo: widget.projId)// Sort by order
            .get();
        var engEmail = activitiesSnapshot1.docs.first.id;
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
          if (finishDate.isBefore(currentDate)||finishDate.isAtSameMomentAs(currentDate)) {
            // Calculate the total days from start date till finish date excluding Sundays
            int totalDays = finishDate.difference(startDate).inDays + 1;
            print("start date = $startDate, finish date = $finishDate, total days = $totalDays, current date = $currentDate");

            int dayCount = totalDays;
            // Add the calculated day count to the total
            totalDaysCount += dayCount;
          }
        }
          totalDayCount = totalDaysCount;
      } catch (e) {
        // Get.snackbar('Error', '$e', backgroundColor: Colors.white, colorText: Colors.black);
      }

      // Return the total day count
      return totalDayCount;
    }

    Future<void> _showExportOptions(BuildContext context) async {
      final ExportFormat1? selectedFormat = await showDialog<ExportFormat1>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Export Format'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Excel'),
                  onTap: () {
                    Navigator.of(context).pop(ExportFormat1.excel);
                  },
                ),
                ListTile(
                  title: const Text('PDF'),
                  onTap: () {
                    Navigator.of(context).pop(ExportFormat1.pdf);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (selectedFormat != null) {
        await _exportActivities(selectedFormat);
      }
    }

    Widget _buildActivityContainer(
        Activity activity, String mainHeading, String subHeading) {
      // Use a pattern like "1. Foundation" for displaying the activity name
      String displayText = '${activity.order}. ${capitalize(activity.name)}';
      // Replace "-" with "/" in start and finish dates
      String formattedStartDate = activity.startDate.replaceAll('-', '/');
      String formattedFinishDate = activity.finishDate.replaceAll('-', '/');
      final today = DateTime.now().subtract(Duration(days: 1));

      // Parse the finish date
      final finishDate = DateFormat('dd/MM/yyyy').parse(activity.finishDate);
      print("activity name = $mainHeading, id = ${activity.id}, engEmail = $engEmail");

      return InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ActivityGallery(
                        engEmail: engEmail,
                        activityId: activity.id,
                        activityName: capitalize(activity.name),
                    ))),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Card(
            elevation: 5,
            color: Colors.white,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7.0,
                    height: 50,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayText, // Use the modified display text
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                ),
                              ),
                            ),
                            if (finishDate.isBefore(today)) // Check finish date
                              Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '$formattedStartDate - $formattedFinishDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Future<void> downloadSampleFile() async {
      try {
        // Check and request storage permission
        var status = await Permission.storage.request();
        if (status.isGranted) {
          // Load the asset
          ByteData data = await rootBundle.load('assets/excel/Sample Excel Sheet.xlsx');
          List<int> bytes = data.buffer.asUint8List();

          // Get the Downloads directory
          Directory? downloadsDirectory = await getExternalStorageDirectory();

          // Create a File instance pointing to the file to be downloaded
          File file = File('${downloadsDirectory?.path}/sample.xlsx');

          // Write the asset data to the file system
          await file.writeAsBytes(bytes);

          Get.snackbar('Sample File Downloaded', '', backgroundColor: Colors.white, colorText: Colors.black);
        } else {
          Get.snackbar('Permission Denied', 'Storage permission is required', backgroundColor: Colors.white, colorText: Colors.black);
        }
      } catch (e) {
        if (kDebugMode) {
          print("An error occurred: $e");
        }
        // Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      }
    }

    // Function to capitalize the first letter of a string
    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

      Widget build(BuildContext context) {
        // Get current date and time in Pakistan time zone
        final pakistanTimeZone = tz.getLocation('Asia/Karachi');
        final currentDateTimeInPakistan = tz.TZDateTime.now(pakistanTimeZone);
        print("current date time = $currentDateTimeInPakistan");

  //     // Extract year, month, and day
  //     final year = currentDateTimeInPakistan.year;
  //     final month = currentDateTimeInPakistan.month;
  //     final day = currentDateTimeInPakistan.day;
  //
  // // Create a DateTime object and add Pakistan's offset (UTC+5)
  //     final currentDate = DateTime(year, month, day).add(const Duration(hours: 5));
  //     print("current date 11 =$currentDate");

        // Extract day of week
        final currentDayOfWeek = currentDateTimeInPakistan.weekday;
        print("current day of week =$currentDayOfWeek");
        // Convert the day of the week to a string representation
        final List<String> dayNames = [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ];
        // Format the date in 'Month Year' format
        final String monthYear =
            DateFormat('MMMM yyyy').format(currentDateTimeInPakistan);
        // Determine if it's a working day (Monday to Thursday)
        final bool isWorkingDay = currentDateTimeInPakistan.weekday != 0;
        return Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF42F98F),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Row(
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
                                  monthYear,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Image.asset(
                                  'assets/images/icons8-schedule-100 1.png',
                                  // Replace with the path to your image asset
                                  width: 75, // Set the width of the image
                                  height: 75, // Set the height of the image
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Row(
                              children: [
                                FutureBuilder<int>(
                                  future: calculateDayNo(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator(); // Show loading indicator while calculating
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Row(
                                        children: [
                                          Text(
                                            'Day ${snapshot.data}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
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
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(7, (index) {
                                // Calculate the date for each day of the week relative to the current day
                                final int dayIndex = index - 3;
                                print("day index = $dayIndex");
                                final day = currentDateTimeInPakistan.subtract(
                                    Duration(
                                        days: currentDayOfWeek - dayIndex - currentDayOfWeek));
                                print("day = $day");
                                // Format the date to 'd' (day of the month)
                                final formattedDate =
                                    DateFormat('d').format(day);
                                print("formatted date = $formattedDate");
                                // Get the abbreviated day name
                                final dayOfWeek = dayNames[
                                    (currentDayOfWeek + dayIndex - 1) % 7];
                                // Check if the current day matches today's date
                                final bool isToday = dayIndex == 0;
                                print("is today = $isToday");

                                return Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color:
                                        isToday ? Colors.black : Colors.white,
                                    // Set background color
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: isToday
                                              ? Colors.white
                                              : Colors.black, // Set text color
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      Text(
                                        dayOfWeek,
                                        style: TextStyle(
                                          color: isToday
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        const Text(
                          'Activities',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 60),
                        PopupMenuButton<String>(
                          color: Colors.white,
                          icon: const Icon(Icons.more_vert, color: Colors.black),
                          onSelected: (String choice) {
                            switch (choice) {
                              case 'Sample':
                                downloadSampleFile();
                                break;
                              case 'Download':
                                _showExportOptions(context);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              // Conditionally add edit and delete options
                              if (loadedActivities.isNotEmpty) ...[
                                const PopupMenuItem(
                                  value: 'Sample',
                                  child: Text('Download Sample Excel', style: TextStyle(color: Colors.black)),
                                ), // Add a divider
                              ],
                              const PopupMenuItem<String>(
                                value: 'Download',
                                child: Text('Download Updated File', style: TextStyle(color: Colors.black)),
                              ),
                            ];
                          },
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.file_download),
                        //   // Add export icon
                        //   onPressed: () => _showExportOptions(context),
                        //   color: Colors.green,
                        // ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: calculateDayNo(),
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
                        }
                        else if (snapshot.hasData){
                          return Column(
                            children: [
                              if (loadedActivities.isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: loadedActivities.map((activity) {
                                      return _buildActivityContainer(
                                        activity,
                                        activity.name,
                                        '${activity.startDate} - ${activity.finishDate}',
                                      );
                                    }).toList(),
                                  ),
                                ),
                              if (loadedActivities.isEmpty)
                                const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 120,
                                      ),
                                      Text('No activities to display',
                                          style: TextStyle(fontSize: 20,color: Colors.black)),
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }

                        else {
                          return  const Center(
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
          ),
        );
      }
    }

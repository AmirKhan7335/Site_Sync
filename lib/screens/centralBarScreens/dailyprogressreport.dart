import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather/weather.dart';
import 'package:flutter/material.dart';
import '../../controllers/progressTrackingController.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../models/activity.dart';
import '../../models/user_data.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'const.dart'; // Make sure you import your constants file where OPENWEATHER_API_KEY is defined

class DailyProgressReportScreen extends StatefulWidget {
  const DailyProgressReportScreen({super.key});

  @override
  DailyProgressReportScreenState createState() =>
      DailyProgressReportScreenState();
}

class DailyProgressReportScreenState extends State<DailyProgressReportScreen> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController contractorController = TextEditingController();
  TextEditingController engineerController = TextEditingController();
  TextEditingController weatherController = TextEditingController();
  TextEditingController overallProgressController = TextEditingController();
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  String? projectId = "";
  Weather? weather1;
  final user = FirebaseAuth.instance.currentUser;
  List<DateTime> noWorkDates = [];
  late final DateTime currentDateTimeInPakistan;

  @override
  void initState() {
    super.initState();
    // Call the method to fetch project details
    fetchProjectDetails();
    currentDateTimeInPakistan = DateTime.now().toUtc().add(const Duration(hours: 5));
  }

  Future<void> fetchProjectDetails() async {
    // Fetch current user's email using Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserEmail = user.email!;

      // Query Firestore to get the corresponding project ID from the 'engineers' subcollection
      DocumentSnapshot engineerDoc = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(currentUserEmail)
          .get();

      // Check if engineerDoc exists
      if (engineerDoc.exists) {
        // Get the project ID
        projectId = (engineerDoc.data() as Map<String, dynamic>)['projectId'];

        if (projectId != null) {
          // Query Firestore to fetch project details using the project ID
          DocumentSnapshot<Map<String, dynamic>> projectDoc =
              await FirebaseFirestore.instance
                  .collection('Projects')
                  .doc(projectId)
                  .get();
          DocumentSnapshot<Map<String, dynamic>> engineerDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserEmail)
                  .get();

          // Check if projectDoc exists
          if (projectDoc.exists) {
            setState(() {
              // Update text controllers with fetched project details
              projectNameController.text = capitalizeFirstLetter(
                  projectDoc.data()!['title'] ?? 'Unknown');
              locationController.text = capitalizeFirstLetter(
                  projectDoc.data()!['location'] ?? 'Unknown');
              engineerController.text = capitalizeFirstLetter(
                  engineerDoc.data()!['username'] ?? 'Unknown');
              contractorController.text = capitalizeFirstLetter(
                  projectDoc.data()!['companyName'] ?? 'Unknown');

              // Fetch and set weather information here
              fetchWeather(projectDoc.data()!['location']);
            });
          }
        }
      }
    }
  }

  Future<void> fetchWeather(String location) async {
    try {
      // Use geocoding to convert location name into coordinates
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        Location cityLocation = locations.first;
        // Fetch weather details using the city's coordinates
        Weather weather = await _wf.currentWeatherByLocation(
            cityLocation.latitude, cityLocation.longitude);
        setState(() {
          weather1 = weather;
          String weatherDescription = weather.weatherDescription ?? 'Unknown';
          double temperature = weather.temperature?.celsius ?? 0.0;
          weatherController.text =
              '$weatherDescription, Temperature: ${temperature.toStringAsFixed(1)}°C';
        });
      } else {
        // Handle case where no matching city is found
        setState(() {
          weatherController.text = 'City not found';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      // Set the weather text controller to indicate an error
      setState(() {
        weatherController.text = 'Failed to fetch weather';
      });
    }
  }

  Future<List> fetchProject() async {
//..
    try {
      final collectionData = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(user!.email)
          .get();

      final projectId = await collectionData.data()!['projectId'];
      final projectCollection = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .get();
      final data = projectCollection.data();
      final projectData = [
        data!['title'],
        data['budget'],
        data['funding'],
        data['startDate'],
        data['endDate'],
        data['location'],
        data['creationDate'],
        data['retMoney'],
        projectId
      ];
      return projectData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  Future<List<Activity>> fetchActivities() async {
    try {
      var email = user?.email;
      if (email == null) {
        return [];
      }
      //---------------------------------------For Client-------------------------
      var projIdForClient = await FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .get();
      var clientProjectId =
          projIdForClient.data()?['projectId']; // Add null check here
      var sameEngineer = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: clientProjectId)
          .get();
      sameEngineer.docs.map((e) => e.id).toList();
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(email)
          .collection('activities')
          .get();

      // Convert documents to Activity objects
      var activities = activitiesSnapshot.docs.map((doc) {
        return Activity(
          id: doc['id'],
          name: doc['name'],
          startDate: DateFormat('dd/MM/yyyy').format(doc['startDate'].toDate()),
          finishDate:
              DateFormat('dd/MM/yyyy').format(doc['finishDate'].toDate()),
          order: doc['order'],
        );
      }).toList();
      // Fetch "No Work" data
      var noWorkSnapshot = await FirebaseFirestore.instance
          .collection('No_Work')
          .where('projectId',
          isEqualTo: clientProjectId ?? projectId) // Include both client and non-client cases
          .get();
      noWorkDates = noWorkSnapshot.docs
          .map((doc) => DateFormat('dd/MM/yyyy').parse(doc['date']))
          .toList();
      print('No Work Dates: $noWorkDates');

      // Check if today is a "No Work" day (moved here for access to noWorkDates)
      bool isNoWorkDay = noWorkDates.any((noWorkDate) =>
      noWorkDate.year == currentDateTimeInPakistan.year &&
          noWorkDate.month == currentDateTimeInPakistan.month &&
          noWorkDate.day == currentDateTimeInPakistan.day);

      return activities;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  Future fetchData() async {
    final username = await fetchUsername();
    final profilePicUrl = await fetchProfilePicUrl();
    final activities = await fetchActivities();
    final projectData = await fetchProject();
    return [
      UserData(
        username: username,
        profilePicUrl: profilePicUrl,
        activities: activities,
      ),
      projectData
    ];
  }

  Future<String> fetchUsername() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['username'];
      } else {
        return 'Guest'; // Default username for guests
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
      return 'Error';
    }
  }

  Future<String?> fetchProfilePicUrl() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();

      if (userSnapshot['profilePic'].exists) {
        return userSnapshot['profilePic'];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile picture: $e');
      }
      return 'https://t4.ftcdn.net/jpg/00/65/77/27/360_F_65772719_A1UV5kLi5nCEWI0BNLLiFaBPEkUbv5Fv.jpg';
    }
  }

  Activity? findTodaysActivity(List<Activity> activities) {
    DateTime today = DateTime.now();
    String formattedToday =
        DateFormat('dd/MM/yyyy').format(today); // Format current date

    try {
      DateTime todayDate = DateFormat('dd/MM/yyyy')
          .parse(formattedToday); // Convert formattedToday to DateTime
      return activities.firstWhere((activity) {
        // Parse activity dates
        DateTime startDate = parseDate(activity.startDate);
        DateTime finishDate = parseDate(activity.finishDate);

        // Compare todayDate with activity dates
        return startDate.isBefore(todayDate) && finishDate.isAfter(todayDate) ||
            startDate.isAtSameMomentAs(todayDate) ||
            finishDate.isAtSameMomentAs(todayDate);
      });
    } catch (e) {
      return null;
    }
  }

  DateTime parseDate(String dateStr) {
    try {
      // Try parsing with "dd/MM/yyyy" format
      final List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        final int? year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      // Try parsing with "dd-MM-yyyy" format
      final List<String> parts2 = dateStr.split('-');
      if (parts2.length == 3) {
        final int? day = int.tryParse(parts2[0]);
        final int? month = int.tryParse(parts2[1]);
        final int? year = int.tryParse(parts2[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      // If parsing fails, return a default value (e.g., current date)
      return DateTime.now();
    } catch (e) {
      // Handle the parsing error here, such as logging an error message
      // Return a default value
      return DateTime.now();
    }
  }

  String capitalizeFirstLetter(String text) {
    return text.replaceAllMapped(
        RegExp(r'\b\w'), (match) => match.group(0)!.toUpperCase());
  }

  int calculatePercentComplete(String startDate, String finishDate) {
    try {
      DateTime today = DateTime.now();
      DateTime parsedStartDate = parseDate(startDate);
      DateTime parsedFinishDate = parseDate(finishDate);

      int totalDuration =
          parsedFinishDate.difference(parsedStartDate).inDays + 1;
      int timeElapsed = today.difference(parsedStartDate).inDays;
      if (totalDuration <= 0) {
        return 0; // Return 0 if total duration is non-positive
      }

      double percentComplete = (timeElapsed / totalDuration) * 100;
      // Round the percentComplete to the nearest integer
      return percentComplete
          .round()
          .clamp(0, 100); // Ensure the result is within [0, 100] range
    } catch (e) {
      return -1; // Return a default value or error code in case of any error
    }
  }

  int calculatePercentComplete1(String startDate, String finishDate) {
    try {
      DateTime today = DateTime.now();
      DateTime parsedStartDate = parseDate(startDate);
      DateTime parsedFinishDate = parseDate(finishDate);

      int totalDuration =
          parsedFinishDate.difference(parsedStartDate).inDays + 1;
      int timeElapsed = today.difference(parsedStartDate).inDays + 1;
      if (totalDuration <= 0) {
        return 0; // Return 0 if total duration is non-positive
      }

      double percentComplete = (timeElapsed / totalDuration) * 100;
      // Round the percentComplete to the nearest integer
      return percentComplete
          .round()
          .clamp(0, 100); // Ensure the result is within [0, 100] range
    } catch (e) {
      return -1; // Return a default value or error code in case of any error
    }
  }

  int calculateDaysLeft(String finishDate) {
    try {
      DateTime parsedFinishDate = parseDate(finishDate);
      DateTime today = DateTime.now();

      // Calculate the difference in days
      int daysDifference = parsedFinishDate.difference(today).inDays;

      // if (today.hour < 12) {
      //   daysDifference += 1;
      // }

      if (daysDifference < 0) {
        return 0; // The finish date is in the past, no days left
      } else {
        return daysDifference + 1; // Add 1 to include the due date
      }
    } catch (e) {
      return -1; // Return a default value or handle the error accordingly
    }
  }

  // Function to generate PDF
  Future<PdfDocument> generatePDF(List<Activity> activities,
      Activity? todayActivity, ProjectProgressController controller) async {
    // Create a new PDF document
    final document = PdfDocument();

    // Add a page to the document
    final page = document.pages.add();
    // Draw text on the page
    page.graphics.drawString(
      'Daily Progress Report',
      PdfStandardFont(PdfFontFamily.helvetica, 25),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 30),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    // Add project details
    final details = StringBuffer();
    // Check if today is a "No Work" day using noWorkDates
    bool isNoWorkDay = noWorkDates.any((noWorkDate) =>
    noWorkDate.year == currentDateTimeInPakistan.year &&
        noWorkDate.month == currentDateTimeInPakistan.month &&
        noWorkDate.day == currentDateTimeInPakistan.day);
    print('No Work Day: $isNoWorkDay');
    details.writeln('');
    details.writeln('');
    details.writeln('');
    page.graphics.drawString(
      'PROJECT DETAILS:',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: Rect.fromLTWH(0, 50, page.getClientSize().width, 30),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
    details.writeln('');
    details.writeln('Date: ${_getFormattedDate(DateTime.now())}');
    details.writeln('');
    details.writeln('Project Name: ${projectNameController.text}');
    details.writeln('');
    details.writeln('Location: ${locationController.text}');
    details.writeln('');
    details.writeln('Contractor: ${contractorController.text}');
    details.writeln('');
    details.writeln('Engineer: ${engineerController.text}');
    details.writeln('');
    details.writeln('Weather: ${weatherController.text}');
    details.writeln('');
    details.writeln('');
    details.writeln('');
    details.writeln('');
    page.graphics.drawString(
      'TODAY\'S OVERALL PROGRESS:',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: Rect.fromLTWH(0, 270, page.getClientSize().width, 30),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
    if (isNoWorkDay) {
    details.writeln(
        '- ${capitalizeFirstLetter(todayActivity?.name ?? 'No')} activity was scheduled today.');
    details.writeln(
        '- The activity progress was ${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%.');
    details.writeln(
        '- No work was done today.');
    details.writeln(
        '- The activity is estimated to complete in ${activities.isNotEmpty ? (todayActivity != null ? (calculateDaysLeft(todayActivity.finishDate) == 1 ? '1 day.' : '${calculateDaysLeft(todayActivity.finishDate)} days.') : 'No Activity') : '.'}');
    details.writeln(
        '- The overall progress of the project is ${controller.overAllPercent1.value}%');
    } else {
      details.writeln(
          '- ${capitalizeFirstLetter(todayActivity?.name ?? 'No')} activity was scheduled today.');
      details.writeln(
          '- The activity progress was ${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%.');
      details.writeln(
          '- After the execution of the work, the activity progress is ${calculatePercentComplete1(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%.');
      details.writeln(
          '- The activity is estimated to complete in ${activities.isNotEmpty ? (todayActivity != null ? (calculateDaysLeft(todayActivity.finishDate) == 1 ? '1 day.' : '${calculateDaysLeft(todayActivity.finishDate)} days.') : 'No Activity') : '.'}');
      details.writeln(
          '- The overall progress of the project is ${controller.overAllPercent1.value}%');
    }

    // Draw project details on the page
    page.graphics.drawString(
      details.toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(
          0, 40, page.getClientSize().width, page.getClientSize().height - 40),
    );

    // Return the generated PDF document
    return document;
  }

// Function to save PDF to downloads directory
  Future<String> savePDF(PdfDocument document) async {
    try {
      // Get the downloads directory path
      final String? downloadsDirectory =
          (await getExternalStorageDirectory())?.path;
      if (downloadsDirectory != null) {
        // Define the file path with dynamic file name based on current date
        final String currentDate =
            DateFormat('dd-MM-yyyy').format(DateTime.now());
        final String filePath = '$downloadsDirectory/$currentDate.pdf';

        // Save the PDF to the downloads directory
        final file = File(filePath);
        final bytes = await document.save();
        await file.writeAsBytes(bytes);

        // Return the file path
        return filePath;
      } else {
        throw Exception('Unable to access the downloads directory.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving PDF: $e');
      }
      throw Exception('Failed to save PDF');
    }
  }

// Function to open PDF
  Future<void> openPDF(String path) async {
    try {
      // Open PDF
      await OpenFile.open(path);
    } catch (e) {
      // Handle any errors
      if (kDebugMode) {
        print('Error opening PDF: $e');
      }
      throw Exception('Failed to open PDF');
    }
  }

  Future<void> openPDFfile(BuildContext context) async {
    try {
      // Fetch data
      final List<dynamic> data = await fetchData();

      // Extract activities and todayActivity from data
      final UserData userData = data[0] as UserData;
      final List<Activity> activities = userData.activities ?? [];
      final Activity? todayActivity = findTodaysActivity(activities);

      // Initialize controller
      final controller = Get.put(ProjectProgressController());

      // Generate PDF with the list of activities
      final pdf = await generatePDF(activities, todayActivity, controller);

      // Save PDF to downloads directory
      final path = await savePDF(pdf);

      // Open PDF
      await openPDF(path);
    } catch (e) {
      if (kDebugMode) {
        print('Error opening PDF: $e');
      }
      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sharePDF(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Fetch data
      final List<dynamic> data = await fetchData();

      // Extract activities and todayActivity from data
      final UserData userData = data[0] as UserData;
      final List<Activity> activities = userData.activities ?? [];
      final Activity? todayActivity = findTodaysActivity(activities);

      // Initialize controller
      final controller = Get.put(ProjectProgressController());

      // Generate PDF with the list of activities
      final pdf = await generatePDF(activities, todayActivity, controller);

      // Save PDF to downloads directory
      final path = await savePDF(pdf);

      // Upload PDF to Firebase Storage
      final downloadUrl = await uploadPDFToFirebase(path);

      // Save download URL to Firestore
      await saveDownloadUrlToFirestore(downloadUrl);

      // Dismiss loading indicator
      Navigator.pop(context);

      // Show success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily progress report shared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing PDF: $e');
      }
      // Dismiss loading indicator
      Navigator.pop(context);

      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> uploadPDFToFirebase(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(filePath));
      return ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading PDF to Firebase: $e');
      }
      throw Exception('Failed to upload PDF to Firebase');
    }
  }

  Future<void> saveDownloadUrlToFirestore(String downloadUrl) async {
    try {
      final String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Get the project ID
      final projId =
          projectId; // Assuming you have a function to get the project ID

      // Save download URL, project ID, and today's date inside a document in the summary collection
      await FirebaseFirestore.instance.collection(projId!).doc(todayDate).set({
        todayDate: downloadUrl,
        'today-date': todayDate,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving download URL to Firestore: $e');
      }
      throw Exception('Failed to save download URL to Firestore');
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = fetchData();
    final controller = Get.put(ProjectProgressController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Progress Report',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String value) async {
              if (value == 'open_pdf') {
                await openPDFfile(context);
              } else if (value == 'share_pdf') {
                await sharePDF(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'open_pdf',
                child: ListTile(
                  leading: Icon(Icons.open_in_new),
                  title: Text('Open PDF'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share_pdf',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share PDF'),
                ),
              ),
            ],
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: data,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                final List<dynamic> data = snapshot.data as List<dynamic>;
                final UserData userData = data[0] as UserData;
                final List<Activity> activities = userData.activities ?? [];
                // Find today's and upcoming activities
                Activity? todayActivity = findTodaysActivity(activities);
                controller.calculateOverallPercent(activities);
                // Check if today is a "No Work" day
                bool isNoWorkDay = noWorkDates.any((noWorkDate) =>
                    noWorkDate.year == currentDateTimeInPakistan.year &&
                    noWorkDate.month == currentDateTimeInPakistan.month &&
                    noWorkDate.day == currentDateTimeInPakistan.day);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Project Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const Expanded(child: SizedBox()),
                        Text(
                          'Date: ${_getFormattedDate(DateTime.now())}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField('PROJECT NAME', projectNameController),
                    const SizedBox(height: 10),
                    _buildTextField('LOCATION', locationController),
                    const SizedBox(height: 10),
                    _buildTextField('CONTRACTOR', contractorController),
                    const SizedBox(height: 10),
                    _buildTextField('ENGINEER', engineerController),
                    const SizedBox(height: 10),
                    _buildTextField('WEATHER', weatherController),
                    const SizedBox(height: 20),
                    const Text(
                      'TODAY\'S OVERALL PROGRESS',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    _buildDynamicHeightTextField(
                      isNoWorkDay
                          ? '${capitalizeFirstLetter(todayActivity?.name ?? 'No')} activity was scheduled today. The activity progress was ${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%. No work was done today. Today\'s progress is 0%. The activity is estimated to complete in ${activities.isNotEmpty ? (todayActivity != null ? (calculateDaysLeft(todayActivity.finishDate) == 1 ? '1 day.' : '${calculateDaysLeft(todayActivity.finishDate)} days.') : 'No Activity') : '.'}  The overall progress of the project is ${controller.overAllPercent1.value}%.'
                          : '${capitalizeFirstLetter(todayActivity?.name ?? 'No')} activity was scheduled today. The activity progress was ${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%. After the execution of the work, the activity progress is ${calculatePercentComplete1(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%. The activity is estimated to complete in ${activities.isNotEmpty ? (todayActivity != null ? (calculateDaysLeft(todayActivity.finishDate) == 1 ? '1 day.' : '${calculateDaysLeft(todayActivity.finishDate)} days.') : 'No Activity') : '.'}  The overall progress of the project is ${controller.overAllPercent1.value}%',
                      overallProgressController,
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'No Data Found',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildDynamicHeightTextField(
      String labelText, TextEditingController controller) {
    controller.text = labelText; // Set initial text

    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      // Minimum number of lines
      maxLines: 20,
      // Maximum number of lines
      style: const TextStyle(color: Colors.black, height: 1.1),
      // Set height to 1.0
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      readOnly: false, // Allow editing
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {bool isLabel = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLabel)
          Text(
            labelText,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        SizedBox(
          height: 30, // Reduced height
          child: Stack(
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black, fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                readOnly: false, // Allow editing
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    projectNameController.dispose();
    locationController.dispose();
    contractorController.dispose();
    engineerController.dispose();
    weatherController.dispose();
    overallProgressController.dispose();
    super.dispose();
  }
}

import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/engineer_screens/editactivityscreen.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import '../../../components/mytextfield.dart';
import '../detailsscreen.dart';
import '../foundationschedulescreen.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationCases.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum ExportFormat {
  excel,
  pdf,
}

class ScheduleScreen extends StatefulWidget {
  final bool isClient;

  const ScheduleScreen({super.key, required this.isClient});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  List<Activity> activities = [];
  bool isLoading = false;
  static List<Activity> loadedActivities = [];
  int? newUserOrder;

  // Define TextEditingController variables
  final TextEditingController _newOrderController = TextEditingController();
  final TextEditingController _newActivityNameController =
      TextEditingController();

  Future<void> showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF455A64),
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickFile() async {
    setState(() {
      isLoading = true; // Start loading when file picking begins
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'pdf', 'mpp'],
    );

    if (result != null) {
      String filePath = result.files.single.path ?? '';
      File file = File(filePath);

      try {
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        List<Activity> tempActivities = [];
        int order = 1; // Initialize the order counter

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;

          // Check if the first row contains headers
          bool hasHeaders = sheet.rows.isNotEmpty &&
              sheet.rows.first.any((cell) =>
                  cell?.value != null && cell!.value.toString().isNotEmpty);

          // Define a mapping of expected column names to their variations
          Map<String, List<String>> columnHeaderVariations = {
            'name': [
              'activity',
              'activity name',
              'activityname',
              'activity_name',
              'name',
              'Activity',
              'Activity Name',
              'ActivityName',
              'Activity_Name'
            ],
            'startDate': [
              'start date',
              'startdate',
              'start_date',
              'start',
              'Start',
              'Start Date',
              'StartDate',
              'Start_Date'
            ],
            'finishDate': [
              'finish date',
              'finishdate',
              'finish_date',
              'finish',
              'Finish Date',
              'FinishDate',
              'Finish_Date',
              'Finish'
            ]
          };

          // Find the column indices based on expected column names and variations
          int nameIndex;
          int startDateIndex;
          int finishDateIndex;

          if (hasHeaders) {
            // If headers are provided, find the corresponding column indices
            nameIndex = findColumnIndex(
                sheet.rows.first, columnHeaderVariations['name']!);
            startDateIndex = findColumnIndex(
                sheet.rows.first, columnHeaderVariations['startDate']!);
            finishDateIndex = findColumnIndex(
                sheet.rows.first, columnHeaderVariations['finishDate']!);
          } else {
            // If headers are not provided, use default column indices
            nameIndex = 0;
            startDateIndex = 1;
            finishDateIndex = 2;
          }

          // Iterate through rows to extract data
          for (var row in sheet.rows.skip(hasHeaders ? 1 : 0)) {
            // If the row is empty, skip it
            if (row.isEmpty) continue;

            // Extract data from the row
            String name = row.length > nameIndex
                ? row[nameIndex]?.value?.toString() ?? ''
                : '';
            String startDate = row.length > startDateIndex
                ? row[startDateIndex]?.value?.toString() ?? ''
                : '';
            String finishDate = row.length > finishDateIndex
                ? row[finishDateIndex]?.value?.toString() ?? ''
                : '';

            // If any of the required fields are empty, skip the row
            if (name.isEmpty || startDate.isEmpty || finishDate.isEmpty) {
              debugPrint('Skipping row with incomplete data');
              continue;
            }

            DateTime startDateParsed;
            DateTime finishDateParsed;
            try {
              startDateParsed = parseDate(startDate);
              finishDateParsed = parseDate(finishDate);
            } catch (e) {
              await showErrorDialog('Invalid date format: $e');
              continue;
            }

            // Convert to 'dd/MM/yy' format for displaying
            String formattedStartDate =
                DateFormat('dd/MM/yyyy').format(startDateParsed);
            String formattedFinishDate =
                DateFormat('dd/MM/yyyy').format(finishDateParsed);

            var activity = Activity(
              id: 'your_unique_identifier',
              // Update this accordingly
              name: name,
              startDate: formattedStartDate,
              finishDate: formattedFinishDate,
              order: order++,
            );
            tempActivities.add(activity);
          }
        }

        // Clear existing activities for the current user's email
        await clearActivitiesForCurrentUser();

        // Update the loaded activities list
        setState(() {
          loadedActivities.clear(); // Clear the local list
          loadedActivities = tempActivities; // Assign the new activities
        });

        // Upload all activities to Firestore
        for (var activity in tempActivities) {
          await uploadActivityToFirebase(activity);
        }

        debugPrint('Number of activities uploaded: ${loadedActivities.length}');
      } catch (e) {
        await showErrorDialog('Error during parsing: $e');
      }
    } else {
      // User canceled the picker
    }

    setState(() {
      isLoading = false;
    });
  }

// Function to find the index of a column with variations of the expected name
  int findColumnIndex(List<dynamic> row, List<String> expectedVariations) {
    for (var variation in expectedVariations) {
      var index = row.indexWhere((cell) =>
          cell?.value?.toString().toLowerCase().contains(variation) ?? false);
      if (index != -1) {
        return index;
      }
    }
    // If none of the variations are found, return a default index (0)
    return 0;
  }

  DateTime parseDate(String dateString) {
    try {
      List<String> formats = [
        'dd/MM/yyyy',
        // Common date format
        'dd-MM-yyyy',
        'dd-MM-yy',
        'dd/MM/yy',
        'MM/dd/yyyy',
        'MM-dd-yyyy',
        'MM-dd-yy',
        'MM/dd/yy',
        'yyyy-MM-dd',
        // ISO 8601 format
        'M/d/yyyy',
        'M-d-yyyy',
        'M-d-yy',
        'M/d/yy',
        'yyyy/MM/dd',
        'MM/d/yyyy',
        'MM-d-yyyy',
        'MM-d-yy',
        'MM/d/yy',
        'd/M/yyyy',
        'd-M-yyyy',
        'd-M-yy',
        'M/dd/yyyy',
        'M-dd-yyyy',
        '44945'
        // Add more formats as needed
      ];
      for (String format in formats) {
        try {
          final DateFormat formatter = DateFormat(format);
          return formatter.parseStrict(dateString); // Use strict parsing
        } catch (_) {
          // Continue to the next format if parsing fails
        }
      }
      return DateTime.parse(dateString);
    } catch (e) {
      throw FormatException('Date not in expected format: $dateString');
    }
  }

  Future<void> clearActivitiesForCurrentUser() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    var querySnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
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
    var email = FirebaseAuth.instance.currentUser!.email;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
                mainHeading: mainHeading,
                subHeading: subHeading,
                image: activity.image, activityId: activity.id,engineerEmail: email ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

// Function to capitalize the first letter of a string
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showEditOptions() async {
    if (loadedActivities.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            title: const Text('Select an Activity to Edit',
                style: TextStyle(color: Colors.black)),
            children: loadedActivities.asMap().entries.map((entry) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToEditScreen(entry.value, entry.key);
                },
                child: Text(entry.value.name,
                    style: TextStyle(color: Colors.black)),
              );
            }).toList(),
          );
        },
      );
    }
  }

  void _navigateToEditScreen(Activity selectedActivity, int index) async {
    final Activity? updatedActivity = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(
          activity: selectedActivity,
          index: index,
          onSave: (Activity updatedActivity, int? newOrder) async {
            // Start the loading process
            setState(() => isLoading = true);

            bool nameChanged = selectedActivity.name != updatedActivity.name;
            bool startDateChanged =
                selectedActivity.startDate != updatedActivity.startDate;
            bool finishDateChanged =
                selectedActivity.finishDate != updatedActivity.finishDate;
            bool orderChanged =
                newOrder != null && newOrder != selectedActivity.order;
            bool alreadyUpdated = false; // Flag to track if update already done

            if (orderChanged) {
              // If the order is changed, perform reordering first
              String updatedActivityId =
                  await reorderAndUpdateActivities(updatedActivity, newOrder);

              // Find the updated activity by ID
              Activity updatedActivityAfterReorder = loadedActivities
                  .firstWhere((activity) => activity.id == updatedActivityId);

              // Update other details if needed
              if (nameChanged || startDateChanged || finishDateChanged) {
                await updateActivityDetails(updatedActivityAfterReorder,
                    nameChanged, startDateChanged, finishDateChanged);
                alreadyUpdated = true; // Mark as updated
              }
            }

            if ((nameChanged || startDateChanged || finishDateChanged) &&
                !alreadyUpdated) {
              // If order hasn't changed, but other properties have, and not updated yet
              await deleteActivityFromFirebase(selectedActivity.id);
              updatedActivity.id =
                  'activity_${DateTime.now().millisecondsSinceEpoch}';
              await uploadActivityToFirebase(updatedActivity);
              updateLocalActivity(updatedActivity);
            }

            fetchActivitiesFromFirebase();

            // End the loading process
            setState(() => isLoading = false);
          },
        ),
      ),
    );

    if (updatedActivity == null) {
      if (kDebugMode) {
        print('No activity updated');
      }
      return;
    }
  }

  Future<void> updateActivityDetails(Activity activity, bool nameChanged,
      bool startDateChanged, bool finishDateChanged) async {
    if (nameChanged || startDateChanged || finishDateChanged) {
      await deleteActivityFromFirebase(activity.id);
      activity.id = 'activity_${DateTime.now().millisecondsSinceEpoch}';
      await uploadActivityToFirebase(activity);
      updateLocalActivity(activity);
    }
  }

  Future<String> reorderAndUpdateActivities(
      Activity updatedActivity, int newOrder) async {
    setState(() => isLoading = true); // Start loading

    String updatedActivityId =
        updatedActivity.id; // Store the updated activity's ID

    try {
      int oldIndex = loadedActivities
          .indexWhere((activity) => activity.id == updatedActivity.id);

      if (oldIndex != -1) {
        // Remove the old version of the edited activity
        loadedActivities.removeAt(oldIndex);

        // Insert the updated activity at the new position
        loadedActivities.insert(
            newOrder - 1, updatedActivity); // Adjust for zero-based indexing

        // Correct the order values for all activities
        for (int i = 0; i < loadedActivities.length; i++) {
          loadedActivities[i].order = i + 1; // Orders should start from 1
          if (i == newOrder - 1) {
            updatedActivityId =
                loadedActivities[i].id; // Update the ID after reordering
          }
        }

        // Update activities in Firestore
        for (var activity in loadedActivities) {
          await updateActivityInFirestore(activity);
        }
      }
    } catch (e) {
      debugPrint("An error occurred: $e");
    } finally {
      setState(() => isLoading = false); // Stop loading
    }

    return updatedActivityId; // Return the updated activity ID
  }

  final controller = Get.put(AddActivityController());

  void _addActivity() async {
    setState(() => isLoading = true);
    // Show a dialog to get activity details (name, start date, finish date, and order)
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Add New Activity',
          style: TextStyle(color: Colors.black),
        ),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                hintText: 'Activity Name',
                obscureText: false,
                controller: _newActivityNameController,
                icon: Icons.event,
                keyboardType:
                    TextInputType.text, // Use text input type for name
              ),
              MyDateField(
                  hintText: controller.selectedDate == null
                      ? 'Start Date'
                      : '${DateFormat('dd-MM-yyyy').format(controller.selectedDate!.value)}',
                  callback: controller.SelectDate),
              MyDateField(
                  hintText: controller.endDate == null
                      ? 'End Date'
                      : '${DateFormat('dd-MM-yyyy').format(controller.endDate!.value)}',
                  callback: controller.EndDate),
              MyTextField(
                hintText: 'Order (e.g., 1)',
                obscureText: false,
                controller: _newOrderController,
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // Cancel
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              final newName = _newActivityNameController.text;
              final newOrderText = _newOrderController.text;
              newUserOrder = int.tryParse(newOrderText); // Parse the new order

              if (newName.isNotEmpty &&
                  controller.selectedDate != null &&
                  controller.endDate != null &&
                  newUserOrder != null) {
                // Create the new activity with the specified order
                final newActivity = Activity(
                  id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
                  // Unique ID
                  name: newName,
                  startDate: DateFormat('dd/MM/yyyy')
                      .format(controller.selectedDate!.value),
                  finishDate: DateFormat('dd/MM/yyyy')
                      .format(controller.endDate!.value),
                  order: newUserOrder!,
                );

                Navigator.of(context)
                    .pop(newActivity); // Return the new activity
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please fill all the fields and specify the order')),
                );
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    // If a new activity was added
    if (result != null) {
      newUserOrder = int.tryParse(_newOrderController.text);

      if (newUserOrder != null) {
        // Create a list to track activities whose order changed
        List<Activity> activitiesWithChangedOrder = [];

        // Adjust the order of existing activities
        for (var activity in loadedActivities) {
          if (activity.order >= newUserOrder!) {
            activitiesWithChangedOrder.add(activity);
            activity.order++;
          }
        }

        // Add the new activity and sort the list
        loadedActivities.add(result);
        loadedActivities.sort((a, b) => a.order.compareTo(b.order));

        // Delete and re-upload activities whose order changed
        for (var activity in activitiesWithChangedOrder) {
          await deleteActivityFromFirebase(activity.id);
          await uploadActivityToFirebase(activity);
        }

        // Upload the new activity
        await uploadActivityToFirebase(result);

        // Fetch activities from Firestore
        if (mounted) {
          fetchActivitiesFromFirebase();
        }
      } else {
        ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
          const SnackBar(content: Text('Please specify a valid order number')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false); // Stop loading
    }
  }

  void _noWork() async {
    Activity? todayActivity = findTodaysActivity(loadedActivities);
    if (todayActivity != null) {
      // Get necessary information
      var email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var projId = (await firestore.collection('engineers').doc(email).get()).data()!['projectId'];
      String todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // Create or update document in "No Work" collection
      await firestore.collection('No_Work').doc(todayActivity.id).set({
        'activityName': todayActivity.name,
        'date': todaysDate,
        'projectId': projId,
        'activityId': todayActivity.id,
        'startDate': todayActivity.startDate,
        'finishDate': todayActivity.finishDate,
      });

      // Send notification (optional)
      NotificationCases().scheduleNotification(email!, 'No Work');
    } else {
      print('No activity found for today');
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

  void _deleteActivity() async {
    final Activity? activityToDelete = await showDialog<Activity?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: loadedActivities
                  .map((activity) => Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(activity),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: Text(activity.name,
                              style: TextStyle(color: Colors.black)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );

    if (activityToDelete != null) {
      // Start the loading process
      setState(() => isLoading = true);

      // Delete the activity from Firestore using the ID
      await deleteActivityFromFirebase(activityToDelete.id);

      // Remove the activity from the local state
      setState(() {
        loadedActivities
            .removeWhere((activity) => activity.id == activityToDelete.id);
      });

      // End the loading process
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteActivityFromFirebase(String activityId) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .doc(activityId)
        .delete();
    //------------------------------------------------Sending Notification-------
    NotificationCases().scheduleNotification(email!, 'Deleted');
  }

  @override
  void initState() {
    super.initState();
    fetchActivitiesFromFirebase();
    _initializeTimeZone();
  }

  Future<void> fetchActivitiesFromFirebase() async {
    try {
      var email = FirebaseAuth.instance.currentUser?.email;
//-------------------For Client---------------------------
      var projIdForClient = await FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .get();
      var clientProjectId;
      if (projIdForClient.data() != null) {
        clientProjectId = projIdForClient.data()!['projectId'];
      }
      var sameEngineer = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: clientProjectId)
          .get();
      var engEmails = sameEngineer.docs.map((e) => e.id).toList();
      var activitiesSnapshot = widget.isClient
          ? await FirebaseFirestore.instance
              .collection('engineers')
              .doc(engEmails[0])
              .collection('activities')
              .orderBy('order')
              .get()
          //----------------------------------------------------------------------
          : await FirebaseFirestore.instance
              .collection('engineers')
              .doc(email)
              .collection('activities')
              .orderBy('order') // Sort by order
              .get();

      List<Activity> tempActivities = [];
      for (var doc in activitiesSnapshot.docs) {
        var data = doc.data();
        tempActivities.add(Activity(
            id: data['id'],
            // Use the Firestore document ID as the activity ID
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
    } catch (e) {
      Get.snackbar('Error', '$e', backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future<void> updateActivityInFirestore(Activity updatedActivity) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .doc(updatedActivity.id)
        .update({
      'name': updatedActivity.name,
      'startDate': updatedActivity.startDate,
      'finishDate': updatedActivity.finishDate,
      'order': updatedActivity.order,
    });
  }

  void updateLocalActivity(Activity updatedActivity) {
    int index = loadedActivities
        .indexWhere((activity) => activity.id == updatedActivity.id);
    if (index != -1) {
      setState(() {
        loadedActivities[index] = updatedActivity;
      });
    }
  }

  Future<void> uploadActivityToFirebase(Activity activity) async {
    try {
      var email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var activitiesCollection =
          firestore.collection('engineers').doc(email).collection('activities');

      String sanitizedActivityName =
          activity.name.replaceAll(RegExp(r'[/.#$\[\]]'), '_');
      String documentId =
          '${sanitizedActivityName}_${DateTime.now().millisecondsSinceEpoch}';
      activity.id = documentId; // Set the ID for the activity

      var activityRef = activitiesCollection.doc(documentId);
      await activityRef.set({
        'id': documentId,
        'name': activity.name,
        'startDate': DateFormat('dd/MM/yyyy').parse(activity.startDate),
        'finishDate': DateFormat('dd/MM/yyyy').parse(activity.finishDate),
        'order': activity.order,
        'image': activity.image,
      });
      //------------------------------------------------Sending Notification-------
      NotificationCases().scheduleNotification(email!, 'Updated');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future<void> downloadSampleFile() async {
    try {
      // Check and request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Load the asset
        ByteData data =
            await rootBundle.load('assets/excel/Sample Excel Sheet.xlsx');
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
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

  Future<void> _showExportOptions(BuildContext context) async {
    final ExportFormat? selectedFormat = await showDialog<ExportFormat>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Export Format',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Excel',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop(ExportFormat.excel);
                },
              ),
              ListTile(
                title: const Text(
                  'PDF',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop(ExportFormat.pdf);
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

  Future<void> _exportActivities(ExportFormat format) async {
    try {
      String fileName = 'activities_export.${format.toString().toLowerCase()}';
      List<Activity> activities = loadedActivities;
      String filePath;

      switch (format) {
        case ExportFormat.excel:
          filePath = await _generateExcelExportData(activities);
          break;
        case ExportFormat.pdf:
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
      Get.snackbar('Export Error', 'An error occurred during export: $e', backgroundColor: Colors.white, colorText: Colors.black);
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
        DateTime startDate =
            DateTime.tryParse(activity.startDate) ?? DateTime.now();
        DateTime finishDate =
            DateTime.tryParse(activity.finishDate) ?? DateTime.now();
        sheet.getRangeByIndex(i + 2, 2).setDateTime(startDate);
        sheet.getRangeByIndex(i + 2, 3).setDateTime(finishDate);
      }

      // Construct the file path
      final String? downloadsDirectory =
          (await getExternalStorageDirectory())?.path;
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
      headerRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);

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
      final String? downloadsDirectory =
          (await getExternalStorageDirectory())?.path;
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

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones(); // Load time zone database
  }

  bool isdownloading = false;

  @override
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
    final bool isWorkingDay =
        currentDateTimeInPakistan.weekday != 0; // Sunday = 0, Saturday = 6

    return SingleChildScrollView(
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
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          children: [
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
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          children: [
                            FutureBuilder<int>(
                              future: calculateDayNo(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                      color: Colors
                                          .blue); // Show loading indicator while calculating
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    'Day ${snapshot.data}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                            final formattedDate = DateFormat('d').format(day);
                            print("formatted date = $formattedDate");
                            // Get the abbreviated day name
                            final dayOfWeek =
                                dayNames[(currentDayOfWeek + dayIndex - 1) % 7];
                            // Check if the current day matches today's date
                            final bool isToday = dayIndex == 0;
                            print("is today = $isToday");

                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isToday ? Colors.black : Colors.white,
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
                                      color:
                                          isToday ? Colors.white : Colors.black,
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
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Activities',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    widget.isClient
                        ? Row(
                            children: [
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.black),
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
                                      const PopupMenuItem<String>(
                                        value: 'Download',
                                        child: Text('Download Updated File',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ), // Add a divider
                                    ],
                                    const PopupMenuItem(
                                      value: 'Sample',
                                      child: Text('Download Sample Excel',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ];
                                },
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // IconButton(
                              //   icon: const Icon(Icons.file_upload),
                              //   onPressed: isLoading ? null : pickFile,
                              //   color: const Color(0xFF2CF07F),
                              // ),
                              // IconButton(
                              //   icon: const Icon(Icons.file_download), // Add export icon
                              //   onPressed: isLoading ? null : () => _showExportOptions(context),
                              //   color: Colors.green,
                              // ),
                              // Add the PopupMenuButton
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.black),
                                onSelected: (String choice) {
                                  switch (choice) {
                                    case 'Edit':
                                      _showEditOptions();
                                      break;
                                    case 'Delete':
                                      _deleteActivity();
                                      break;
                                    case 'Sample':
                                      downloadSampleFile();
                                      break;
                                    case 'Add':
                                      _addActivity();
                                      break;
                                    case 'No Work':
                                      _noWork();
                                      break;
                                    case 'Upload':
                                      pickFile();
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
                                        value: 'Edit',
                                        child: Text('Edit Activity',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Delete',
                                        child: Text('Delete Activity',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'Download',
                                        child: Text('Download Updated File',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ), // Add a divider
                                      const PopupMenuItem<String>(
                                        value: 'No Work',
                                        child: Text('No Work Done Today',
                                            style:
                                            TextStyle(color: Colors.black)),
                                      ),
                                    ],
                                    // const PopupMenuItem<String>(
                                    //   value: 'Edit',
                                    //   child: Text('Edit Activity'),
                                    // ),
                                    // const PopupMenuItem<String>(
                                    //   value: 'Delete',
                                    //   child: Text('Delete Activity'),
                                    // ),
                                    const PopupMenuItem<String>(
                                      value: 'Add',
                                      child: Text('Add Activity',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Upload',
                                      child: Text('Upload File',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),

                                    const PopupMenuItem(
                                      value: 'Sample',
                                      child: Text('Download Sample Excel',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ];
                                },
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue))
                  : Column(
                      children: [
                        const SizedBox(height: 10),
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
                                SizedBox(height: 100),
                                Text('No activities to display',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                                SizedBox(height: 16),
                                // widget.isClient
                                //     ? const Text('')
                                //     : Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           ElevatedButton(
                                //             onPressed: _addActivity,
                                //             style: ButtonStyle(
                                //               backgroundColor:
                                //                   MaterialStateProperty.all<
                                //                       Color>(Colors.green),
                                //             ),
                                //             child: const Text('Add Activity',
                                //                 style: TextStyle(
                                //                     color: Colors.black)),
                                //           ),
                                //           const SizedBox(
                                //             width: 10,
                                //           ),
                                //           ElevatedButton(
                                //             onPressed: () async {
                                //               setState(() {
                                //                 isdownloading = true;
                                //               });
                                //               await downloadSampleFile();
                                //
                                //               setState(() {
                                //                 isdownloading = false;
                                //               });
                                //             },
                                //             style: ButtonStyle(
                                //               backgroundColor:
                                //                   MaterialStateProperty.all<
                                //                       Color>(Colors.green),
                                //             ),
                                //             child: isdownloading
                                //                 ? const Padding(
                                //                     padding:
                                //                         EdgeInsets.all(8.0),
                                //                     child:
                                //                         CircularProgressIndicator(
                                //                             color: Colors.blue),
                                //                   )
                                //                 : const Text('Download File',
                                //                     style: TextStyle(
                                //                         color: Colors.black)),
                                //           ),
                                //         ],
                                //       ),
                              ],
                            ),
                          ),
                        // if (loadedActivities.isNotEmpty)
                        //   widget.isClient
                        //       ? const Text('')
                        //       :Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       IconButton(
                        //         icon: const ColorFiltered(
                        //           colorFilter: ColorFilter.mode(
                        //             Colors.green,
                        //             BlendMode.srcIn,
                        //           ),
                        //           child: ImageIcon(AssetImage(
                        //               "assets/images/edit_icon.png")),
                        //         ),
                        //         onPressed: _showEditOptions,
                        //       ),
                        //       IconButton(
                        //         icon: const Icon(Icons.delete),
                        //         color: Colors.green,
                        //         onPressed: _deleteActivity,
                        //       ),
                        //       ElevatedButton(
                        //         onPressed: _addActivity,
                        //         style: ButtonStyle(
                        //           backgroundColor:
                        //               MaterialStateProperty.all<Color>(
                        //                   Colors.green),
                        //         ),
                        //         child: const Text('Add Activity',
                        //             style: TextStyle(color: Colors.black)),
                        //       ),
                        //     ],
                        //   )
                      ],
                    ),
            ],
          )),
    );
  }
}

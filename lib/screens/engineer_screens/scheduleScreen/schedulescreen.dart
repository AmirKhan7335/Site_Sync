import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/engineer_screens/editactivityscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:path/path.dart' as path;

import '../../../components/mytextfield.dart';
import '../../../main.dart';
import '../chatscreen.dart';
import '../detailsscreen.dart';
import '../foundationschedulescreen.dart';
import '../notificationsscreen.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

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
          for (var row in sheet.rows) {
            if (row.length < 3) {
              debugPrint('Skipping row with LESS NO OF COLUMNS.');
              continue;
            }

            // Check if row[0] is a header and skip it
            if (row[0]?.value?.toString().trim() == 'Activity name') {
              debugPrint('Skipping header row');
              continue;
            }

            String name = row[0]?.value?.toString().trim() ?? '';
            // debugPrint('Activity Name: $name');
            String startDate = row[1]?.value?.toString().trim() ?? '';
            String finishDate = row[2]?.value?.toString().trim() ?? '';
            // debugPrint('Start Date String: $startDate');
            // debugPrint('Finish Date String: $finishDate');

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
              id: 'your_unique_identifier', // Update this accordingly
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

  DateTime parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      List<String> formats = [
        'dd/MM/yyyy', // Common date format
        'dd-MM-yyyy',
        'dd-MM-yy',
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

      throw FormatException('Date not in expected format', dateString);
    }
  }

  Future<void> clearActivitiesForCurrentUser() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    var querySnapshot = await FirebaseFirestore.instance
        .collection('schedules')
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

    return InkWell(
      onTap: () {
        if (mainHeading == 'Foundation') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FoundationScheduleScreen(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                mainHeading: mainHeading,
                subHeading: subHeading,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8D9F),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              width: 9.0,
              height: 50,
              color: const Color(0xFFFED36A),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText, // Use the modified display text
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$formattedStartDate - $formattedFinishDate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            backgroundColor: const Color(0xFF6B8D9F),
            title: const Text('Select an Activity to Edit'),
            children: loadedActivities.asMap().entries.map((entry) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToEditScreen(entry.value, entry.key);
                },
                child: Text(entry.value.name),
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
        title: const Text('Add New Activity'),
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
                      : '${controller.selectedDate!.value.toLocal()}'
                          .split(' ')[0],
                  callback: controller.SelectDate),
              MyDateField(
                  hintText: controller.endDate == null
                      ? 'End Date'
                      : '${controller.endDate!.value.toLocal()}'.split(' ')[0],
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
            child: const Text('Cancel'),
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
                  id: 'activity_${DateTime.now().millisecondsSinceEpoch}', // Unique ID
                  name: newName,
                  startDate: controller.selectedDate.toString(),
                  finishDate: controller.endDate.toString(),
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
            child: const Text('Add'),
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

  void _deleteActivity() async {
    final Activity? activityToDelete = await showDialog<Activity?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF6B8D9F),
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: loadedActivities
                  .map((activity) => Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(activity),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(activity.name),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
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
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .doc(activityId)
        .delete();
  }

  @override
  void initState() {
    super.initState();
    fetchActivitiesFromFirebase();
  }

  Future<void> fetchActivitiesFromFirebase() async {
    try {
      print('salam--------------------');
      var email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .doc(email)
          .collection('activities')
          .orderBy('order') // Sort by order
          .get();

      List<Activity> tempActivities = [];
      for (var doc in activitiesSnapshot.docs) {
        var data = doc.data();
        tempActivities.add(Activity(
            id: data['id'], // Use the Firestore document ID as the activity ID
            name: data['name'],
            startDate: data['startDate'],
            finishDate: data['finishDate'],
            order: data['order'],
            image: data['image']));
      }

      setState(() {
        loadedActivities = tempActivities;
      });
    } catch (e) {
      Get.snackbar('Error', '${e}');
    }
  }

  Future<void> updateActivityInFirestore(Activity updatedActivity) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('schedules')
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
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var activitiesCollection =
        firestore.collection('schedules').doc(email).collection('activities');

    String sanitizedActivityName =
        activity.name.replaceAll(RegExp(r'[/.#$\[\]]'), '_');
    String documentId =
        '${sanitizedActivityName}_${DateTime.now().millisecondsSinceEpoch}';
    activity.id = documentId; // Set the ID for the activity

    var activityRef = activitiesCollection.doc(documentId);
    await activityRef.set({
      'id': documentId,
      'name': activity.name,
      'startDate': activity.startDate,
      'finishDate': activity.finishDate,
      'order': activity.order,
      'image': activity.image,
    });
  }

  downloadSampleFile() async {
    try {
      String url =
          'https://firebasestorage.googleapis.com/v0/b/amir-e8895.appspot.com/o/sample.xlsx?alt=media&token=068351f0-2bc9-4cfd-b46a-ea609d3e69a0';

      // Get the Excel file download URL from Firebase Storage

      // Check and request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        var response = await http.get(Uri.parse(url));
        var downloadsPath = await Directory("/storage/emulated/0/Download");
        File file = File(path.join(downloadsPath!.path, 'sampleFile.xlsx'));

        file.writeAsBytesSync(response.bodyBytes);

        Get.snackbar('Sample File Downloaded', '');
      } else {
        // Handle permission denied
        Get.snackbar('Permission Denied', '');
      }
    } catch (e) {
      Get.snackbar('Error', '${e.toString()}');
    }
  }

  bool isdownloading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          //height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 32,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                        child: Text(
                      'Schedule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    )),
                    IconButton(
                      icon: const Icon(Icons.file_upload),
                      onPressed: isLoading ? null : pickFile,
                      color: const Color(0xFFFED36A),
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
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No activities to display',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _addActivity,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.yellow),
                                      ),
                                      child: const Text('Add Activity',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isdownloading = true;
                                        });
                                        await downloadSampleFile();

                                        setState(() {
                                          isdownloading = false;
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.yellow),
                                      ),
                                      child: isdownloading
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                color: Colors.black,
                                              ),
                                            )
                                          : Text('Download File',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (loadedActivities.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.yellow,
                                    BlendMode.srcIn,
                                  ),
                                  child: ImageIcon(AssetImage(
                                      "assets/images/edit_icon.png")),
                                ),
                                onPressed: _showEditOptions,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.yellow,
                                onPressed: _deleteActivity,
                              ),
                              ElevatedButton(
                                onPressed: _addActivity,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.yellow),
                                ),
                                child: const Text('Add Activity',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          )
                      ],
                    ),
            ],
          )),
    );
  }
}

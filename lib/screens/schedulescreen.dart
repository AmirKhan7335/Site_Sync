import 'package:amir_khan1/screens/taskdetailsscreen.dart';
import 'package:amir_khan1/screens/editactivityscreen.dart';
import 'package:amir_khan1/screens/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import '../components/mytextfield.dart';
import '../main.dart';
import 'chatscreen.dart';
import 'detailsscreen.dart';
import 'foundationschedulescreen.dart';
import 'notificationsscreen.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  List<Activity> activities = [];
  bool isLoading = false;
  static List<Activity> loadedActivities = [];
  int? newUserOrder;
  bool isSaving = false; // Add a variable to track saving/uploading state
  // Define TextEditingController variables
  final TextEditingController _newOrderController = TextEditingController();
  final TextEditingController _newActivityNameController = TextEditingController();
  final TextEditingController _newActivityStartDateController = TextEditingController();
  final TextEditingController _newActivityFinishDateController = TextEditingController();

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

  // This method needs to be updated to handle reordering of activities
  Future<void> reorderActivities(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final Activity item = loadedActivities.removeAt(oldIndex);
    loadedActivities.insert(newIndex, item);

    // Update the order in Firestore for all activities
    for (int i = 0; i < loadedActivities.length; i++) {
      loadedActivities[i].order = i;
      await uploadActivityToFirebase(loadedActivities[i]);
    }

    setState(() {});
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
        int order = 0; // Initialize the order counter

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
            debugPrint('Activity Name: $name');
            String startDate = row[1]?.value?.toString().trim() ?? '';
            String finishDate = row[2]?.value?.toString().trim() ?? '';
            debugPrint('Start Date String: $startDate');
            debugPrint('Finish Date String: $finishDate');


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

            // Convert to 'dd-MM-yy' format for displaying
            String formattedStartDate = DateFormat('dd-MM-yyyy').format(startDateParsed);
            String formattedFinishDate = DateFormat('dd-MM-yyyy').format(finishDateParsed);

            var activity = Activity(
              name: name,
              startDate: formattedStartDate,
              finishDate: formattedFinishDate,
              order: order++, // Assign and increment the order
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
    List<String> formats = [
      'yyyy-MM-ddTHH:mm:ss.000', // ISO 8601 format
      'dd/MM/yyyy', // Common date format
      'dd-MM-yyyy', 'dd-MM-yy', '44945'// Common date format
      // Add more formats as needed
    ];
    for (String format in formats) {
      try {
        final DateFormat formatter = DateFormat(format);
        return formatter.parseStrict(dateString); // Use strict parsing
      } catch (e) {
        // Continue to next format if parsing fails
      }
    }
    throw FormatException('Date not in expected format', dateString);
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

  Widget _buildActivityContainer(Activity activity, String mainHeading, String subHeading) {
    // Use a pattern like "1. Foundation" for displaying the activity name
    String displayText = '${activity.order + 1}. ${capitalize(activity.name)}';

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
              builder: (context) =>
                  DetailsScreen(
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
              color: const Color (0xFFFED36A),
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
                    subHeading,
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
            setState(() => isSaving = true);

            // Determine if the order has changed and needs reordering
            if (newOrder != null && newOrder != selectedActivity.order) {
              // Reorder activities and update Firestore
              await reorderAndUpdateActivities(updatedActivity, newOrder);
            } else {
              // If the order hasn't changed, just update the details
              await uploadActivityToFirebase(updatedActivity);
            }

            // End the loading process
            setState(() {
              loadedActivities[index] = updatedActivity;
              isSaving = false;
            });
          },
        ),
      ),
    );
    setState(() {
      loadedActivities[index] = updatedActivity!;
      isSaving = false;
    });
  }
  Future<void> reorderAndUpdateActivities(Activity updatedActivity, int newOrder) async {
    setState(() => isLoading = true); // Start loading

    try {
      // Find the old index of the activity that is being updated
      int oldIndex = loadedActivities.indexWhere((activity) => activity.name == updatedActivity.name);

      if (oldIndex == -1) {
        debugPrint("Activity not found in the list");
        return;
      }

      // Adjust the newOrder if necessary
      if (newOrder > oldIndex) {
        newOrder--;
      }

      // Update the order of the existing activities
      for (int i = 0; i < loadedActivities.length; i++) {
        if (i >= newOrder && i != oldIndex) {
          loadedActivities[i].order++;
        } else if (i > oldIndex && newOrder <= oldIndex) {
          loadedActivities[i].order--;
        }
      }

      // Remove the old version of the edited activity from Firestore
      await deleteActivityFromFirebasee(loadedActivities[oldIndex].name);

      // Remove the old version of the edited activity from the list
      loadedActivities.removeAt(oldIndex);

      // Update the order of the edited activity
      updatedActivity.order = newOrder;

      // Insert the updated activity at the correct position
      loadedActivities.insert(newOrder, updatedActivity);

      // Update activities in Firestore
      for (var activity in loadedActivities) {
        await uploadActivityToFirebase(activity);
        if (kDebugMode) {
          print("Updated Activity in Firestore: Name: ${activity.name}, Order: ${activity.order}");
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      // Handle exceptions if any
      debugPrint("An error occurred: $e");
    } finally {
      setState(() => isLoading = false); // Stop loading
    }
  }

  Future<void> deleteActivityFromFirebasee(String activityName) async {
    // Assuming you are using activity names as Firestore document IDs
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .doc(activityName)
        .delete();
  }


  void _addActivity() async {
    // Show a dialog to get activity details (name, start date, finish date, and order)
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add New Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextField(
              hintText: 'Activity Name',
              obscureText: false,
              controller: _newActivityNameController,
              icon: Icons.event, keyboardType: TextInputType.text, // Use text input type for name
            ),
            MyTextField(
              hintText: 'Start Date',
              obscureText: false,
              controller: _newActivityStartDateController,
              icon: Icons.date_range, keyboardType: TextInputType.number,
            ),
            MyTextField(
              hintText: 'Finish Date',
              obscureText: false,
              controller: _newActivityFinishDateController,
              icon: Icons.date_range, keyboardType: TextInputType.number,
            ),
            MyTextField(
              hintText: 'Order (e.g., 1)',
              obscureText: false,
              controller: _newOrderController, // Add a TextEditingController for order
              icon: Icons.format_list_numbered, keyboardType: TextInputType.number, // Provide an icon for order
            )
          ],
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
              final newStartDate = _newActivityStartDateController.text;
              final newFinishDate = _newActivityFinishDateController.text;
              if (newName.isNotEmpty &&
                  newStartDate.isNotEmpty &&
                  newFinishDate.isNotEmpty &&
                  newUserOrder != null) {
                // Create the new activity with the specified order
                final newActivity = Activity(
                  name: newName,
                  startDate: newStartDate,
                  finishDate: newFinishDate,
                  order: newUserOrder!,
                );

                // Adjust the order of existing activities as needed
                for (int i = 0; i < loadedActivities.length; i++) {
                  final activity = loadedActivities[i];
                  if (activity.order >= newUserOrder!) {
                    activity.order++; // Increment order for existing activities after the new one
                  }
                }

                Navigator.of(context).pop(newActivity); // Return the new activity
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all the fields and specify the order')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    // If a new activity was added, update Firestore and the local list
    if (result != null) {
      await uploadActivityToFirebase(result);
      setState(() {
        loadedActivities.add(result);
      });
    }
  }

  void _deleteActivity() async {
    final Activity? confirmed = await showDialog<Activity?>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF6B8D9F), // Set background color
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)), // Set title text color
        content: SingleChildScrollView(
          child: ListBody(
            children: loadedActivities.map((activity) => Align(
              alignment: Alignment.centerLeft, // Align to the left
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(activity),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, alignment: Alignment.centerLeft, // Align text to the left
                ),
                child: Text(activity.name),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Set text color of actions
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != null) {
      await deleteActivityFromFirebase(confirmed.name);

      // Adjust the order of existing activities after deletion
      loadedActivities.remove(confirmed);
      for (int i = 0; i < loadedActivities.length; i++) {
        final activity = loadedActivities[i];
        if (activity.order > confirmed.order) {
          activity.order--;
        }
      }

      setState(() {});
    }
  }



  Future<void> deleteActivityFromFirebase(String activityName) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    String sanitizedActivityName = activityName.replaceAll(RegExp(r'[/.#$\[\]]'), '_');
    var activityRef = FirebaseFirestore.instance
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .doc(sanitizedActivityName);
    await activityRef.delete();
  }

  @override
  void initState() {
    super.initState();
    fetchActivitiesFromFirebase();
  }

  Future<void> fetchActivitiesFromFirebase() async {
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
        name: data['name'],
        startDate: data['startDate'],
        finishDate: data['finishDate'],
        order: data['order'], // Include the 'order' field from Firestore
      ));
    }

    setState(() {
      loadedActivities = tempActivities;
    });
  }

  Future<void> uploadActivityToFirebase(Activity activity) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var activitiesCollection = firestore.collection('schedules').doc(email).collection('activities');

    // Start a batch write
    WriteBatch batch = firestore.batch();

    // Delete all existing activities
    var querySnapshot = await activitiesCollection.get();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Add all activities from the updated list
    for (var activity in loadedActivities) {
      String sanitizedActivityName = activity.name.replaceAll(RegExp(r'[/.#$\[\]]'), '_');
      String documentId = '${sanitizedActivityName}_${DateTime.now().millisecondsSinceEpoch}';

      var activityRef = activitiesCollection.doc(documentId);

      batch.set(activityRef, {
        'id': documentId,
        'name': activity.name,
        'startDate': activity.startDate,
        'finishDate': activity.finishDate,
        'order': activity.order,
      });
    }

    // Commit the batch write
    await batch.commit();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Schedule')),
        backgroundColor: const Color(0xFF212832),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: isLoading ? null : pickFile,
            color: const Color(0xFFFED36A),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF212832),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 10),
          if (loadedActivities.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
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
          ),
        if (loadedActivities.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No activities to display', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addActivity,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: const Text('Add Activity', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
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
                    child: ImageIcon(AssetImage("assets/images/edit_icon.png")),
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
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                  ),
                  child: const Text('Add Activity', style: TextStyle(color: Colors.black)),
                ),
              ],
            )
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        currentIndex: 3,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const ChatScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TaskDetailsScreen();
            }));
          } else if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'My Home Page')));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const ScheduleScreen()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 30.0),
                ),
              ),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        iconSize: 20.0,
      ),
    );
  }
}


import 'package:amir_khan1/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProjectProgressController extends GetxController {
  RxInt overAllPercent1 = 0.obs;
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

  Future<int> calculateOverallPercent(List<Activity> activities) async {
    try {
      DateTime today1 = DateTime.now();
      String formattedToday1 =
      DateFormat('dd/MM/yyyy').format(today1);
      DateTime todayDate1 = DateFormat('dd/MM/yyyy')
          .parse(formattedToday1);
      DateTime today = DateTime.now();
      int totalDuration = 0;
      for (int i = 0; i < activities.length; i++) {
        DateTime parsedStartDate = parseDate(activities[i].startDate);
        DateTime parsedFinishDate = parseDate(activities[i].finishDate);
        int activityDuration =
            parsedFinishDate.difference(parsedStartDate).inDays + 1;
        print("activity duration = $activityDuration");
        totalDuration += activityDuration;
        print("total duration = $totalDuration");
      }
      double completedActivitiesPercentages = 0;
      int todaysactivityduration = 0;

      for (int i = 0; i < activities.length; i++) {
        DateTime parsedStartDate = parseDate(activities[i].startDate);
        DateTime parsedFinishDate = parseDate(activities[i].finishDate);
        int activityDuration =
            parsedFinishDate.difference(parsedStartDate).inDays + 1;

        for (var activity in activities) {
          if (activity.name == findTodaysActivity(activities)?.name) {
            todaysactivityduration = activityDuration;
            break; // Break out of the loop once a match is found
          }
        }

        if (parsedFinishDate.isBefore(todayDate1)) {
          // Activity is completed
          double percentComplete = (activityDuration / totalDuration) * 100;
          print("parsed finishe");
          print("percent complete = $percentComplete");
          completedActivitiesPercentages += percentComplete;
          print("completed activities percentages = $completedActivitiesPercentages");
        }
      }


      // Find today's activity and calculate its percentage
      Activity? todayActivity = findTodaysActivity(activities);
      if (todayActivity != null
      // && todayActivity.finishDate !=
          //     DateFormat('dd/MM/yyyy').format(DateTime.now())
      ) {
        int todayActivityPercent = calculatePercentComplete(
          todayActivity.startDate,
          todayActivity.finishDate,
        );
        // Calculate the contribution of today's activity to the overall percentage
        int todayContribution =
            ((todayActivityPercent) * (todaysactivityduration / totalDuration))
                .round();

        completedActivitiesPercentages += todayContribution.round();
      }

      overAllPercent1.value = completedActivitiesPercentages.round();

      var email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var engineersCollection = firestore.collection('engineers');
      var consultantEmail;
      var projectID;

      try {
        DocumentSnapshot engineerDoc = await engineersCollection.doc(email).get();
        if (engineerDoc.exists) {
          // If document exists, retrieve the consultantEmail field
          consultantEmail = engineerDoc.get('consultantEmail');
          projectID = engineerDoc.get('projectId');
          if (kDebugMode) {
            print('Consultant email: $consultantEmail');
          }
        } else {
          if (kDebugMode) {
            print('Engineer document with email $email does not exist.');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching consultant email: $e');
        }
      }

      await uploadOverallPercentToProject(projectID, overAllPercent1.value);

    } catch (e) {
      // Handle the error, log it, or display an error message
    }
    return overAllPercent1.value;
  }

  Future<void> uploadOverallPercentToProject(String projectID, int overallPercent) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the project document using the provided project ID
      DocumentReference projectDocRef = firestore.collection('Projects').doc(projectID);

      // Update the overall percent value in the project document
      await projectDocRef.update({'overallPercent': overallPercent});
      if (kDebugMode) {
        print('overall progress value = $overallPercent');
      }
      if (kDebugMode) {
        print('Overall percent uploaded successfully to the project document with ID: $projectID');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading overall percent to project document: $e');
      }
    }
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

  fetchActivities(id) async {
    try {
      final engEmailQuery = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: id)
          .get();
      final email = engEmailQuery.docs.map((e) => e.id).toList();
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(email[0])
          .collection('activities')
          .get();

      // Convert documents to Activity objects
      List<Activity> activities = activitiesSnapshot.docs.map((doc) {
        return Activity(
          id: doc['id'],
          name: doc['name'],
          startDate: DateFormat('dd/MM/yyyy').format(doc['startDate'].toDate()),
          finishDate:
              DateFormat('dd/MM/yyyy').format(doc['finishDate'].toDate()),
          order: doc['order'],
        );
      }).toList();
      calculateOverallPercent(activities);
    } catch (e) {
      
      
    debugPrint(e.toString());
      return [];
    }
  }

  fetchContrActivities(id) async {
    try {
      final engEmailQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .where('projectId', isEqualTo: id)
          .get();
      final email = engEmailQuery.docs.map((e) => e.id).toList();
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(email[0])
          .collection('activities')
          .get();

      // Convert documents to Activity objects
      List<Activity> activities = activitiesSnapshot.docs.map((doc) {
        return Activity(
          id: doc['id'],
          name: doc['name'],
          startDate: DateFormat('dd/MM/yyyy').format(doc['startDate'].toDate()),
          finishDate:
              DateFormat('dd/MM/yyyy').format(doc['finishDate'].toDate()),
          order: doc['order'],
        );
      }).toList();
      calculateOverallPercent(activities);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }
}

import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/pages/profile_page.dart';
import 'package:amir_khan1/pages/users_page.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/screens/engineer_screens/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/createaccountscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/schedulescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/signinscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/splashscreen.dart';
import 'package:amir_khan1/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/auth.dart';
import 'components/my_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

// ctrl+alt+l = format code
// signin screen = log in page
// create account screen =  register page
// signup or createaccount = login or register page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/profile_page': (context) => const ProfilePage(),
        '/users_page': (context) => const UsersPage(),
        '/auth': (context) => const AuthPage(),
        '/engineer_home': (context) => const EngineerHomePage(),
        '/signin': (context) => SigninScreen(
              onTap: () {},
            ),
        '/createaccount': (context) => CreateAccountScreen(
              onTap: () {},
            ),
        '/role': (context) => const Role(),
        '/chat': (context) => const ChatScreen(),
        // '/taskdetails': (context) => const TaskDetailsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

Widget buildIndicator(int index, int currentPage) {
  return Container(
    margin: const EdgeInsets.all(4.0),
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: index == currentPage ? Colors.blue : Colors.grey,
    ),
  );
}

class EngineerHomePage extends StatefulWidget {
  const EngineerHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<EngineerHomePage> {
  int currentPage = 0;
  int currentIndex = 0; // Index of the selected tab
  int overAllPercent = 0;
  final PageController pageController = PageController();
  final user = FirebaseAuth.instance.currentUser;
  List<Activity> activities = []; // Store activities here

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

  Future<List<Activity>> fetchActivities() async {
    var email = user?.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .get();

    // Convert documents to Activity objects
    return activitiesSnapshot.docs.map((doc) {
      return Activity(
        id: doc['id'],
        name: doc['name'],
        startDate: DateFormat('dd/MM/yyyy').format(parseDate(doc['startDate'])),
        finishDate:
            DateFormat('dd/MM/yyyy').format(parseDate(doc['finishDate'])),
        order: doc['order'],
      );
    }).toList();
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

  Activity? findUpcomingActivity(List<Activity> activities) {
    DateTime today = DateTime.now();
    Activity? upcomingActivity;

    try {
      upcomingActivity = activities
          .where((activity) => parseDate(activity.startDate).isAfter(today))
          .reduce((a, b) =>
              parseDate(a.startDate).isBefore(parseDate(b.startDate)) ? a : b);
    } catch (e) {
      // Handle the case where no upcoming activity is found
      upcomingActivity = Activity(
        id: 'dummy',
        name: 'No Upcoming Activity',
        startDate: 'N/A',
        finishDate: 'N/A',
        order: 0,
      );
    }

    return upcomingActivity;
  }

  int calculateDaysLeft(String finishDate) {
    try {
      DateTime parsedFinishDate = parseDate(finishDate);
      DateTime today = DateTime.now();

      // Calculate the difference in days
      int daysDifference = parsedFinishDate.difference(today).inDays;

      if (today.hour < 12) {
        daysDifference += 1;
      }

      if (daysDifference < 0) {
        return 0; // The finish date is in the past, no days left
      } else {
        return daysDifference + 1; // Add 1 to include the due date
      }
    } catch (e) {
      return -1; // Return a default value or handle the error accordingly
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

  int calculateOverallPercent(List<Activity> activities) {
    try {
      DateTime today = DateTime.now();
      int totalDuration = 0;
      for (int i = 0; i < activities.length; i++) {
        DateTime parsedStartDate = parseDate(activities[i].startDate);
        DateTime parsedFinishDate = parseDate(activities[i].finishDate);
        int activityDuration =
            parsedFinishDate.difference(parsedStartDate).inDays + 1;
        totalDuration += activityDuration;
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

        if (parsedFinishDate.isBefore(today)) {
          // Activity is completed
          double percentComplete = (activityDuration / totalDuration) * 100;
          completedActivitiesPercentages += percentComplete;
        }
      }

      // Find today's activity and calculate its percentage
      Activity? todayActivity = findTodaysActivity(activities);
      if (todayActivity != null &&
          todayActivity.finishDate !=
              DateFormat('dd/MM/yyyy').format(DateTime.now())) {
        int todayActivityPercent = calculatePercentComplete(
          todayActivity.startDate,
          todayActivity.finishDate,
        );
        // Calculate the contribution of today's activity to the overall percentage
        int todayContribution =
            (todayActivityPercent * (todaysactivityduration / totalDuration))
                .round();

        completedActivitiesPercentages += todayContribution.round();
      }

      // Update the state with the overall percentage
      setState(() {
        overAllPercent = completedActivitiesPercentages.round();
      });
    } catch (e) {
      // Handle the error, log it, or display an error message
    }
    return overAllPercent;
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

  Future<UserData> fetchData() async {
    final username = await fetchUsername();
    final profilePicUrl = await fetchProfilePicUrl();
    final activities = await fetchActivities();

    return UserData(
      username: username,
      profilePicUrl: profilePicUrl,
      activities: activities,
    );
  }

  Future<String?> fetchProfilePicUrl() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['profilePic'];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile picture: $e');
      }
      return null;
    }
  }

  Widget engineerHomeTab(data) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Home Page',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<UserData>(
                  // Fetch the username asynchronously
                  future: data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.blue));
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final userData = snapshot.data!;
                      final snapshotData = userData.activities;
                      List<Activity> activities = snapshotData ?? [];
                      // Find today's and upcoming activities
                      Activity? todayActivity = findTodaysActivity(activities);
                      Activity? upcomingActivity =
                          findUpcomingActivity(activities);
                      overAllPercent = calculateOverallPercent(activities);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User information
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.yellow),
                                  ),
                                  const SizedBox(height: 0),
                                  Text(
                                    snapshot.data?.username ?? 'Guest',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              CircleAvatar(
                                backgroundImage: snapshot.data?.profilePicUrl !=
                                        null
                                    ? NetworkImage(
                                        snapshot.data!.profilePicUrl!)
                                    : const NetworkImage(
                                        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                                radius: 30,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Search bar
                          const SizedBox(
                            height: 48.0,
                            child: Center(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        hintText: "Search",
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.white),
                                        filled: true,
                                        fillColor: Color(0xFF6B8D9F),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Page view with indicators
                          StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    PageView(
                                      physics: const BouncingScrollPhysics(),
                                      controller: pageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          currentPage = index;
                                        });
                                      },
                                      children: [
                                        PageOne(
                                            startDate: todayActivity?.startDate,
                                            endDate: todayActivity?.finishDate,
                                            activityProgress: overAllPercent),
                                        const PageTwo(),
                                        const PageThree(),
                                      ],
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0; i < 3; i++)
                                            buildIndicator(i, currentPage),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          // Today's activity
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Today's activity",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 10, bottom: 16, right: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B8D9F),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      todayActivity?.name ?? 'No Activity',
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    // const SizedBox(width: 80),
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          activities.isNotEmpty
                                              ? (todayActivity != null
                                                  ? (calculateDaysLeft(
                                                              todayActivity
                                                                  .finishDate) ==
                                                          1
                                                      ? 'Last Day'
                                                      : '${calculateDaysLeft(todayActivity.finishDate)} Days left')
                                                  : 'No Activity')
                                              : '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      activities.isNotEmpty
                                          ? 'Due: ${todayActivity?.finishDate ?? "No Due Date"}'
                                          : 'No Due Date',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 45),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 140,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    todayActivity?.finishDate !=
                                                            null
                                                        ? "Completed"
                                                        : "",
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                                Text(
                                                  todayActivity?.finishDate !=
                                                          null
                                                      ? '${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%'
                                                      : '0%',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 146,
                                              child: LinearProgressIndicator(
                                                value: todayActivity
                                                            ?.finishDate !=
                                                        null
                                                    ? (calculatePercentComplete(
                                                            todayActivity
                                                                    ?.startDate ??
                                                                "",
                                                            todayActivity
                                                                    ?.finishDate ??
                                                                "") /
                                                        100)
                                                    : 0,
                                                backgroundColor: Colors.grey,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Upcoming activity
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Upcoming activity",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 10, bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B8D9F),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upcomingActivity?.name ??
                                      'No Upcoming Activity',
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      activities.isNotEmpty
                                          ? 'Starts: ${upcomingActivity?.startDate ?? "No Start Date"}'
                                          : 'No Start Date',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = fetchData();
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: const Color(0xFF212832),
      body: currentIndex == 1
          ? ChatScreen()
          : currentIndex == 2
              ? Placeholder()
              : currentIndex == 0
                  ? engineerHomeTab(data)
                  : currentIndex == 3
                      ? const ScheduleScreen()
                      : const NotificationsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
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
              padding: const EdgeInsets.all(0.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 56.0,
                  height: 36.0,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 30.0),
                ),
              ),
            ),
            label: 'Camera',
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

class UserData {
  final String username;
  final String? profilePicUrl;
  final List<Activity>? activities;

  UserData({required this.username, this.profilePicUrl, this.activities});

  @override
  String toString() {
    return username;
  }
}
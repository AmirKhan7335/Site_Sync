import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/screens/consultant_screens/ConsultantSchedule.dart';
import 'package:amir_khan1/screens/consultant_screens/addProjectScreen.dart';
import 'package:amir_khan1/screens/consultant_screens/progressPage.dart';
import 'package:amir_khan1/screens/consultant_screens/requestPage.dart';
import 'package:amir_khan1/screens/consultant_screens/scheduledProjects.dart';
import 'package:amir_khan1/screens/consultant_screens/widgets/statusContainer.dart';
import 'package:amir_khan1/screens/engineer_screens/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultantHomePage extends StatefulWidget {
  const ConsultantHomePage({super.key});

  @override
  ConsultantHomePageState createState() => ConsultantHomePageState();
}

class ConsultantHomePageState extends State<ConsultantHomePage> {
  
  final PageController pageController = PageController();
  final user = FirebaseAuth.instance.currentUser;
  int currentConsultantIndex = 0;
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

  Future<ConsultantUserData> fetchData() async {
    final username = await fetchUsername();
    final profilePicUrl = await fetchProfilePicUrl();
    // final activities = await fetchActivities();

    return ConsultantUserData(
      username: username,
      profilePicUrl: profilePicUrl,
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

  Future<List> fetchProjects() async {
//..
    final collectionData =
        await FirebaseFirestore.instance.collection('Projects').get();
    final userData = collectionData.docs.map(
      (doc) {
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location']
        ];
      },
    ).toList();
    return userData;
//..
  }

  Widget ConsultantHomeTab(data) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Consultant Page',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<ConsultantUserData>(
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
                          const SizedBox(height: 20),
                          // Page view with indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusContainer(
                                  icon: Icons.calendar_today,
                                  count: 0,
                                  text: 'Projects'),
                              StatusContainer(
                                  icon: Icons.done_outline,
                                  count: 0,
                                  text: 'Completed'),
                              StatusContainer(
                                  icon: Icons.work, count: 0, text: 'Ongoing'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Today's activity

                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 10, bottom: 16, right: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProgressPage()));
                                  },
                                  child: Text('Progress',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ),
                                Container(
                                  height: 30,
                                  width: 1.5,
                                  color: Colors.yellow,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RequestPage()));
                                  },
                                  child: Text(
                                    'Request',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Upcoming activity
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Recently Added",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 200,
                            child: FutureBuilder(
                                future: fetchProjects(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text('No Projects Added');
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else {
                                    final projectList = snapshot.data;

                                    return ListView.builder(
                                        itemCount: projectList!.length,
                                        itemBuilder: ((context, index) =>
                                            Padding(
                                              padding: const EdgeInsets.only(bottom:16.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(16.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 8.0, bottom: 8.0),
                                                  child: ListTile(
                                                    title: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                size: 15,
                                                                color: Colors
                                                                    .yellow),
                                                            Text(
                                                                projectList[index]
                                                                    [3]),
                                                            Text(' - '),
                                                            Text(
                                                                projectList[index]
                                                                    [4]),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .location_on_outlined,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .yellow),
                                                                Text(projectList[
                                                                    index][5]),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            projectList[index][0],
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 25,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.person,
                                                                color: Colors
                                                                    .yellow),
                                                            Text(
                                                                projectList[index]
                                                                    [2]),
                                                            Expanded(
                                                              child: SizedBox(
                                                                
                                                              ),
                                                            ),
                                                            Text(
                                                              'Rs ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .yellow),
                                                            ),
                                                            Text(
                                                                projectList[index]
                                                                    [1]),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )));
                                  }
                                }),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
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
      body: currentConsultantIndex == 1
          ? ChatScreen()
          : currentConsultantIndex == 2
              ? CreateProject()
              : currentConsultantIndex == 0
                  ? ConsultantHomeTab(data)
                  : currentConsultantIndex == 3
                      ? const ScheduleProjects()
                      : const NotificationsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        currentIndex: currentConsultantIndex,
        onTap: (int index) {
          setState(() {
            currentConsultantIndex = index;
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
                  child: const Icon(Icons.add_box_outlined,
                      color: Colors.black, size: 30.0),
                ),
              ),
            ),
            label: '',
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

class ConsultantUserData {
  final String username;
  final String? profilePicUrl;

  ConsultantUserData({
    required this.username,
    this.profilePicUrl,
  });

  @override
  String toString() {
    return username;
  }
}

import 'package:amir_khan1/controllers/projectsCountingController.dart';
import 'package:amir_khan1/screens/consultant_screens/consultantHome.dart';
import 'package:amir_khan1/screens/consultant_screens/progressPage.dart';
import 'package:amir_khan1/screens/consultant_screens/requestPage.dart';
import 'package:amir_khan1/screens/consultant_screens/widgets/statusContainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConsultantHomeTab extends StatefulWidget {
  const ConsultantHomeTab({super.key});

  @override
  State<ConsultantHomeTab> createState() => _ConsultantHomeTabState();
}

class _ConsultantHomeTabState extends State<ConsultantHomeTab> {
  @override
  void initState() {
    super.initState();
    countProject();
  }

  countProject() async {
    final countController = Get.put(ProjectCountingController());
    var one = await fetchAllProjects();
    var two = await fetchOngoingProjects();
    var three = await fetchCompletedProjects();

    countController.totalProjects.value = one;
    countController.ongoingProjects.value = two;
    countController.completedProjects.value = three;
  }

  final user = FirebaseAuth.instance.currentUser;
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

  Future<int> fetchCompletedProjects() async {
    try {
      DateTime currentDate = DateTime.now();

      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('endDate', isLessThan: Timestamp.fromDate(currentDate))
          .get();

      final userData = collectionData.docs.length;

      return userData;
    } catch (e) {
      Get.snackbar('Error', e.toString());

      return 0;
    }
  }

  Future<List> fetchRecentProjects() async {
//..
    DateTime fifteenDaysAgo = DateTime.now().subtract(Duration(days: 15));

    final collectionData = await FirebaseFirestore.instance
        .collection('Projects')
        .where('creationDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fifteenDaysAgo))
        .orderBy('creationDate', descending: true)
        .get();
    final userData = collectionData.docs.map(
      (doc) {
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location'],
          doc['creationDate']
        ];
      },
    ).toList();

    return userData;
//..
  }

  Future<int> fetchOngoingProjects() async {
    DateTime currentDate = DateTime.now();

    final collectionData = await FirebaseFirestore.instance
        .collection('Projects')
        // .where('startDate',
        //     isLessThanOrEqualTo: Timestamp.fromDate(currentDate))
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
        .get();

    final userData = collectionData.docs.length;

    return userData;
  }

  Future<int> fetchAllProjects() async {
    try {
      DateTime currentDate = DateTime.now();

      final collectionData =
          await FirebaseFirestore.instance.collection('Projects').get();

      final userData = collectionData.docs.length;

      return userData;
    } catch (e) {
      Get.snackbar('Error', e.toString());

      return 0;
    }
  }

  Widget head(data) {
    
    final countController = Get.put(ProjectCountingController());
    return Column(
      children: [
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
                        IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: Icon(Icons.menu)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back!",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.yellow),
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
                          backgroundImage: snapshot.data?.profilePicUrl != null
                              ? NetworkImage(snapshot.data!.profilePicUrl!)
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
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10.0),
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.white),
                                  filled: true,
                                  fillColor: Color(0xFF6B8D9F),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
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
                   Obx(
                     ()=> Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusContainer(
                            icon: Icons.calendar_today,
                            count: countController.totalProjects.value,
                            text: 'Projects',
                            callback: () {},
                          ),
                          StatusContainer(
                            icon: Icons.done_outline,
                            count: countController.completedProjects.value,
                            text: 'Completed',
                            callback: () {},
                          ),
                          StatusContainer(
                            icon: Icons.work,
                            count: countController.ongoingProjects.value,
                            text: 'Ongoing',
                            callback: () {},
                          ),
                        ],
                      ),
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
                                    fontWeight: FontWeight.bold, fontSize: 20)),
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
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget projects() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder(
          future: fetchRecentProjects(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('No Projects Added');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
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
                  itemBuilder: ((context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month,
                                          size: 15, color: Colors.yellow),
                                      Text(DateFormat('dd-MM-yyyy')
                                          .format(
                                              projectList[index][3].toDate())
                                          .toString()),
                                      Text(' to '),
                                      Text(DateFormat('dd-MM-yyyy')
                                          .format(
                                              projectList[index][4].toDate())
                                          .toString()),
                                      Expanded(child: SizedBox()),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              size: 15, color: Colors.yellow),
                                          Text(projectList[index][5]),
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      projectList[index][0],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.yellow),
                                      Text(projectList[index][2]),
                                      Expanded(
                                        child: SizedBox(),
                                      ),
                                      Text(
                                        'Rs ',
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                      Text(projectList[index][1]),
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
    );
  }

  final ScrollController _scrollController = ScrollController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final data = fetchData();
    return SafeArea(
        key: scaffoldKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Column(
                        children: <Widget>[head(data)],
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ];
            },
            body: projects(),
          ),
        ));
  }
}

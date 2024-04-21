import 'package:amir_khan1/controllers/projectsCountingController.dart';
import 'package:amir_khan1/screens/centralBarScreens/documentScreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/projectScreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/TestingTab/testingScreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/siteCamera/inputRtsp.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/chooseProject.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/consltDocuments.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltTest/chooseProj.dart';
import 'package:amir_khan1/screens/consultant_screens/consultantHome.dart';
import 'package:amir_khan1/screens/consultant_screens/progressPage.dart';
import 'package:amir_khan1/screens/consultant_screens/requestPage.dart';
import 'package:amir_khan1/screens/consultant_screens/widgets/statusContainer.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/centralBar/contrPojectScreen.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/centralBar/contrTest/choooseProj.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/centralBar/doc/chooseProject.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/contrProgress.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/contrRequest.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ContrHomeTab extends StatefulWidget {
  const ContrHomeTab({super.key});

  @override
  State<ContrHomeTab> createState() => _ConsultantHomeTabState();
}

class _ConsultantHomeTabState extends State<ContrHomeTab> {
  @override
  void initState() {
    super.initState();
    countProject();
  }

  countProject() async {
    final countController = Get.put(ProjectCountingController());
    var one = await fetchMyProjects();
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
          .where('email', isEqualTo: user!.email)
          .where('endDate', isLessThan: Timestamp.fromDate(currentDate))
          .get();

      final userData = collectionData.docs.length;

//Contractor  Masail----------------------------------
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();

      List contractorProjIdList =
      await contractorQuery.docs.map((e) => e['projectId']).toList();
      final contractorProjects = await FirebaseFirestore.instance
          .collection('Projects')
          .where('endDate', isLessThan: Timestamp.fromDate(currentDate))
      // .where(FieldPath.documentId, whereIn: contractorProjIdList)
          .get();

      final contractorProjectCount = contractorProjects.docs
          .where((e) => contractorProjIdList.contains(e.id))
          .map((e) {
        return [e.id].toList();
      });

//---------------------------------------------------
      return userData + contractorProjectCount.length;
    } catch (e) {
      Get.snackbar('Error', e.toString());

      return 0;
    }
  }

  Future<List> fetchRecentProjects() async {
//..
    try {
      DateTime fifteenDaysAgo = DateTime.now().subtract(Duration(days: 15));
//Contr Contributions--------------------------------------------
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();
      final contrProjId = contractorQuery.docs.map((e) => e['projectId']);
      final contrProj = await FirebaseFirestore.instance
          .collection('Projects')
          .where('creationDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fifteenDaysAgo))
      //   .where(FieldPath.documentId, whereIn: contrProjId)
          .get();
      final contrResult = await contrProj.docs
          .where((doc) => contrProjId.contains(doc.id))
          .map((doc) {
        return [
          doc['title'],
          doc['budget'],
          doc['funding'],
          doc['startDate'],
          doc['endDate'],
          doc['location'],
          doc['creationDate']
        ];
      }).toList();
//-----------------------------------------------------------------------
      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
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
      userData.addAll(contrResult);
      return userData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  Future<int> fetchOngoingProjects() async {
    try {
      DateTime currentDate = DateTime.now();

      //--Creating Query for Contractor-----------------------------------------------
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();
      List contractorProjIdList =
      await contractorQuery.docs.map((e) => e['projectId']).toList();
      // Get.snackbar('title', contractorProjIdList.toString());
      final contractorProjects = await FirebaseFirestore.instance
          .collection('Projects')
          .where('endDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))

      // .where(FieldPath.documentId, whereIn: contractorProjIdList)
          .get();

      final contractorProjectCount = contractorProjects.docs
          .where((e) => contractorProjIdList.contains(e.id))
          .map((e) {
        return [e.id].toList();
      });

      //--------------------------------------------------------------------------
      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
      // .where('startDate',
      //     isLessThanOrEqualTo: Timestamp.fromDate(currentDate))
          .where('endDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
          .get();

      final userData = collectionData.docs.length;

      return userData + contractorProjectCount.length;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return 0;
    }
  }

  Future<int> fetchMyProjects() async {
    try {
      DateTime currentDate = DateTime.now();
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(user!.email)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();
      final collectionData = await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: user!.email)
          .get();

      final userData = collectionData.docs.length;

      final contractorProjects = contractorQuery.docs.length;

      return userData + contractorProjects;
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
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            backgroundImage: snapshot.data?.profilePicUrl !=
                                null
                                ? NetworkImage(snapshot.data!.profilePicUrl!)
                                : const NetworkImage(
                                'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                            radius: 25,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back!",
                              style:
                              TextStyle(fontSize: 14, color: Colors.green),
                            ),
                            const SizedBox(height: 0),
                            Text(
                              snapshot.data?.username ?? 'Guest',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            color: Colors.black,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                          body: NotificationsScreen())));
                            },
                            icon: Icon(Icons.notifications)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search bar
                    const SizedBox(height: 20),
                    // Page view with indicators
                    Obx(
                          () => Row(
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
                    Card(
                      color: Colors.transparent,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 10, bottom: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                        const ContrProgressPage()));
                              },
                              child: Text('Progress',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                            Container(
                              height: 30,
                              width: 1.5,
                              color: Colors.green,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const ContrRequestPage()));
                              },
                              child: Text(
                                'Request',
                                style: TextStyle(
                                    color: Colors.black,
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
                    ),
                    const SizedBox(height: 15),
                    // Upcoming activity
                    centralbar(),
                    const SizedBox(
                      height: 25,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Recently Added",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 0),
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
              return Text(
                'No Projects Added',
                style: TextStyle(
                  color: Colors.black,
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              final projectList = snapshot.data;

              return ListView.builder(
                  itemCount: projectList!.length,
                  itemBuilder: ((context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      elevation: 10,
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                        size: 15, color: Colors.green),
                                    Text(
                                      DateFormat('dd-MM-yyyy')
                                          .format(
                                        projectList[index][3].toDate(),
                                      )
                                          .toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(' to ',
                                        style:
                                        TextStyle(color: Colors.black)),
                                    Text(
                                        DateFormat('dd-MM-yyyy')
                                            .format(projectList[index][4]
                                            .toDate())
                                            .toString(),
                                        style:
                                        TextStyle(color: Colors.black)),
                                    Expanded(child: SizedBox()),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 15, color: Colors.green),
                                        Text(projectList[index][5],
                                            style: TextStyle(
                                                color: Colors.black)),
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
                                        color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.green),
                                    Text(projectList[index][2],
                                        style:
                                        TextStyle(color: Colors.black)),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    Text(
                                      'Rs ',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Text(projectList[index][1],
                                        style:
                                        TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )));
            }
          }),
    );
  }

  Widget centralbar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChooseProjectForDocument())),
            child: Card(
              color: Colors.transparent,
              elevation: 5,
              child: Container(
                height: 70,
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        Icons.file_copy,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1.5,
                        width: 45,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Dialogue().inputRtsp(context);
            },
            child: Card(
              color: Colors.transparent,
              elevation: 5,
              child: Container(
                height: 70,
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        Icons.video_call,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1.5,
                        width: 45,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        'Site',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectScreen(
                      isCnslt: true,
                    ))),
            child: Card(
              color: Colors.transparent,
              elevation: 5,
              child: Container(
                height: 70,
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1.5,
                        width: 45,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        'Projects',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChooseProjectForTest())),
            child: Card(
              color: Colors.transparent,
              elevation: 5,
              child: Container(
                height: 70,
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Icon(Icons.checklist, color: Colors.black),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1.5,
                        width: 45,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        'Testing',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
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

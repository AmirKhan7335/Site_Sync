import 'package:amir_khan1/screens/consultant_screens/widgets/requestWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Future<List<List>> getPendingRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: false)
          .get();

      final engineerEmail = activitiesSnapshot.docs.map(
        (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();

      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }

      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);

      return [getProject, getNames, nameEmail];
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [[]];
    }
  }

  Future<List<List>> getApprovedRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: true)
          .get();
      final engineerEmail = activitiesSnapshot.docs.map(
        (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();
      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }
      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);

      return [getProject, getNames, nameEmail];
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [[]];
    }
  }

  getEngineerUserName(List emails) async {
    try {
      var activitiesSnapshot =
          await FirebaseFirestore.instance.collection('users');
      final namesList = await Future.wait(emails.map((mail) async {
        final name = await activitiesSnapshot.doc(mail).get();

        return name['username'];
      }).toList());

      return namesList;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  getProjectDetail(List projectIds) async {
    try {
      final projects = FirebaseFirestore.instance.collection('Projects');
      final projectDataList = await Future.wait(projectIds.map(
        (Ids) async {
          final doc = await projects.doc(Ids).get();

          return [doc['title'], doc['startDate'], doc['endDate']];
        },
      ).toList());

      return projectDataList;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  bool isPending = true;
  Widget pendingRequests() {
    return FutureBuilder(
        future: getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data;

            return ListView.builder(
                itemCount: data![0].length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () async {
                        final name = await data[1][index];
                        final project = await data[0][index];
                        final email = await data[2][index];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PendingRequest(
                                      name: name,
                                      projectDataList: project,
                                      engEmail: email,
                                    )));
                      },
                      leading: CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person),
                      ),
                      title: Text('${data[1][index]}'),
                      subtitle: Text('Hi, please approve my role'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('8 Nov'),
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 10,
                          ),
                        ],
                      ),
                    ));
          } else {
            return Text('No Data');
          }
        });
  }

  Widget approvedRequests() {
    return FutureBuilder(
        future: getApprovedRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            return ListView.builder(
                itemCount: data![0].length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ApprovedRequest(
                                    name: data[1][index],
                                    projectDataList: data[0][index],
                                    engEmail: data[2][index],
                                  ))),
                      leading: CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person),
                      ),
                      title: Text('${data[1][index]}'),
                      subtitle: Text('Construction of ${data[0][index][0]}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('08/01/2023'),
                        ],
                      ),
                    ));
          } else {
            return Text('No Data');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPending ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isPending == false) {
                          setState(() {
                            isPending = true;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 20,
                            color: isPending ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: !isPending ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isPending == true) {
                          setState(() {
                            isPending = false;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 20,
                            color: !isPending ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75,
                child: isPending ? pendingRequests() : approvedRequests(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

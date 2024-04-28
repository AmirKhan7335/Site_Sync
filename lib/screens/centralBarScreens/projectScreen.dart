import 'package:amir_khan1/screens/consultant_screens/widgets/projDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../contractor_screen/projectdetailcontractor.dart';

class ProjectScreen extends StatefulWidget {
  ProjectScreen({
    super.key,
    required bool this.isCnslt,
  });

  bool isCnslt;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  getprojIdFromEngineer() async {
    final query = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(currentUserEmail)
        .get();
    final projId = await query.data()!['projectId'];
    return projId;
  }

  Future<List> fetchProjects() async {
    final currentUserEmail1 = FirebaseAuth.instance.currentUser!.email;
    final query2 = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail1)
        .get();
    String projIdFromEngineer = "";
    List<List<dynamic>> result = [];
    print("Role = ${query2['role']}");
    if (query2['role'] != 'Client') {
      projIdFromEngineer = widget.isCnslt ? '' : await getprojIdFromEngineer();

      final query = widget.isCnslt
          ? await FirebaseFirestore.instance
          .collection('Projects')
          .where('email', isEqualTo: currentUserEmail)
          .get()
          : await FirebaseFirestore.instance
          .collection('Projects')
          .where(FieldPath.documentId, isEqualTo: projIdFromEngineer)
          .get();
       result = query.docs.map((doc) {
        return [
          doc['title'],
          doc['startDate'],
          doc['endDate'],
          doc['budget'],
          doc['retMoney'],
          doc['funding'],
          doc['location'],
          doc.id
        ];
      }).toList();
    }
    // final currentUserEmail1 = FirebaseAuth.instance.currentUser!.email;
    // final query2 = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(currentUserEmail1)
    //     .get();
    if (query2['role'] == 'Contractor') {
      // Fetch projects associated with contractors
      final contractorQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(currentUserEmail1)
          .collection('projects')
          .where('reqAccepted', isEqualTo: true)
          .get();
      final contrProjId = contractorQuery.docs.map((e) => e['projectId']);

      final contractorProjectsQuery = await FirebaseFirestore.instance
          .collection('Projects')
          .where(FieldPath.documentId, whereIn: contrProjId)
          .get();
      final contractorProjects = contractorProjectsQuery.docs.map((doc) {
        return [doc['title'],
          doc['startDate'],
          doc['endDate'],
          doc['budget'],
          doc['retMoney'],
          doc['funding'],
          doc['location'],
          doc.id];
      }).toList();

      // Merge and return both sets of projects
      final List<List<dynamic>> allProjects = [];
      allProjects.addAll(result);
      allProjects.addAll(contractorProjects);
      return allProjects;
    }
    if (query2['role'] != 'Contractor'&& query2['role'] != 'Engineer'&& query2['role'] != 'Consultant') {
      // Fetch projects associated with contractors
      print("hi client");
      final contractorQuery = await FirebaseFirestore.instance
          .collection('clients')
          .doc(currentUserEmail)
          .get();
      final contrProjId = await contractorQuery.data()!['projectId'];
      print("project id = $contrProjId");

      final contractorProjectsQuery = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(contrProjId)
          .get();
      final docData = contractorProjectsQuery.data() as Map<String, dynamic>;
      final contractorProjects = [
        docData['title'],
        docData['startDate'],
        docData['endDate'],
        docData['budget'],
        docData['retMoney'],
        docData['funding'],
        docData['location'],
        contractorProjectsQuery.id];

      print("contractorProjects");
      return contractorProjects;
    }

    return result;
  }

  Future<String> getEngineer(projId) async {
    try {
      final engineerEmail = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: projId)
          .get();
      final email = engineerEmail.docs.map((doc) => doc.id).toList();
      final userName = await FirebaseFirestore.instance
          .collection('users')
          .doc(email[0])
          .get();
      return userName.data()!['username'];
    } catch (e) {
      return 'No Engineer Assigned';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Projects', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: fetchProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center();
            }
            final data = snapshot.data;
            final role1 = getRole();
            print("data index 2 = ${data![0][2]}");
            return ListView.builder(
                itemCount: data!.length,
                itemBuilder: ((context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        color: Colors.white,
                        child: ListTile(
                          onTap: () async {
                            final id = data[index][7];
                            final getname = await getEngineer(id);
                            if (widget.isCnslt) {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ProjectDetailContractor(
                                    projectDataList: data[index],
                                    engineerName: getname,
                                  );
                                },
                              ));
                            }
                          },
                          leading: ClipOval(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(data[index][0].toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          // subtitle: role1 != 'Contractor' && role1 != 'Engineer' && role1 != 'Consultant'
                          //     ? Text(
                          //   DateTime.now().isAfter(DateFormat('yyyy-MM-dd').parse(data[index][2]))
                          //       ? 'Completed'
                          //       : 'Ongoing',
                          //   style: const TextStyle(color: Colors.black),
                          // )
                          //     : Text(
                          //   DateTime.now().isAfter(data[index][2].toDate())
                          //       ? 'Completed'
                          //       : 'Ongoing',
                          //   style: const TextStyle(color: Colors.black),
                          // subtitle: Text(
                          //   (() {
                          //     if (data[index][2] is String) {
                          //       return DateTime.now().isAfter(DateFormat('yyyy-MM-dd').parse(data[index][2]))
                          //           ? 'Completed'
                          //           : 'Ongoing';
                          //     } else if (data[index][2] is Timestamp) {
                          //       return DateTime.now().isAfter((data[index][2] as Timestamp).toDate())
                          //           ? 'Completed'
                          //           : 'Ongoing';
                          //     } else {
                          //       return 'Invalid Date'; // Handle unexpected data type
                          //     }
                          //   })(),
                          //   style: const TextStyle(color: Colors.black),
                          // ),
                        ),
                      ),
                    )));
          }),
    );
  }

  getRole() async {
    final currentUserEmail1 = FirebaseAuth.instance.currentUser!.email;
    final query2 = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail1)
        .get();
    return query2['role'];
  }
}

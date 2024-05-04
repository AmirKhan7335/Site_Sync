import 'package:amir_khan1/screens/consultant_screens/widgets/projDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class ProjectScreen1 extends StatefulWidget {
  ProjectScreen1({
    super.key,
    required bool this.isCnslt,
  });

  bool isCnslt;

  @override
  State<ProjectScreen1> createState() => _ProjectScreen1State();
}

class _ProjectScreen1State extends State<ProjectScreen1> {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
  String projTitle = '';

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
        projTitle = doc['title'];
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
      projTitle = docData['title'];

      print("contractorProjects");
      return contractorProjects;
    }

    return result;
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
                itemCount: 1,
                itemBuilder: ((context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: ListTile(
                      onTap: () async {
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
                      title: Text(projTitle,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
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

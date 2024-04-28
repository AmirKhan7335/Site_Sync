import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/consltDocuments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChooseProjectForDocument1 extends StatefulWidget {
  const ChooseProjectForDocument1({super.key});

  @override
  State<ChooseProjectForDocument1> createState() =>
      _ChooseProjectForDocument1State();
}

class _ChooseProjectForDocument1State extends State<ChooseProjectForDocument1> {
  final myEmail = FirebaseAuth.instance.currentUser!.email;
  Future<List<List<dynamic>>> fetchProjects() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    // Fetch projects owned by the current user
    final userProjectsQuery = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: currentUserEmail)
        .get();
    final userProjects = userProjectsQuery.docs.map((doc) {
      return [doc['title'], doc.id];
    }).toList();

    // // Fetch projects associated with contractors
    // final contractorQuery = await FirebaseFirestore.instance
    //     .collection('contractor')
    //     .doc(currentUserEmail)
    //     .collection('projects')
    //     .where('reqAccepted', isEqualTo: true)
    //     .get();
    // final contrProjId = contractorQuery.docs.map((e) => e['projectId']);
    //
    // final contractorProjectsQuery = await FirebaseFirestore.instance
    //     .collection('Projects')
    //     .where(FieldPath.documentId, whereIn: contrProjId)
    //     .get();
    // final contractorProjects = contractorProjectsQuery.docs.map((doc) {
    //   return [doc['title'], doc.id];
    // }).toList();
    //
    // // Merge and return both sets of projects
    // final List<List<dynamic>> allProjects = [];
    // allProjects.addAll(userProjects);
    // allProjects.addAll(contractorProjects);

    return userProjects; 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Select Project',
            style: TextStyle(color: Colors.black),
          ),
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
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: ((context, index) => Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      child: ListTile(
                        onTap: () {
                          final projId = data[index][1];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CnsltDocumentScreen(
                                      projectId: projId)));
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
                        title: Text(
                          data[index][0].toString(),
                          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )));
            }));
  }
}

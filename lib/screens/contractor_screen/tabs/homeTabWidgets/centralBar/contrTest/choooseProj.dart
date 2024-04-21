import 'package:amir_khan1/screens/centralBarScreens/TestingTab/testingScreen.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/consltDocuments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChooseContrProjectForTest extends StatefulWidget {
  const ChooseContrProjectForTest({super.key});

  @override
  State<ChooseContrProjectForTest> createState() =>
      _ChooseProjectForTestState();
}

class _ChooseProjectForTestState extends State<ChooseContrProjectForTest> {
  final myEmail = FirebaseAuth.instance.currentUser!.email;
  Future<List> fetchProjects() async {
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: myEmail)
        .get();
    final result = await query.docs.map((doc) {
      return [doc['title'], doc.id];
    }).toList();
// Contr Contributions-------------------------------------------
    final contractorQuery = await FirebaseFirestore.instance
        .collection('contractor')
        .doc(myEmail)
        .collection('projects')
        .where('reqAccepted', isEqualTo: true)
        .get();
    final contrProjId = contractorQuery.docs.map((e) => e['projectId']);
    if (contrProjId.isNotEmpty) {
      final contrProj = await FirebaseFirestore.instance
          .collection('Projects')
          .where(FieldPath.documentId, whereIn: contrProjId)
          .get();
      final contrResult = await contrProj.docs.map((doc) {
        return [doc['title'], doc.id];
      }).toList();

      result.addAll(contrResult);
      return result;
    } else {
      return result;
    }
//----------------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Project'),
        ),
        body: FutureBuilder(
            future: fetchProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center();
              }
              final data = snapshot.data;
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: ((context, index) => ListTile(
                    onTap: () {
                      final projId = data[index][1];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestingScreen(
                                isClient: false,
                                projId: projId,
                                isCnslt: true,
                              )));
                    },
                    leading: ClipOval(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(data[index][0].toString()),
                    subtitle: Container(
                      height: 1.5,
                      width: 500,
                      color: Colors.grey,
                    ),
                  )));
            }));
  }
}

import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/consltDocuments.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/homeTabWidgets/centralBar/doc/contrdoc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChooseContrProjectForDocument extends StatefulWidget {
  const ChooseContrProjectForDocument({super.key});

  @override
  State<ChooseContrProjectForDocument> createState() =>
      _ChooseProjectForDocumentState();
}

class _ChooseProjectForDocumentState
    extends State<ChooseContrProjectForDocument> {
  final myEmail = FirebaseAuth.instance.currentUser!.email;
  Future<List> fetchProjects() async {
    //Contractor Code---------------------------------------------
    final contractorQuery = await FirebaseFirestore.instance
        .collection('contractor')
        .doc(myEmail)
        .collection('projects')
        .where('reqAccepted', isEqualTo: true)
        .get();
    final contrProjId = contractorQuery.docs.map((e) => e['projectId']);
    final contrProj = await FirebaseFirestore.instance
        .collection('Projects')
        .where(FieldPath.documentId, whereIn: contrProjId)
        .get();
    final contrResult = await contrProj.docs.map((doc) {
      return [doc['title'], doc.id];
    }).toList();
    //----------------------------------------------------------------------

    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: myEmail)
        .get();
    final result = await query.docs.map((doc) {
      return [doc['title'], doc.id];
    }).toList();
    result.addAll(contrResult);

    return result;
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
                                  builder: (context) =>
                                      ContrDocumentScreen(projectId: projId)));
                        },
                        leading: ClipOval(
                          child: Text(
                            index.toString(),
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

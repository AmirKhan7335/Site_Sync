import 'package:amir_khan1/screens/consultant_screens/cnsltDoc/consltDocuments.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/cnsltFinanceHome.dart';
import 'package:amir_khan1/screens/contractor_screen/finance/contrFinanceHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContrProjectForFinance extends StatefulWidget {
  const ContrProjectForFinance({super.key});

  @override
  State<ContrProjectForFinance> createState() => _ContrProjectForFinanceState();
}

class _ContrProjectForFinanceState extends State<ContrProjectForFinance> {
  final myEmail = FirebaseAuth.instance.currentUser!.email;
  Future<List> fetchProjects() async {
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: myEmail)
        .get();
    final result = await query.docs.map((doc) {
      return [doc['title'], doc.id, true];
    }).toList();

    final result2 = await fetchProjectsCreatedByConslt();

    if (result2.isNotEmpty) {
      result.add(result2);

      return result[0];
    } else {
      return result;
    }
  }

  Future<List> fetchProjectsCreatedByConslt() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      final contrRequest = await FirebaseFirestore.instance
          .collection('contractorReq')
          .where('contractorEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: true)
          .get();
      final projectIds = contrRequest.docs.map(
            (doc) {
          return doc['projectId'];
        },
      ).toList();
      debugPrint(projectIds.length.toString());

      final query = await FirebaseFirestore.instance
          .collection('Projects')
          .where(FieldPath.documentId, whereIn: projectIds)
          .get();
      final result = query.docs.map((doc) {
        return [doc['title'], doc.id, false];
      }).toList();
      debugPrint(result.length.toString());
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Project',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              height: Get.height * 0.8,
              child: FutureBuilder(
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
                        itemBuilder: ((context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {
                                final projId = data[index][1];
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ContrFinanceHome(
                                            projectId: projId,
                                            projectCreatedbyContr: data[index]
                                            [2])));
                              },
                              leading: ClipOval(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                data[index][0].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Container(
                                height: 1.5,
                                width: 500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )));
                  }),
            ),
          ],
        ));
  }
}
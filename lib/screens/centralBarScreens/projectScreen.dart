import 'package:amir_khan1/screens/consultant_screens/widgets/projDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectScreen extends StatefulWidget {
  ProjectScreen({super.key, required bool this.isCnslt});
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
    
    final projIdFromEngineer =widget.isCnslt?'': await getprojIdFromEngineer();
    
    final query = widget.isCnslt
        ? await FirebaseFirestore.instance
            .collection('Projects')
            .where('email', isEqualTo: currentUserEmail)
            .get()
        : await FirebaseFirestore.instance
            .collection('Projects')
            .where(FieldPath.documentId, isEqualTo: projIdFromEngineer)
            .get();
    final result = query.docs.map((doc) {
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
        title: Text('Projects'),
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
                      onTap: () async {
                        final id = data[index][7];
                        final getname = await getEngineer(id);
                        if (widget.isCnslt) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ProjectDetail(
                                projectDataList: data[index],
                                engineerName: getname,
                              );
                            },
                          ));
                        }
                      },
                      leading: ClipOval(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(data[index][0].toString()),
                      subtitle: Text(
                          DateTime.now().isAfter(data[index][2].toDate())
                              ? 'Completed'
                              : 'Ongoing'),
                    )));
          }),
    );
  }
}

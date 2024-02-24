import 'package:amir_khan1/screens/consultant_screens/widgets/projDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectScreen extends StatefulWidget {
  ProjectScreen({super.key, required bool this.isCnslt});
  bool isCnslt;
  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Future<List> fetchProjects() async {
    final query = await FirebaseFirestore.instance.collection('Projects').get();
    final result = query.docs.map((doc) {
      return [
        doc['title'],
        doc['startDate'],
        doc['endDate'],
        doc['budget'],
        doc['retMoney'],
        doc['funding'],
        doc['location']
      ];
    }).toList();
    
    return result;
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
                      onTap: () {
                        if (widget.isCnslt) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ProjectDetail(
                                projectDataList:data[index] ,
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

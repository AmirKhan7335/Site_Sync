import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Future<List> fetchProjects() async {
    final query = await FirebaseFirestore.instance.collection('Projects').get();
    final result = query.docs.map((doc) {
      return [doc['title'], doc['endDate']];
    }).toList();
    print(result.length);
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
                      leading: ClipOval(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(data[index][0].toString()),
                      subtitle: Text(DateTime.now().isAfter(data[index][1].toDate())
                          ? 'Completed'
                          : 'Ongoing'),
                    )));
          }),
    );
  }
}

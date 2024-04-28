import 'package:amir_khan1/screens/centralBarScreens/TestingTab/testingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChooseProjectForTest1 extends StatefulWidget {
  const ChooseProjectForTest1({super.key});

  @override
  State<ChooseProjectForTest1> createState() => _ChooseProjectForTest1State();
}

class _ChooseProjectForTest1State extends State<ChooseProjectForTest1> {
  final myEmail = FirebaseAuth.instance.currentUser!.email;
  Future<List> fetchProjects() async {
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: myEmail)
        .get();
    final result = query.docs.map((doc) {
      return [doc['title'], doc.id];
    }).toList();


    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Select Project',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      child: ListTile(
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
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          data[index][0].toString(),
                          style: const TextStyle(color: Colors.black, fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )));
            }));
  }
}

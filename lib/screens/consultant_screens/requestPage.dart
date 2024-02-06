import 'package:amir_khan1/screens/consultant_screens/widgets/requestWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  getPendingRequests() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .where('consultantEmail', isEqualTo: email)
        .where('reqAccepted',isEqualTo: false)
        .get();
    final engineerEmail = activitiesSnapshot.docs.map(
      (doc) {
        return [doc.id,doc['projectId']];
      },
    ).toList();
    return engineerEmail;
  }
   getApprovedRequests() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .where('consultantEmail', isEqualTo: email)
        .where('reqAccepted',isEqualTo: true)
        .get();
    final engineerEmail = activitiesSnapshot.docs.map(
      (doc) {
        return [doc.id,doc['projectId']];
      },
    ).toList();
    return engineerEmail;
  }

  bool isPending = true;
  Widget pendingRequests() {
    return FutureBuilder(
        future: getPendingRequests(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PendingRequest())),
                    leading: CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person),
                    ),
                    title: Text('Engineer Name'),
                    subtitle: Text('Hi, please approve my role'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('8 Nov'),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 10,
                        ),
                      ],
                    ),
                  ));
        });
  }

  Widget approvedRequests() {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ApprovedRequest())),
              leading: CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),
              title: Text('Name (Engineer)'),
              subtitle: Text('Construction of NSTP'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('08/01/2023'),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPending ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isPending == false) {
                          setState(() {
                            isPending = true;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 20,
                            color: isPending ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: !isPending ? Colors.yellow : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isPending == true) {
                          setState(() {
                            isPending = false;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 20,
                            color: !isPending ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75,
                child: isPending ? pendingRequests() : approvedRequests(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

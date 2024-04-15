import 'package:amir_khan1/screens/centralBarScreens/TestingTab/compressiveStrengthTest.dart/foundation.dart';
import 'package:amir_khan1/screens/centralBarScreens/TestingTab/testDocs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestingScreen extends StatefulWidget {
  TestingScreen(
      {super.key, required String this.projId, required bool this.isCnslt, required this.isClient});
  String projId;
  bool isCnslt;
  bool isClient;
  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  Future<String?> showTextInputDialog(
      BuildContext context, String labelText) async {
    String? _text = "";

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(labelText),
          content: TextField(
            onChanged: (String value) {
              _text = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',style: TextStyle(color:Colors.black),),
            ),
            TextButton(
              onPressed: () {
                if (_text != '') {
                  FirebaseFirestore.instance
                      .collection('Projects')
                      .doc(widget.projId)
                      .collection('testing')
                      .doc(_text)
                      .set({});
                }
                Navigator.pop(context, _text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('Testing',style: TextStyle(color:Colors.black),),
        ),
        body: NamesList(projId: widget.projId, isClient: widget.isClient),
        floatingActionButton: widget.isCnslt
            ? const Center() : widget.isClient
            ? const Center()
            : FloatingActionButton(
                onPressed: () {
                  showTextInputDialog(context, 'Write Test');
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
              ));
  }
}

class NamesList extends StatefulWidget {
  NamesList({super.key, required String this.projId, required this.isClient});
  String projId;
  bool isClient;
  @override
  State<NamesList> createState() => _NamesListState();
}

class _NamesListState extends State<NamesList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.projId)
          .collection('testing')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final data = snapshot.data!.docs;
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (data[index].id == 'Compressive Strength Test') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                            isClient: widget.isClient,
                                            title: 'Compressive Strength Test',
                                            projId: widget.projId,
                                          )));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TestDocumentScreen(
                                             isClient: widget.isClient,
                                            docName: data[index].id,
                                            projId: widget.projId,
                                          )));
                            }
                          },
                          leading: ClipOval(
                              child: Text(
                            '${index + 1}',style: const TextStyle(color:Colors.black,fontSize: 20),
                            
                          )),
                          title: Text(
                            '${data[index].id}',
                            style: const TextStyle(color:Colors.black,
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 48, right: 16.0),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  )));
        }
      },
    );
  }
}

class DetailScreen extends StatefulWidget {
  DetailScreen(
      {super.key, required String this.title, required String this.projId, required this.isClient});
  String title;
  String projId;
  bool isClient;
  @override
  State<DetailScreen> createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  List names = ["Foundations", 'Columns', 'Beams', 'Slabs'];
  List icons = [
    Icons.foundation,
    Icons.view_column,
    Icons.space_bar,
    Icons.square
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.title,style: const TextStyle(color:Colors.black),),
      ),
      body: ListView.builder(
          itemCount: names.length,
          itemBuilder: ((context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FoundationDocumentScreen(
                                       isClient:widget.isClient,
                                      docName: names[index],
                                      projId: widget.projId,
                                    )));
                      },
                      leading: ClipOval(child: Icon(icons[index],color:Colors.black,)),
                      title: Text(
                        '${names[index]}',
                        style: const TextStyle(
                            fontSize: 20,color:Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 48, right: 16.0),
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _text),
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
          title: Text('Testing'),
        ),
        body: NamesList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showTextInputDialog(context, 'Write Test').then((value) {
              FirebaseFirestore.instance.collection('testing').doc().set({
                'name': value,
              });
            });
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ));
  }
}

class NamesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('testing').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final data = snapshot.data!.docs;
          return
        
          ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                          title: 'Detail',
                                        )));
                          },
                          leading: ClipOval(
                              child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 20),
                          )),
                          title: Text(
                            '${data[index]['name']}',
                            style: TextStyle(
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
  DetailScreen({super.key, required String this.title});
  String title;
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
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: names.length,
          itemBuilder: ((context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipOval(child: Icon(icons[index])),
                      title: Text(
                        '${names[index]}',
                        style: TextStyle(
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
              ))),
    );
  }
}

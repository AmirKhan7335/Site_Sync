import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  List names = ["Foundations", 'Columns', 'Beams', 'Slabs'];
  List icons = [Icons.foundation, Icons.view_column, Icons.space_bar, Icons.square];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: ListView.builder(
          itemCount: names.length,
          itemBuilder: ((context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                      leading: ClipOval(child: Icon(icons[index ])),
                      title: Text(
                        '${names[index ]}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 48,right:16.0),
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

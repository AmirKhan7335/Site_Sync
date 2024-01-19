import 'package:amir_khan1/screens/consultant_screens/widgets/progressWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Widget Ongoing() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OngoingProgress(
                      index: index + 1,
                      name: "Construction of NISH",
                      progressValue: 0.75,
                    ))),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[400],
          radius: 30,
          child: Text(
            '${index + 1}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Construction of NISH'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 160,
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(5),
                          value: 0.75,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.yellow),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('75%'),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget Completed() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompletedProgress(
                      index: index + 1,
                      name: "Construction of NICE",
                      progressValue: 1,
                    ))),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[400],
          radius: 30,
          child: Text(
            '${index + 1}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Construction of NICE'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 160,
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(5),
                          value: 1,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.yellow),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('100%'),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  bool isOngoing = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
        centerTitle: true,
      ),
      body: Column(
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
                    color: isOngoing ? Colors.yellow : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isOngoing == false) {
                        setState(() {
                          isOngoing = true;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Ongoing',
                        style: TextStyle(
                          fontSize: 20,
                          color: isOngoing ? Colors.black : Colors.white,
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
                    color: !isOngoing ? Colors.yellow : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isOngoing == true) {
                        setState(() {
                          isOngoing = false;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 20,
                          color: !isOngoing ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(right: 8, left: 8, bottom: 0),
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75,
                child: isOngoing ? Ongoing() : Completed(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

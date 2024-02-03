
import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/enghomeTab.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/takePicture.dart';
import 'package:flutter/material.dart';

class EngineerHomePage extends StatefulWidget {
  const EngineerHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<EngineerHomePage> {
  
  int currentIndex = 0; // Index of the selected tab

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: const Color(0xFF212832),
      body: currentIndex == 1
          ? ChatScreen()
          : currentIndex == 2
              ? TakePicture()
              : currentIndex == 0
                  ? EngineerHomeTab()
                  : currentIndex == 3
                      ? const ScheduleScreen()
                      : const NotificationsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 60.0,
                  height: 38.0,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 40.0),
                ),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Finanace',
          ),
        ],
        iconSize: 20.0,
      ),
    );
  }
}

import 'package:amir_khan1/screens/schedulescreen.dart';
import 'package:amir_khan1/screens/taskdetailsscreen.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'chatscreen.dart';


//Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
        'Olivia Anne', 'House 1 Design Project', 'left a comment in task'),
    NotificationItem(
        'Robert Brown', 'Hospital Design Project', 'left a comment in task'),
    NotificationItem(
        'Sophia', 'University Design Project', 'left a comment in task'),
    NotificationItem('Anna', 'Mosque Design Project', 'left a comment in task'),
    NotificationItem('Robert Brown', 'House 2 Design Project',
        'marked the task as in process'),
    NotificationItem(
        'Sophia', 'House 3 Design Project', 'left a comment in task'),
    NotificationItem(
        'Anna', 'House 4 Design Project', 'left a comment in task'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212832),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF212832),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            // For simplicity, using an icon instead of an image
            title: Text(
                '${notifications[index].name} ${notifications[index].action}'),
            subtitle: Text(notifications[index].task),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        // Set the background color
        currentIndex: currentIndex,
        // Set the current tab index
        onTap: (int index) {
          // Handle tab tap, change the current index
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));
          } else if (index == 2) {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TaskDetailsScreen();
            }));
          } // Navigate to TaskDetailsScreen
          else if (index == 0) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const MyHomePage(title: 'My Home Page');
            })); // Navigate to TaskDetailsScreen
          } else if (index == 3) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const ScheduleScreen();
            })); // Navigate to TaskDetailsScreen
          } else {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const NotificationsScreen();
            })); // Navigate to TaskDetailsScreen
          }
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
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 30.0),
                ),
              ),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        // Set the height of the BottomNavigationBar
        // Adjust this value as needed
        iconSize: 20.0,
      ),
    );
  }
}

class NotificationItem {
  final String name;
  final String task;
  final String action;

  NotificationItem(this.name, this.task, this.action);
}

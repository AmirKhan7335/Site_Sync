import 'package:amir_khan1/screens/schedulescreen.dart';
import 'package:amir_khan1/screens/taskdetailsscreen.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'chatscreen.dart';
import 'notificationsscreen.dart';



//foundation schedule screen
class FoundationScheduleScreen extends StatefulWidget {
  const FoundationScheduleScreen({super.key});

  @override
  State<FoundationScheduleScreen> createState() =>
      _FoundationScheduleScreenState();
}

class _FoundationScheduleScreenState extends State<FoundationScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212832),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        children: [
          const Text(
            'Foundation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildActivityTile('Reinforcement Installation', '2/10/23 - 8/10/23'),
          _buildActivityTile('Form work', '9/10/23 - 15/10/23'),
          _buildActivityTile('Concreting', '16/10/23 - 25/11/23'),
          _buildActivityTile('Curing', '20/11/23 - 15/12/23'),
        ],
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));
          } else if (index == 2) {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TaskDetailsScreen();
            }));
          } // Navigate to TaskDetailsScreen
          else if (index == 0) {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const MyHomePage(title: 'My Home Page');
            })); // Navigate to TaskDetailsScreen
          } else if (index == 3) {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ScheduleScreen();
            })); // Navigate to TaskDetailsScreen
          } else {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
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

  Widget _buildActivityTile(String title, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF537789),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.0,
            height: 60,
            color: const Color(0xFFFED36A),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFD2D2D2),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          const Text(
            'Tap to view',
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
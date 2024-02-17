import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'engChatscreen.dart';

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
    return Container(
      
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32,right: 32,top: 45,),
            child: Row(
              children: [
                Text(
                  'Notifications',style: TextStyle(
                      
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    
                    )
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height-200 ,
            child: ListView.builder(
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
          ),
        ],
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

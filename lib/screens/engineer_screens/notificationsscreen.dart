import 'package:flutter/material.dart';


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
      color: Colors.white,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 32,right: 32,top: 45,),
            child: Row(
              children: [
                Text(
                  'Notifications',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    
                    )
                ),
              ],
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
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
                      '${notifications[index].name} ${notifications[index].action}',style: const TextStyle(color: Colors.black),),
                  subtitle: Text(notifications[index].task,style: const TextStyle(color: Colors.black),),
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

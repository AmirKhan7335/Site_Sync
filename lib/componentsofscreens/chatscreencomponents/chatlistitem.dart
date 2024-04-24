import 'package:flutter/material.dart';
import '../../screens/engineer_screens/chatscreen.dart';



class ChatListItem extends StatelessWidget {
  final ChatUser user;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: ListTile(
          leading:
          CircleAvatar(
            radius: 30,
            child: Image.asset('assets/images/Ellipse.png'),
          ),
          title: Text(user.name,style: TextStyle(color: Colors.black)),
          onTap: onTap,
        ),
      ),
    );
  }
}
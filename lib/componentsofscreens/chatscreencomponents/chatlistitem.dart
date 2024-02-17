import 'package:flutter/material.dart';
import '../../screens/engineer_screens/engChatscreen.dart';



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
    return ListTile(
      leading:
      CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0] : '?')),
      title: Text(user.name),
      onTap: onTap,
    );
  }
}
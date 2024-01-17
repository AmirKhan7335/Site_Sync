import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/engineer_screens/chatscreen.dart';
import 'chatinputarea.dart';
import 'chatmessages.dart';

//personal chats
class IndividualChatScreen extends StatefulWidget {
  final ChatUser user;
  final String chatRoomId;
  final ChatUser? selectedUser;

  const IndividualChatScreen({
    super.key,
    required this.user,
    required this.chatRoomId,
    required this.selectedUser, // Add selectedUser parameter
  });

  @override
  IndividualChatScreenState createState() => IndividualChatScreenState();
}

class IndividualChatScreenState extends State<IndividualChatScreen> {
  late String chatRoomId;

  @override
  Widget build(BuildContext context) {
    chatRoomId = getChatRoomId(
      FirebaseAuth.instance.currentUser?.email ?? '',
      widget.user.id,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.selectedUser?.name[0] ?? '', // Use widget.selectedUser
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.selectedUser?.name ?? 'User', // Use widget.selectedUser
                        style: const TextStyle(fontSize: 18)),
                    const Text('Online',
                        style:
                        TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF212832),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              user: widget.user,
              chatRoomId: chatRoomId,
            ),
          ),
          ChatInputArea(
            user: widget.user,
            chatRoomId: chatRoomId,
          ),
        ],
      ),
    );
  }
}



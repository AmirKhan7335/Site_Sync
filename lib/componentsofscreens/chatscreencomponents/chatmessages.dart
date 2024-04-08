import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/engineer_screens/chatscreen.dart';
import 'chatmessage.dart';
import 'messagetile.dart';

class ChatMessages extends StatefulWidget {
  final ChatUser? user;
  final String chatRoomId;

  const ChatMessages({super.key, required this.user, required this.chatRoomId});

  @override
  ChatMessagesState createState() => ChatMessagesState();
}

class ChatMessagesState extends State<ChatMessages> {
  String currentUserId = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No messages yet.'));
        }
        List<ChatMessage> messages = snapshot.data!.docs.map((doc) {
          final Map<String, dynamic> data = doc.data()
          as Map<String, dynamic>; // Cast to Map<String, dynamic>
          var timestamp = data['timestamp'];
          DateTime createdAt = timestamp != null
              ? (timestamp as Timestamp).toDate()
              : DateTime.now();
          String sender = data['senderId'];
          String text = data['text'];
          String deliveryStatus = data['deliveryStatus'] ?? 'sent'; // Default to 'sent'

          // Update the message status in Firestore if it's not 'read' or 'delivered'
          if (deliveryStatus == 'sent' && sender != currentUserId) {
            // Assuming you have a function to update the message status in Firestore
            updateMessageStatus(doc.reference, 'delivered');
            // print("sender = $sender, deliveryStatus = $deliveryStatus");
            // print("current user id is $currentUserId");
          }
          // print("sender 111 = $sender, deliveryStatus = $deliveryStatus");
          // print("current user id 111 is $currentUserId");

          return ChatMessage(
            audioUrl: data['audioUrl'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            documentUrl: data['documentUrl'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            sender: sender,
            text: text,
            createdAt: createdAt,
            messageStatus: getMessageStatus(sender, deliveryStatus),
            documentName: data['documentName'] ?? '',
          );
        }).toList();
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            ChatMessage message = messages[index];
            bool isSentByMe = message.sender == currentUserId; // Compare with current user's ID
            return MessageTile(
              documentName: message.documentName,
              imageUrl: message.imageUrl,
              audioUrl: message.audioUrl,
              documentUrl: message.documentUrl,
              videoUrl: message.videoUrl,
              message: message.text,
              isSentByMe: isSentByMe,
              timestamp: message.createdAt,
              chatRoomId: widget.chatRoomId,
            );
          },
        );
      },
    );
  }

  // Add this function inside the ChatMessagesState class
  Future<void> updateMessageStatus(DocumentReference messageRef, String status) async {
    try {
      await messageRef.update({'deliveryStatus': status});
    } catch (e) {
      // Handle error
    }
  }

  // Function to determine message status based on sender and delivery status
  MessageStatus getMessageStatus(String sender, String deliveryStatus) {
    if (deliveryStatus == 'read' || sender == currentUserId) {
      return MessageStatus.read;
    } else if (deliveryStatus == 'delivered') {
      return MessageStatus.delivered;
    } else {
      return MessageStatus.sent;
    }
  }
}



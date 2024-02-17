import '../../screens/engineer_screens/engChatscreen.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime createdAt;
  final MessageStatus messageStatus; // Keep the enum type here

  ChatMessage({
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.messageStatus, // Pass the enum directly
  });
}
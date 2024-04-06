import '../../screens/engineer_screens/chatscreen.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime createdAt;
  final MessageStatus messageStatus;
  final String? voiceMessageUrl;// Keep the enum type here

  ChatMessage({
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.messageStatus,
    required this.voiceMessageUrl,// Pass the enum directly
  });
}
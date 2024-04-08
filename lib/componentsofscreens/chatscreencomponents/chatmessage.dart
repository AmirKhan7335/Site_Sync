import '../../screens/engineer_screens/chatscreen.dart';

class ChatMessage {
  final String? imageUrl;
  final String sender;
  final String text;
  final DateTime createdAt;
  final String? documentUrl;
  final String? documentName;
  final MessageStatus messageStatus;
  final String? audioUrl;// Keep the enum type here
  final String? videoUrl;

  ChatMessage({
    required this.documentName,
    required this.imageUrl,
    required this.videoUrl,
    required this.sender,
    required this.documentUrl,
    required this.text,
    required this.createdAt,
    required this.messageStatus,
    required this.audioUrl,// Pass the enum directly
  });
}
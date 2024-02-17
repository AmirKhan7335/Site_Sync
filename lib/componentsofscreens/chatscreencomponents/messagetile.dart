import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/engineer_screens/engChatscreen.dart';


class MessageTile extends StatefulWidget {
  final String message;
  final String chatRoomId;
  final bool isSentByMe;
  final DateTime timestamp;

  const MessageTile({
    super.key,
    required this.message,
    required this.chatRoomId,
    required this.isSentByMe,
    required this.timestamp,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  MessageStatus _messageStatus = MessageStatus.loading;

  @override
  void initState() {
    super.initState();
    fetchMessageStatus(widget.chatRoomId).then((status) {
      setState(() {
        _messageStatus = status;
      });
      // print("message is ${widget.message} ,message status is $_messageStatus and message tile timestamp is ${widget.timestamp}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var bubbleColor =
    widget.isSentByMe ? const Color(0xFF4C9EFF) : const Color(0xFF4C9EFF);
    var textColor = widget.isSentByMe ? Colors.white : Colors.white;

    IconData tickIcon = Icons.done;
    Color tickColor = textColor.withOpacity(0.6);

    if (_messageStatus == MessageStatus.sent && widget.isSentByMe) {
      tickIcon = Icons.done;
      tickColor = Colors.white;
    } else if (_messageStatus == MessageStatus.delivered && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.yellow;
    } else if (_messageStatus == MessageStatus.read && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.yellow;
    } else if (_messageStatus == MessageStatus.loading) {
      tickIcon = Icons.access_time;
    } else {
      tickIcon = Icons.done;
      tickColor = Colors.transparent;
    }

    return Align(
      alignment:
      widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Wrap(
          alignment:
          widget.isSentByMe ? WrapAlignment.end : WrapAlignment.start,
          children: [
            IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.message,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(widget.timestamp),
                            style: TextStyle(
                                color: textColor.withOpacity(0.6), fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            tickIcon,
                            size: 16,
                            color: tickColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<MessageStatus> fetchMessageStatus(String chatRoomId) async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');

      QuerySnapshot messageQuerySnapshot = await messagesRef.get();

      for (QueryDocumentSnapshot messageSnapshot in messageQuerySnapshot.docs) {
        final data = messageSnapshot.data() as Map<String, dynamic>;

        for (var i = 0; i < messageQuerySnapshot.docs.length; i++) {
          if (data['text'] == widget.message) {
            // Compare Timestamp directly with DateTime
            final Timestamp messageTimestamp = data['timestamp'];
            final DateTime widgetTimestamp = widget.timestamp;

            // Compare the timestamps
            if (messageTimestamp.toDate() == widgetTimestamp) {
              final messageStatusString = data['deliveryStatus'] ?? 'sent';

              if (messageStatusString == 'delivered') {
                return MessageStatus.delivered;
              } else if (messageStatusString == 'read') {
                return MessageStatus.read;
              } else {
                return MessageStatus.sent;
              }
            }
          }
        }
      }

      return MessageStatus.sent; // Default to 'sent'
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching message status: $e');
      }
      return MessageStatus.sent; // Default to 'sent' in case of an error
    }
  }
}

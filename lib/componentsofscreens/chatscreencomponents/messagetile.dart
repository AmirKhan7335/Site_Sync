import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import '../../screens/engineer_screens/chatscreen.dart';


class MessageTile extends StatefulWidget {
  final String message;
  final String chatRoomId;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? voiceMessageUrl;

  const MessageTile({
    super.key, // Added 'Key?' to fix the error
    required this.message,
    required this.chatRoomId,
    required this.isSentByMe,
    required this.timestamp,
    required this.voiceMessageUrl,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    var bubbleColor = widget.isSentByMe
        ? const Color(0xFF2ECC71) // Adjusted bubble color for sent messages
        : const Color(0xFF2ECC71);  // Adjusted bubble color for received messages
    var textColor = widget.isSentByMe ? Colors.white : Colors.white; // Adjusted text color

    IconData tickIcon = Icons.done;
    Color tickColor = Colors.white54; // Adjusted tick color

    if (_messageStatus == MessageStatus.sent && widget.isSentByMe) {
      tickIcon = Icons.done;
      tickColor = Colors.white54;
    } else if (_messageStatus == MessageStatus.delivered && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.white54;
    } else if (_messageStatus == MessageStatus.read && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.yellow; // Adjusted tick color for read messages
    } else if (_messageStatus == MessageStatus.loading) {
      tickIcon = Icons.access_time;
    } else {
      tickIcon = Icons.done;
      tickColor = Colors.white54;
    }

    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Added margin
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5), // Adjusted maxWidth
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Added padding
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(8), // Adjusted border radius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display voice message player if URL is provided
                  if (widget.voiceMessageUrl != null && widget.voiceMessageUrl!.isNotEmpty)
                    VoiceMessagePlayer(url: widget.voiceMessageUrl!),
                  // Display text message if message is not empty and voice message is not provided
                  if (widget.voiceMessageUrl!.isEmpty)
                    Text(
                      widget.message,
                      style: TextStyle(color: textColor),
                    ),
                  SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Expanded(child: SizedBox()),
                        // Display message delivery timestamp
                        Text(
                          DateFormat('h:mm a').format(widget.timestamp),
                          style: const TextStyle(color: Colors.white54, fontSize: 10), // Adjusted timestamp style
                        ),
                        const SizedBox(width: 4), // Added spacing between timestamp and tick icon
                        // Display tick icon indicating message delivery status
                        Icon(
                          tickIcon,
                          size: 14,
                          color: tickColor,
                        ),
                      ],
                    ),
                  ),
                ],
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

class VoiceMessagePlayer extends StatefulWidget {
  final String url;

  const VoiceMessagePlayer({super.key, required this.url});

  @override
  VoiceMessagePlayerState createState() => VoiceMessagePlayerState();
}

class VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late AudioPlayer _audioPlayer;
  late bool _isPlaying;
  late Duration _duration;
  late Duration _position;

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
    _duration = Duration.zero;
    _position = Duration.zero;
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.url);

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (_position >= _duration) {
        _audioPlayer.seek(Duration.zero); // Move cursor to start
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // Set a fixed height
      child: GestureDetector(
        onTap: () {
          if (_isPlaying) {
            _audioPlayer.pause();
          } else {
            _audioPlayer.play();
          }
          setState(() {
            _isPlaying = !_isPlaying;
          });
        },
        child: Row(
          children: [
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                if (playerState != null && playerState.playing) {
                  _isPlaying = true;
                  return const Icon(
                    Icons.pause,
                    size: 24,
                    color: Colors.limeAccent,
                  );
                } else {
                  _isPlaying = false;
                  return const Icon(
                    Icons.play_arrow,
                    size: 24,
                    color: Colors.limeAccent,
                  );
                }
              },
            ),
            Expanded(
              child: Slider(
                value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()), // Clamp the value
                max: _duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            Text(
              _printDuration(_duration),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to format duration as mm:ss
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

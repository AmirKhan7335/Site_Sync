import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_sound/flutter_sound.dart';
import '../../screens/engineer_screens/chatscreen.dart';
import 'messagetile.dart';

final audio.AudioPlayer audioPlayer = audio.AudioPlayer();
String messageId = '';

class ChatInputArea extends StatefulWidget {
  final ChatUser user;
  final String chatRoomId;

  const ChatInputArea({
    super.key, // Use 'Key?' instead of 'super.key'
    required this.user,
    required this.chatRoomId,
  });

  @override
  ChatInputAreaState createState() => ChatInputAreaState();
}

class ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  bool _isSending = false;
  final audio.AudioPlayer audioPlayer = audio.AudioPlayer();
  late final FlutterSoundRecorder _audioRecorder;
  // Add a variable to track whether recording is in progress
  bool _isRecording = false;
  // Add a variable to store the recorded audio file path
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });

    _initAudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    audioPlayer.dispose(); // Dispose of the audio player
    _audioRecorder.openRecorder();
    super.dispose();
  }

  Future<void> _initAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder(); // Use `openRecorder` instead of `openAudioSession`
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio recorder: $e');
      }
    }
  }


  Future<void> startRecording() async {
    if (_isRecording) {
      return; // Do nothing if already recording
    }
    try {
      // Open the audio recorder
      await _audioRecorder.openRecorder();
      // Start recording to a file with a unique name (timestamp)
      await _audioRecorder.startRecorder(
        toFile: DateTime.now().millisecondsSinceEpoch.toString(),
        codec: Codec.aacMP4,
      );
      setState(() {
        _isRecording = true; // Update UI to reflect recording state
      });
    } catch (e) {
      // Handle any errors that occur during recording initialization
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return; // Do nothing if not recording
    }
    try {
      // Stop recording
      await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false; // Update UI to reflect recording state
      });
    } catch (e) {
      // Handle any errors that occur during recording termination
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> sendVoiceMessage() async {
    if (_isRecording) {
      // If recording is in progress, stop recording before sending
      await stopRecording();
    }

    // Ensure that there is a recorded audio file to send
    if (_audioFilePath != null && _audioFilePath!.isNotEmpty) {
      setState(() {
        _isSending = true; // Set sending flag to true
      });

      try {
        // Simulate sending the recorded audio message (replace with actual logic)
        await Future.delayed(const Duration(seconds: 2));
        // Update UI or perform actions after successful sending
        setState(() {
          if (kDebugMode) {
            print('Voice message sent: $_audioFilePath');
          }
        });
      } catch (e) {
        // Handle any errors that occur during sending
        if (kDebugMode) {
          print('Error sending voice message: $e');
        }
      } finally {
        setState(() {
          _isSending = false; // Reset sending flag
        });
      }
    } else {
      // No recorded audio file available to send
      if (kDebugMode) {
        print('No recorded audio available to send.');
      }
    }
  }


  Future<void> pickImageAndSend() async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload the image to a server or send it as a message
      // Include the image URL or file path in the message
    }
  }

  Future<String> sendMessage() async {
    if (_messageController.text.isNotEmpty && !_isSending) {
      setState(() {
        _isSending = true;
      });
      final currentContext = context;
      try {
        var message = {
          'text': _messageController.text,
          'senderId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
          'receiverId': widget.user.id,
          'timestamp': FieldValue.serverTimestamp(),
          'messageStatus': 'sent',
        };
        // print ("sender in chat input area = ${message['senderId']}");

        DocumentReference messageRef = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .collection('messages')
            .add(message);
        messageId = messageRef.id;

        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .update({
          'latestMessageTimestamp': FieldValue.serverTimestamp(),
        });
        _messageController.text = '';

        setState(() {
          if (kDebugMode) {
            print('Message sent');
          }
          _messageController.text = '';
        });
        if (context.mounted) {
          Navigator.pop(currentContext);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending message: $e');
        }
        _messageController.text = '';
      } finally {
        setState(() {
          _isSending = false;
          MessageTile(
            message: _messageController.text,
            isSentByMe: true,
            timestamp: DateTime.now(),
            chatRoomId: widget.chatRoomId,
          );
        });
      }
    }
    return messageId;
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                // Handle camera option
                // You can implement capturing photos or videos here
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Photo & Video Library'),
              onTap: () {
                pickImageAndSend();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () {
                // Handle document option
                // You can implement sending documents here
              },
            ),
            // Add more ListTiles here for each option
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 202, 193, 193),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.yellow),
            onPressed: _showOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon:
                        const Icon(Icons.emoji_emotions, color: Colors.yellow),
                    onPressed: () async {
                      messageId = await sendMessage();
                    },
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.yellow),
            onPressed: () {
              // Handle camera option
              // You can implement capturing photos or videos here
            },
          ),
          _isTyping
              ? IconButton(
                  icon: const Icon(Icons.send, color: Colors.yellow),
                  onPressed: () async {
                    messageId = await sendMessage();
                  },
                )
              : IconButton(
            icon: _isRecording
                ? const Icon(Icons.stop, color: Colors.red)
                : const Icon(Icons.mic, color: Colors.yellow),
            onPressed: () async {
              if (_isRecording) {
                // Stop recording and send voice message
                await stopRecording();
                await sendVoiceMessage(); // Send the recorded audio message
              } else {
                // Start recording
                startRecording();
              }
            },
          ),
        ],
      ),
    );
  }
}

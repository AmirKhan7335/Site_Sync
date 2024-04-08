import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../screens/engineer_screens/chatscreen.dart';
import 'package:path/path.dart' as p;
import 'messagetile.dart';
import 'dart:io';
import 'dart:async'; // Add import for Timer

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
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String audioFilePath = '';

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
    _audioRecorder.closeRecorder();
    super.dispose();
  }
  // Method to initialize _audioRecorder
  Future<void> _initAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio recorder: $e');
      }
    }
  }


  Future<void> _startRecording() async {
    final permissionStatus = await Permission.microphone.request();
    if (permissionStatus.isGranted) {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String path = '${appDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        if (kDebugMode) {
          print('Recording started. Path: $path');
        }
        await _audioRecorder.startRecorder(toFile: path, codec: Codec.aacMP4);
        setState(() {
          _isRecording = true;
          audioFilePath = path;
        });

        // Start a timer to limit the recording duration if needed
        // Replace 60 seconds with your desired recording duration
        Timer(const Duration(seconds: 60), () {
          if (_isRecording) {
            _stopRecording();
          }
        });
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('Error starting recording: $e');
          print(stackTrace);
        }
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      if (audioFilePath.isNotEmpty) {
        // Send the recorded audio file internally
        if (kDebugMode) {
          print('Audio file path: $audioFilePath');
        } // Debug print for audio file path
        _sendAudioMessage(audioFilePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }


  Future<void> _sendAudioMessage(String filePath) async {
    setState(() {
      _isSending = true;
    });

    try {
      // Check if the file exists
      File audioFile = File(filePath);
      if (!await audioFile.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Upload the recorded audio file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('audio_messages').child('${DateTime.now().millisecondsSinceEpoch}.m4a');
      await storageRef.putFile(audioFile);

      // Get the download URL of the uploaded file
      final audioUrl = await storageRef.getDownloadURL();

      // Construct the message data
      var message = {
        'text': '', // No text for audio message
        'senderId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
        'receiverId': widget.user.id,
        'timestamp': FieldValue.serverTimestamp(),
        'messageStatus': 'sent',
        'audioUrl': audioUrl,
        'documentUrl': '',
        'imageUrl': '',
        'videoUrl': '',
        'documentName': '',
      };

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message);

      // Update latest message timestamp
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .update({
        'latestMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // Clear audio file path
      setState(() {
        audioFilePath = '';
      });

      // Update UI if needed
      // You can add logic here to update UI when the message is sent

      if (kDebugMode) {
        print('Voice message sent: $filePath');
      }
    } catch (e) {
      // Handle any errors that occur during sending
      if (kDebugMode) {
        print('Error sending voice message: $e');
      }
    } finally {
      setState(() {
        _isSending = false;
      });
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
          'audioUrl': '',
          'documentUrl': '',
          'imageUrl': '',
          'videoUrl': '',
          'documentName': '',
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
            documentName: '',
            imageUrl: '',
            documentUrl: '',
            audioUrl: '',
            message: _messageController.text,
            isSentByMe: true,
            timestamp: DateTime.now(),
            chatRoomId: widget.chatRoomId,
            videoUrl: '',
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
              leading: const Icon(Icons.camera_alt),
              title: const Text('Photo'),
              onTap: () async {
                final XFile? media = await ImagePicker().pickImage(source: ImageSource.camera);
                if (media != null) {
                  // Send the captured media file
                  if (media.path.endsWith('.jpg') || media.path.endsWith('.jpeg') || media.path.endsWith('.png')) {
                    _sendImageMessage(media.path);
                  } else {
                    _sendImageMessage(media.path);
                  }
                  Navigator.pop(context); // Close the options
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Video'),
              onTap: () async {
                final XFile? media = await ImagePicker().pickVideo(source: ImageSource.camera);
                if (media != null) {
                  // Send the captured media file
                  if (media.path.endsWith('.jpg') || media.path.endsWith('.jpeg') || media.path.endsWith('.png')) {
                    _sendImageMessage(media.path);
                  } else {
                    _sendVideoMessage(media.path);
                  }
                  Navigator.pop(context); // Close the options
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Photo Library'),
              onTap: () async {
                final XFile? media = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (media != null) {
                  // Send the selected media file
                  if (media.path.endsWith('.jpg') || media.path.endsWith('.jpeg') || media.path.endsWith('.png')) {
                    _sendImageMessage(media.path);
                  } else {
                    _sendVideoMessage(media.path);
                  }
                  Navigator.pop(context); // Close the options
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Video Library'),
              onTap: () async {
                final XFile? media = await ImagePicker().pickVideo(source: ImageSource.gallery);
                if (media != null) {
                  // Send the selected media file
                  if (media.path.endsWith('.jpg') || media.path.endsWith('.jpeg') || media.path.endsWith('.png')) {
                    _sendImageMessage(media.path);
                  } else {
                    _sendVideoMessage(media.path);
                  }
                  Navigator.pop(context); // Close the options
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null) {
                  final filePath = result.files.single.path!;
                  _sendDocumentMessage(filePath);
                }
                Navigator.pop(context); // Close the options
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendVideoMessage(String videoPath) async {
    setState(() {
      _isSending = true;
    });

    try {
      // Check if the file exists
      File videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('File does not exist: $videoPath');
      }

      // Upload the selected video file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('videos').child('${DateTime.now().millisecondsSinceEpoch}.mp4');
      await storageRef.putFile(videoFile);

      // Get the download URL of the uploaded video file
      final videoUrl = await storageRef.getDownloadURL();

      // Construct the message data
      var message = {
        'text': '', // No text for video message
        'senderId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
        'receiverId': widget.user.id,
        'timestamp': FieldValue.serverTimestamp(),
        'messageStatus': 'sent',
        'videoUrl': videoUrl,
        'audioUrl': '',
        'documentUrl': '',
        'imageUrl': '',
        'documentName': '',
      };

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message);

      // Update latest message timestamp
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .update({
        'latestMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // Update UI if needed
      // You can add logic here to update UI when the message is sent

      if (kDebugMode) {
        print('Video message sent: $videoPath');
      }
    } catch (e) {
      // Handle any errors that occur during sending
      if (kDebugMode) {
        print('Error sending video message: $e');
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }



  Future<void> _sendImageMessage(String imagePath) async {
    setState(() {
      _isSending = true;
    });

    try {
      // Check if the file exists
      File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('File does not exist: $imagePath');
      }

      // Upload the selected image file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image file
      final imageUrl = await storageRef.getDownloadURL();

      // Construct the message data
      var message = {
        'text': '', // No text for image message
        'senderId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
        'receiverId': widget.user.id,
        'timestamp': FieldValue.serverTimestamp(),
        'messageStatus': 'sent',
        'imageUrl': imageUrl,
        'audioUrl': '',
        'documentUrl': '',
        'videoUrl': '',
        'documentName': '',
      };

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message);

      // Update latest message timestamp
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .update({
        'latestMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // Update UI if needed
      // You can add logic here to update UI when the message is sent

      if (kDebugMode) {
        print('Image message sent: $imagePath');
      }
    } catch (e) {
      // Handle any errors that occur during sending
      if (kDebugMode) {
        print('Error sending image message: $e');
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendDocumentMessage(String documentPath) async {
    setState(() {
      _isSending = true;
    });

    try {
      // Check if the file exists
      File documentFile = File(documentPath);
      if (!await documentFile.exists()) {
        throw Exception('File does not exist: $documentPath');
      }

      // Determine the file name and extension
      String fileName = p.basename(documentPath);
      String extension = p.extension(documentPath);

      // Upload the selected document file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('documents').child('${DateTime.now().millisecondsSinceEpoch}$extension');
      await storageRef.putFile(documentFile);

      // Get the download URL of the uploaded document file
      final documentUrl = await storageRef.getDownloadURL();

      // Construct the message data
      var message = {
        'text': '', // No text for document message
        'senderId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
        'receiverId': widget.user.id,
        'timestamp': FieldValue.serverTimestamp(),
        'messageStatus': 'sent',
        'documentUrl': documentUrl,
        'documentName': fileName, // Add the document name to the message data
        'audioUrl': '',
        'imageUrl': '',
        'videoUrl': '',
      };

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message);

      // Update latest message timestamp
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .update({
        'latestMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // Update UI if needed
      // You can add logic here to update UI when the message is sent

      if (kDebugMode) {
        print('Document message sent: $documentPath');
      }
    } catch (e) {
      // Handle any errors that occur during sending
      if (kDebugMode) {
        print('Error sending document message: $e');
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      height: 70.0,
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
                color: Colors.white12,
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
            onPressed: () async {
              final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                // Send the captured image file
                _sendImageMessage(image.path);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera, color: Colors.yellow),
            onPressed: () async {
              final XFile? image = await ImagePicker().pickVideo(source: ImageSource.camera);
              if (image != null) {
                // Send the selected image file
                _sendVideoMessage(image.path);
              }
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
            icon: _isRecording ? const Icon(Icons.stop, color: Colors.red) : const Icon(Icons.mic, color: Colors.blue),
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
            },
          ),
        ],
      ),
    );
  }
}

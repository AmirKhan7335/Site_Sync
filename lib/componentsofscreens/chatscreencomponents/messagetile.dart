import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../screens/engineer_screens/chatscreen.dart';
import 'package:video_player/video_player.dart';
import 'documentviewer.dart';
import 'dart:io';


class MessageTile extends StatefulWidget {
  final String? documentUrl;
  final String message;
  final String chatRoomId;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? audioUrl;
  final String? imageUrl;
  final String? videoUrl;
  final String? documentName;

  const MessageTile({super.key,
    required this.documentName,
    required this.documentUrl,
    required this.videoUrl,
    required this.message,
    required this.chatRoomId,
    required this.isSentByMe,
    required this.timestamp,
    required this.audioUrl,
    required this.imageUrl,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  MessageStatus _messageStatus = MessageStatus.loading;
  Duration _voiceMessageDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    fetchMessageStatus(widget.chatRoomId).then((status) {
      setState(() {
        _messageStatus = status;
      });
    });
  }

  getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/files");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  Future<void> _checkFileAndOpen(fileUrl, fileName) async {
    try {
      var storePath = await getPath();
      bool isExist = await File('$storePath/$fileName').exists();
      if (isExist) {
        OpenFile.open('$storePath/$fileName');
      } else {
        var filePath = '$storePath/$fileName';
        // setState(() {
        //   dowloading = true;
        //   progress = 0;
        // });

        await Dio().download(
          fileUrl,
          filePath,
          onReceiveProgress: (count, total) {
            // setState(() {
            //   progress = (count / total);
            // });
          },
        );
        OpenFile.open(filePath);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width * 0.5;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Align(
        alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
            child: Container(
              width: imageWidth,  // Adjust width as needed
              height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),// Adjust height as needed
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('        Image Viewer', style: TextStyle(color: Colors.black)),
                            iconTheme: const IconThemeData(color: Colors.black),
                          ),
                          body: Center(
                            child: Hero(
                              tag: widget.imageUrl!,
                              child: Image.network(
                                widget.imageUrl!,
                              ),
                            ),
                          ),
                        ),
                      ));
                    },
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(widget.timestamp),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        _buildTickIcon(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
      {
        return Align(
          alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            width: imageWidth, // Set the width explicitly
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: 150,
              width: double.infinity,// Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(),
                          body: Hero(
                            tag: widget.videoUrl!,
                            child: VideoPlayerWidget(
                              videoUrl: widget.videoUrl!,
                              maxWidth: MediaQuery.of(context).size.width * 0.5, // Adjust as needed
                            ),
                          ),
                        ),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: VideoPlayerWidget(
                        videoUrl: widget.videoUrl!,
                        maxWidth: MediaQuery.of(context).size.width * 0.5, // Adjust as needed
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(widget.timestamp),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        _buildTickIcon(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    else {
      return _buildMessageTile();
    }
  }

  Widget _buildMessageTile() {
    var bubbleColor = widget.isSentByMe
        ? const Color(0xFF2ECC71)
        : const Color(0xFF2ECC71);
    var textColor = widget.isSentByMe ? Colors.white : Colors.white;

    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        if (widget.documentUrl != null) {
                          // Check if the document is a PDF
                          if (widget.documentUrl!.toLowerCase().endsWith('.pdf')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentScreen(documentUrl: widget.documentUrl!, documentName: widget.documentName ?? ''),
                              ),
                            );
                          } else {
                            // Open non-PDF document
                            _checkFileAndOpen(widget.documentUrl, widget.documentName ?? '');
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: Text(
                          widget.documentName ?? '',
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty)
                    VoiceMessagePlayer(
                      url: widget.audioUrl!,
                      onDurationChanged: (duration) {
                        setState(() {
                          _voiceMessageDuration = duration;
                        });
                      },
                    ),
                  // Display text message if message is not empty and voice message is not provided
                  if (widget.message.isNotEmpty)
                    Text(
                      widget.message,
                      style: TextStyle(color: textColor),
                    ),
                  SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty)
                          const SizedBox(width: 10),
                        if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty)
                          Text(
                            Utils.printDuration(_voiceMessageDuration),
                            style: const TextStyle(color: Colors.white54, fontSize: 10),
                          ),
                        const Expanded(child: SizedBox()),
                        // Display message delivery timestamp
                        Text(
                          DateFormat('h:mm a').format(widget.timestamp),
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        _buildTickIcon(),
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

  Widget _buildTickIcon() {
    IconData tickIcon = Icons.done;
    Color tickColor = Colors.white54;

    if (_messageStatus == MessageStatus.sent && widget.isSentByMe) {
      tickIcon = Icons.done;
      tickColor = Colors.white54;
    } else if (_messageStatus == MessageStatus.delivered && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.white54;
    } else if (_messageStatus == MessageStatus.read && widget.isSentByMe) {
      tickIcon = Icons.done_all;
      tickColor = Colors.yellow;
    } else if (_messageStatus == MessageStatus.loading) {
      tickIcon = Icons.access_time;
    }

    return Icon(
      tickIcon,
      size: 14,
      color: tickColor,
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
            final Timestamp messageTimestamp = data['timestamp'];
            final DateTime widgetTimestamp = widget.timestamp;

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

      return MessageStatus.sent;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching message status: $e');
      }
      return MessageStatus.sent;
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double maxWidth; // Add a maxWidth property

  const VideoPlayerWidget({super.key, required this.videoUrl, required this.maxWidth});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  final bool _isPlaying = false;
  bool _isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isVideoLoaded = true;
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isVideoLoaded) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Hero(
                  tag: widget.videoUrl,
                  child: VideoPlayerScreen(videoUrl: widget.videoUrl),
                ),
              ),
            ),
          ));
        }
      },
      child: SizedBox(
        width: widget.maxWidth, // Use the maxWidth property
        height: 150, // Adjust height as needed
        child: Stack(
          alignment: Alignment.center, // Adjust alignment as needed
          children: [
            _isVideoLoaded ? VideoPlayer(_videoController) : Container(),
            !_isPlaying && _isVideoLoaded
                ? const Icon(Icons.play_arrow, size: 50, color: Colors.white) // Play icon if not playing
                : Container(),
          ],
        ),
      ),
    );
  }
}




  class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late bool _isPlaying;
  late Duration _duration;
  late Duration _position;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _videoController.play();
        });
      });

    _isPlaying = true;
    _duration = Duration.zero;
    _position = Duration.zero;

    _videoController.addListener(() {
      setState(() {
        _position = _videoController.value.position;
        _duration = _videoController.value.duration;
      });

      // Check if the video has completed
      if (_position >= _duration) {
        setState(() {
          _videoController.pause(); // Pause the video
          _isPlaying = false; // Update the play/pause icon
          _position = Duration.zero; // Reset the position to the start
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child:  Text('Video Player           ', style: TextStyle(color: Colors.black))),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            _videoController.pause();
                          } else {
                            _videoController.play();
                          }
                          _isPlaying = !_isPlaying;
                        });
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Slider(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          _videoController.seekTo(Duration(seconds: value.toInt()));
                        });
                      },
                    ),
                    Text(
                      '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







class VoiceMessagePlayer extends StatefulWidget {
  final String url;
  final Function(Duration) onDurationChanged; // Callback function to pass duration

  const VoiceMessagePlayer({super.key, required this.url, required this.onDurationChanged});

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
        widget.onDurationChanged(_duration); // Pass duration to parent widget
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
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
      height: 25,   // Set a fixed height
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
                activeColor: Colors.limeAccent,
                inactiveColor: Colors.white,
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Utils {
  static String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}


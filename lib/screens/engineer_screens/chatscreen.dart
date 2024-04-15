import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../componentsofscreens/chatscreencomponents/chatinfotileofchatscreen.dart';
import '../../componentsofscreens/chatscreencomponents/chatinputarea.dart';
import '../../componentsofscreens/chatscreencomponents/chatlistscreen.dart';
import '../../componentsofscreens/chatscreencomponents/chatmessage.dart';
import '../../componentsofscreens/chatscreencomponents/chatmessages.dart';

enum MessageStatus { sent, delivered, read, loading }

List<MessageChat> currentChatList = [];
GlobalKey<ChatScreenState> chatScreenKey = GlobalKey();

//Chat Screen
class MessageChat {
  final String sender;
  String latestMessage; // Remove 'final'

  MessageChat(this.sender, this.latestMessage);
}

// Define a Chat class to represent individual chat rooms/messages
class Chat {
  final String chatRoomId;
  Timestamp latestMessageTimestamp;

  Chat({required this.chatRoomId, required this.latestMessageTimestamp});
}

class ChatScreen extends StatefulWidget {
  final bool isClient;
  const ChatScreen({super.key, required this.isClient});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  int currentIndex1 = 0;
  ChatUser? selectedUser;
  List<Chat> chatList = [];
  List<ChatMessage> chatMessages = [];
  List allChatRooms = [];
  late final String chatRoomId;

  // Define a stream controller for chat rooms
  final StreamController<List<Map<String, dynamic>>> chatRoomsStreamController =
      StreamController<List<Map<String, dynamic>>>();

  StreamSubscription<QuerySnapshot>? messagesSubscription;

  Future<void> fetchChatMessages(String chatRoomId) async {
    // Cancel any existing subscription
    messagesSubscription?.cancel();

    try {
      // Create a stream of messages for the specified chat room
      final messagesStream = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      // Listen to changes in the messages collection
      messagesSubscription = messagesStream.listen((snapshot) {
        final List<ChatMessage> messages = snapshot.docs.map((doc) {
          final Map<String, dynamic> data = doc.data();
          return ChatMessage(
            imageUrl: data['imageUrl'] ?? '',
            audioUrl: data['audioUrl'] ?? '',
            documentUrl: data['documentUrl'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            documentName: data['documentName'] ?? '',
            sender: data['senderId'],
            text: data['text'],
            createdAt: (data['timestamp'] as Timestamp).toDate(),
            messageStatus: data['messageStatus'],
          );
        }).toList();

        setState(() {
          chatMessages = messages;
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chat messages: $e');
      }
    }
  }

  // Define the updateChatList function within ChatScreenState
  void updateChatList(ChatUser user, String latestMessage) {
    setState(() {
      var existingChat = currentChatList.firstWhere(
        (chat) => chat.sender == user.id,
        orElse: () => MessageChat(user.id, ""),
      );
      existingChat.latestMessage = latestMessage;
    });
  }

  Future<void> fetchChatData() async {
    try {
      final QuerySnapshot chatRoomsSnapshot = await FirebaseFirestore.instance
          .collection('chatRooms')
          .orderBy('latestMessageTimestamp', descending: true)
          .get();

      final List<Chat> chats = chatRoomsSnapshot.docs.map((doc) {
        final String chatRoomId = doc.id;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final Timestamp latestMessageTimestamp = data['latestMessageTimestamp'];
        return Chat(
            chatRoomId: chatRoomId,
            latestMessageTimestamp: latestMessageTimestamp);
      }).toList();

      setState(() {
        chatList = chats;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chat data: $e');
      }
    }
  }

  @override
  void initState() {
    // Call getAllChatRooms in initState to fetch chat data only once
    super.initState();
    getAllChatRooms();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await getAllChatRooms();
      if (selectedUser != null) {
        await fetchChatMessages(selectedUser!.chatRoomId);
      }
      setState(() {});
    });
  }

  Future getAllChatRooms() async {
    try {
      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();

      List<Map<String, dynamic>?> allUsers = result.docs
          .map((doc) => doc.data() as Map<String, dynamic>?)
          .where((data) => data != null)
          .toList();

      Map<String, dynamic> uniqueChatRooms = {};

      for (var element in allUsers) {
        var myId = FirebaseAuth.instance.currentUser?.email;
        if (myId == null) continue;

        var thatId = element?['email'];
        if (thatId == null) continue;

        var newChatRoom =
            myId.compareTo(thatId) > 0 ? '${myId}_$thatId' : '${thatId}_$myId';

        // Fetch chat room data
        QuerySnapshot chatRoomSnapshot = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(newChatRoom)
            .collection('messages')
            .get();

        if (chatRoomSnapshot.docs.isNotEmpty) {
          // Update the map with unique chat rooms only if there are messages in the chat room
          uniqueChatRooms[thatId] = element;
        }
      }

      setState(() {
        allChatRooms = uniqueChatRooms.values.toList();
        if (allChatRooms.isNotEmpty) {
          selectedUser = ChatUser(
            id: allChatRooms.first['email'],
            name: allChatRooms.first['username'],
            chatRoomId: getChatRoomId(
              FirebaseAuth.instance.currentUser?.email ?? '',
              allChatRooms.first['email'],
            ),
          );
          fetchChatMessages(selectedUser!.chatRoomId);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chat rooms: $e');
      }
    }
  }

  @override
  void dispose() {
    // Dispose any controllers or streams here
    messagesSubscription?.cancel();
    super.dispose();
  }

  bool isChat = true;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 42, right: 8),
            child: Row(
              children: [
                const Text(
                  '           Messages',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    // Navigate to ChatListScreen
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ChatListScreen(user: selectedUser, isClient:widget.isClient);
                    }));
                    if (result != null && result is bool && result) {
                      // Message sent or some other action completed, update the chat screen
                      fetchChatData();
                      fetchChatMessages(selectedUser!.chatRoomId);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isChat ?  const Color(0xFF3EED88): Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isChat == false) {
                        setState(() {
                          isChat = true;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 20,
                          color: isChat ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: !isChat ?  const Color(0xFF3EED88): Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isChat == true) {
                        setState(() {
                          isChat = false;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          fontSize: 20,
                          color: !isChat ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: selectedUser != null
                            ? FirebaseFirestore.instance
                                .collection('chatRooms')
                                .doc(selectedUser!.chatRoomId)
                                .collection('messages')
                                .snapshots()
                                .map((snapshot) => snapshot.docs
                                    .map((doc) => doc.data())
                                    .toList())
                            : null,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                'No Chats yet',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 25),
                              ),
                            );
                          } else {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.9,
                              padding: const EdgeInsets.only(top: 0),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 0),
                                itemCount: allChatRooms.length,
                                itemBuilder: (context, index) {
                                  var chatRoomData = allChatRooms[index];

                                  // Create a ChatUser based on the chat room data
                                  var chatUser = ChatUser(
                                    id: chatRoomData['email'],
                                    name: chatRoomData['username'],
                                    chatRoomId: '',
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        ChatInfoTile(
                                          key: ValueKey(chatUser.id),
                                          cUserID: FirebaseAuth
                                              .instance.currentUser!.email!,
                                          otherUser: chatUser,
                                          onTap: () {
                                            // When the tile is tapped, set the selectedUser
                                            setState(() {
                                              selectedUser = chatUser;
                                            });
                                          },
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4, left: 16.0, right: 16.0),
                                          child: Divider(
                                              color: Colors.grey, height: 0),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class  ChatUser {
  final String id;
  final String name;
  final String chatRoomId; // Add this if you need a chatRoomId for ChatUser

  ChatUser({required this.id, required this.name, this.chatRoomId = ''});
}

void startChatWithUser(BuildContext context, ChatUser user) {
  final String currentUserId = FirebaseAuth.instance.currentUser?.email ?? '';
  final String chatRoomId = getChatRoomId(currentUserId, user.id);

  // Now use the context passed as a parameter
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ChatRoomScreen(chatRoomId: chatRoomId, user: user);
  }));
}

class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;
  final ChatUser? user; // Make user nullable

  const ChatRoomScreen({super.key, required this.chatRoomId, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user?.name ?? '')), // Handle null user
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(chatRoomId: chatRoomId, user: user),
          ),
          ChatInputArea(chatRoomId: chatRoomId, user: user!),
        ],
      ),
    );
  }
}

String messageStatusToString(MessageStatus status) {
  return status.toString().split('.').last;
}

class Message {
  final String text;
  final String sender;
  final Timestamp timestamp;

  Message({required this.text, required this.sender, required this.timestamp});
}

String getChatRoomId(String user1, String user2) {
  return user1.compareTo(user2) > 0 ? '${user1}_$user2' : '${user2}_$user1';
}

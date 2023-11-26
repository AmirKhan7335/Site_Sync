import 'package:amir_khan1/screens/schedulescreen.dart';
import 'package:amir_khan1/screens/taskdetailsscreen.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'notificationsscreen.dart';


//Chat Screen
class MessageChat {
  final String sender;
  final String text;

  MessageChat(this.sender, this.text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  int currentIndex1 = 0;
  final List<MessageChat> personalChats = [
    MessageChat('Alice', 'Hi there!'),
    MessageChat('Bob', 'Hello!'),
    MessageChat('Alice', 'How are you?'),
    MessageChat('Bob', 'I am fine. How about you?'),
  ];

  final List<MessageChat> groupChats = [
    MessageChat('Group 1', 'Hey everyone!'),
    MessageChat('Group 2', 'Good morning!'),
    MessageChat('Group 1', 'What are we doing today?'),
    MessageChat('Group 2', 'Lets plan an outing!'),
    // Add more group chat messages here
  ];

  List<MessageChat> currentChatList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the currentChatList with personal chats
    currentChatList = personalChats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212832),
        title:  const Center(child: Text("Messages")),
      ),
      backgroundColor: const Color(0xFF212832),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex1 = 0; // Switch to "Chat"
                      currentChatList = personalChats; // Show personal chats
                    });
                  },
                  child: Container(
                    width: 180,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color:
                    currentIndex1 == 0 ? Colors.yellow : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                          currentIndex1 == 0 ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex1 = 1; // Switch to "Groups"
                      currentChatList = groupChats; // Show group chats
                    });
                  },
                  child: Container(
                    width: 180,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color:
                    currentIndex1 == 1 ? Colors.yellow : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                          currentIndex1 == 1 ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentChatList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndividualChatScreen(
                            sender: currentChatList[index].sender),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Text(currentChatList[index].sender[0],
                          style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(currentChatList[index].sender,
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(currentChatList[index].text,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('10:30 AM',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 12.0,
                              height: 12.0,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 376.0,
            height: 60.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ChatListScreen();
                }));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                backgroundColor: Colors.yellow,
              ),
              child: const Text(
                "Start Chat",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        // Set the background color
        currentIndex: currentIndex,
        // Set the current tab index
        onTap: (int index) {
          // Handle tab tap, change the current index
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));
          } else if (index == 2) {
            // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TaskDetailsScreen();
            }));
          } // Navigate to TaskDetailsScreen
          else if (index == 0) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const MyHomePage(title: 'My Home Page');
            })); // Navigate to TaskDetailsScreen
          } else if (index == 3) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const ScheduleScreen();
            })); // Navigate to TaskDetailsScreen
          } else {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const NotificationsScreen();
            })); // Navigate to TaskDetailsScreen
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 30.0),
                ),
              ),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        // Set the height of the BottomNavigationBar
        // Adjust this value as needed
        iconSize: 20.0,
      ),
    );
  }
}

//start chat button screen
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen (chat screen).
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(
                backgroundColor: Colors.yellow, child: Icon(Icons.group_add)),
            title: Text('Create a group'),
          ),
          ChatListItem(
              name: 'Aslam', details: '(C - Bhittai Mess)', initial: 'A'),
          ChatListItem(name: 'Tanveer', details: '(C - CIPS)', initial: 'T'),
          ChatListItem(name: 'Kamran', details: '(E - NSTP)', initial: 'K'),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String name;
  final String details;
  final String initial;

  const ChatListItem({
    super.key,
    required this.name,
    required this.details,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(name),
      subtitle: Text(details),
    );
  }
}

//personal chats
class IndividualChatScreen extends StatelessWidget {
  final String sender;

  const IndividualChatScreen({Key? key, required this.sender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Text(sender[0], style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sender, style: const TextStyle(fontSize: 18)),
                    const Text('Online',
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF212832),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Chat interface for $sender'),
            ),
          ),
          const ChatInputArea()
        ],
      ),
    );
  }
}

//chat input area screen
class ChatInputArea extends StatefulWidget {
  const ChatInputArea({Key? key}) : super(key: key);

  @override
  ChatInputAreaState createState() => ChatInputAreaState();
}

class ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Photo & Video Library'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () {},
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
      color: const Color(0xFF263238),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          // "+" Button to show additional options
          IconButton(
            icon: const Icon(Icons.add, color: Colors.yellow),
            onPressed: _showOptions,
          ),
          // Container for TextField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
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
                    onPressed: () {
                      // Handle the stickers button action here
                    },
                  ),
                ),
              ),
            ),
          ),
          // Camera Button
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.yellow),
            onPressed: () {},
          ),
          // Send or Mic Button based on whether the user is typing
          _isTyping
              ? IconButton(
            icon: const Icon(Icons.send, color: Colors.yellow),
            onPressed: () {},
          )
              : IconButton(
            icon: const Icon(Icons.mic, color: Colors.yellow),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

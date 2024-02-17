import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/engineer_screens/engChatscreen.dart';
import 'chatlistitem.dart';
import 'individualchatscreen.dart'; // Import your IndividualChatScreen

class ChatListScreen extends StatefulWidget {
  final ChatUser? user;

  ChatListScreen({super.key, required this.user});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  String chatRoomId = ''; // Initialize chatRoomId as an empty string
  List<ChatUser> validUsers = [];
  bool isLoading = true;
  bool userSelected = false; // Track whether a user is selected
  ChatUser? selectedUser;

  @override
  void initState() {
    super.initState();
    loadValidUsers();
  }

  Future<void> loadValidUsers() async {
    setState(() => isLoading = true);

    try {
      final usersData = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();
      validUsers = usersData.docs.map((doc) {
        final Map<String, dynamic> data =
            doc.data(); // Cast to Map<String, dynamic>
        return ChatUser(
          id: doc.id,
          name: data['username'] ?? '',
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function to set chatRoomId when a user is selected
  Future<void> setUserSelected(ChatUser user) async {
    setState(() {
      selectedUser = user;
      userSelected = true;
      // Generate chatRoomId when a user is selected
      chatRoomId = getChatRoomId(
        FirebaseAuth.instance.currentUser?.email ?? '',
        selectedUser?.id ?? '', // Handle null selectedUser
      );
    });

    // Remove the current screen from the navigation stack
    // Navigator.of(context).pop();

    // Navigate to the individual chat screen
   await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(
          user: selectedUser!,
          chatRoomId: chatRoomId, // Pass chatRoomId
          selectedUser: selectedUser!, // Pass selectedUser
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: userSelected
          ? null // Remove the AppBar when a user is selected
          : AppBar(
              title: const Text('Valid Users'),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : userSelected
              ? IndividualChatScreen(
                  user: selectedUser!,
                  chatRoomId: chatRoomId, // Pass chatRoomId
                  selectedUser: selectedUser!, // Pass selectedUser
                )
              : validUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: validUsers.length,
                      itemBuilder: (context, index) {
                        final user = validUsers[index];
                        return ChatListItem(
                          user: user,
                          onTap: () {
                            // Call setUserSelected when a user is tapped
                            setUserSelected(
                              user,
                            );
                          },
                        );
                      },
                    )
                  : const Center(child: Text('No users available')),
    );
  }
}

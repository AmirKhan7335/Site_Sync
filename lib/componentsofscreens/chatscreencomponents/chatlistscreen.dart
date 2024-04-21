import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/engineer_screens/chatscreen.dart';
import 'chatlistitem.dart';
import 'individualchatscreen.dart'; // Import your IndividualChatScreen

class ChatListScreen extends StatefulWidget {
  final ChatUser? user;
  final bool isClient;
  const ChatListScreen({super.key, required this.user, required this.isClient});

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

  checkRole() async {
    final user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.email)
        .get();
    String getRole = await userSnapshot['role'];
    return getRole;
  }

  Future<void> loadValidUsers() async {
    setState(() => isLoading = true);

    try {
      final userEmail = await FirebaseAuth.instance.currentUser!.email;

      final role = await checkRole();
      if (role == 'Consultant') {
        //For Consultant Valid Users:
        final consltData = await FirebaseFirestore.instance
            .collection('engineers')
            .where('consultantEmail', isEqualTo: userEmail)
            .get();
        final docIds = await consltData.docs.map((doc) {
          return doc.id;
        }).toList();

        final usersData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: docIds)
            .get();

        validUsers = usersData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        //-------------------For Client--------------------------
        final consltClientData = await FirebaseFirestore.instance
            .collection('clients')
            .where('consultantEmail', isEqualTo: userEmail)
            .get();
        final docClientIds = await consltClientData.docs.map((doc) {
          return doc.id;
        }).toList();

        final usersClientData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: docClientIds)
            .get();

        var validClientUsers = usersClientData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        validUsers.addAll(validClientUsers);
        //-------------------------------------------------------
      }
      else if (role == 'Contractor') {
        //For Consultant Valid Users:
        final consltData = await FirebaseFirestore.instance
            .collection('engineers')
            .where('consultantEmail', isEqualTo: userEmail)
            .get();
        final docIds = await consltData.docs.map((doc) {
          return doc.id;
        }).toList();
        final usersData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: docIds)
            .get();

        validUsers = usersData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        //----Contractor Contributions----------------------------------------

        final contractorQuery = await FirebaseFirestore.instance
            .collection('contractor')
            .doc(userEmail)
            .collection('projects')
            .where('reqAccepted', isEqualTo: true)
            .get();
//-----------------------------------------------------------------
        final consultantEmail =
        contractorQuery.docs.map((e) => e['consultantEmail']);
        final subData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: consultantEmail)
            .get();

        final validConslt = subData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        validUsers.addAll(validConslt);
//--------------------------------------------------------------------
        final contrProjId = contractorQuery.docs.map((e) => e['projectId']);
//////////////////////////////////////////////////////////////////
        ///For Client-----------------------------------------------------
        final contrClientData = await FirebaseFirestore.instance
            .collection('clients')
            .where('projectId', whereIn: contrProjId)
            .get();
        final contrClientdocIds = await contrClientData.docs.map((doc) {
          return doc.id;
        }).toList();
        final contrusersClientData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: contrClientdocIds)
            .get();

        final validClientContrUsers = contrusersClientData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        validUsers.addAll(validClientContrUsers);
//////////////////////////////////////////////////////////
        final contrData = await FirebaseFirestore.instance
            .collection('engineers')
            .where('projectId', whereIn: contrProjId)
            .get();
        final contrdocIds = await contrData.docs.map((doc) {
          return doc.id;
        }).toList();
        final contrusersData = await FirebaseFirestore.instance
            .collection('users')
        // .where('email',
        //     isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where(FieldPath.documentId, whereIn: contrdocIds)
            .get();

        final validContrUsers = contrusersData.docs.map((doc) {
          final Map<String, dynamic> data =
          doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id,
            name: data['username'] ?? '',
          );
        }).toList();
        validUsers.addAll(validContrUsers);
        //====================================================================
      } else if (role == 'Engineer') {
        final query = await FirebaseFirestore.instance
            .collection('engineers')
            .doc(userEmail)
            .get();

        final consltEmail = query.data()!['consultantEmail'];
        final usersData = await FirebaseFirestore.instance
            .collection('users')
            .doc(consltEmail)
            .get();
        validUsers = [
          ChatUser(id: consltEmail, name: usersData.data()!['username'])
        ];
      }
      else if (role == 'Client') {
        //------------------------------------------------
        var projIdForClient = await FirebaseFirestore.instance
            .collection('clients')
            .doc(userEmail)
            .get();
        var clientProjectId = projIdForClient.data()!['projectId'];
        var sameEngineer = await FirebaseFirestore.instance
            .collection('engineers')
            .where('projectId', isEqualTo: clientProjectId)
            .get();
        if (sameEngineer.docs.isNotEmpty) {
          var engEmails = sameEngineer.docs.map((e) => e.id).toList();
          final data = await FirebaseFirestore.instance
              .collection('users')
              .doc(engEmails[0])
              .get();
          var users = [
            ChatUser(id: engEmails[0], name: data.data()!['username'])
          ];

          ///----------------------------------------------------
          final query = await FirebaseFirestore.instance
              .collection('clients')
              .doc(userEmail)
              .get();

          final consltEmail = query.data()!['consultantEmail'];
          print('Consultant Email: $consltEmail');
          final usersData = await FirebaseFirestore.instance
              .collection('users')
              .doc(consltEmail)
              .get();
          validUsers = [
            ChatUser(id: consltEmail, name: usersData.data()!['username'])
          ];
          validUsers.addAll(users);
        } else {
          final query = await FirebaseFirestore.instance
              .collection('clients')
              .doc(userEmail)
              .get();

          final consltEmail = query.data()!['consultantEmail'];
          print('Consultant Email: $consltEmail');
          final usersData = await FirebaseFirestore.instance
              .collection('users')
              .doc(consltEmail)
              .get();
          validUsers = [
            ChatUser(id: consltEmail, name: usersData.data()!['username'])
          ];
        }
      }
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
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              title: const Text('Valid Users',
                  style: TextStyle(color: Colors.black)),
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
                  : const Center(
                      child: Text('No users available',
                          style: TextStyle(color: Colors.black))),
    );
  }
}

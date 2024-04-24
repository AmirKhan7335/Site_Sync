import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/engineer_screens/chatscreen.dart';
import 'chatlistitem.dart';
import 'individualchatscreen.dart'; // Import your IndividualChatScreen

class ChatListScreen extends StatefulWidget {
  final ChatUser? user;

  ChatListScreen({super.key, required this.user, required this.isClient});

  bool isClient;

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
        //------------------------for Contractor-------------------------------
        final consltContractorData = await FirebaseFirestore.instance
            .collection('contractors')
            .where('consultantEmail', isEqualTo: userEmail)
            .get();
        final docContractorProjectIds = consltContractorData.docs.map((doc) {
          return doc['projectId'];
        }).toList();

        final List<String> contractorProjectIds = [];

        for (var projectId in docContractorProjectIds) {
          contractorProjectIds.add(projectId);
        }

        final List<String> contractorNames = [];

// Fetch contractor names from the "Projects" collection
        for (var projectId in contractorProjectIds) {
          final projectDoc = await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .get();

          final contractorName = projectDoc.data()?['contractorName'];
          if (contractorName != null) {
            contractorNames.add(contractorName);
          }
        }

        final usersContractorsData = await FirebaseFirestore.instance
            .collection('users')
            .where('username', whereIn: contractorNames)
            .get();

        var validContractorUsers = usersContractorsData.docs.map((doc) {
          final Map<String, dynamic> data = doc.data(); // Cast to Map<String, dynamic>
          return ChatUser(
            id: doc.id, // Assuming the document ID is the email
            name: data['username'] ?? '',
          );
        }).toList();
        validUsers.addAll(validContractorUsers);
      } else if (role == 'Contractor') {
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
        final projectId1 = query.data()!['projectId'];
        final usersData = await FirebaseFirestore.instance
            .collection('users')
            .doc(consltEmail)
            .get();
        var validUsers1 = [
          ChatUser(id: consltEmail, name: usersData.data()!['username'])
        ];

        ///----------------------------------------------------Client
        final query2 = await FirebaseFirestore.instance
            .collection('Projects')
            .doc(projectId1)
            .get();
        final clientName = query2.data()!['clientName'];

        // Query for the user with the specified username
        final query3 = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: clientName)
            .get();
        String clientEmail = ' ';
        // Check if there are any documents returned
        if (query3.docs.isNotEmpty) {
          // Access the first document in the query result
          clientEmail = query3.docs.first.data()['email'];
          print('Consultant Email: $clientEmail');
        } else {
          // Handle the case where no user with the specified username is found
          print('No user found with the username: $clientName');
        }
        var validUsers2 = [ChatUser(id: clientEmail, name: clientName)];
        validUsers2.addAll(validUsers1);

        ///----------------------------------------------------Contractor
        final query4 = await FirebaseFirestore.instance
            .collection('Projects')
            .doc(projectId1)
            .get();
        final contractorName = query4.data()!['contractorName'];
        // Query for the user with the specified username
        final query5 = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: contractorName)
            .get();
        String contractorEmail = ' ';
        // Check if there are any documents returned
        if (query5.docs.isNotEmpty) {
          // Access the first document in the query result
          contractorEmail = query5.docs.first.data()['email'];
          print('Contractor Email: $contractorEmail');
        } else {
          // Handle the case where no user with the specified username is found
          print('No user found with the username: $contractorName');
        }
        validUsers = [ChatUser(id: contractorEmail, name: contractorName)];
        validUsers.addAll(validUsers2);
      } else if (role == 'Client') {
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
          var validUsers1 = [
            ChatUser(id: consltEmail, name: usersData.data()!['username'])
          ];
          validUsers1.addAll(users);
          ///----------------------------------------------------Contractor
          final query4 = await FirebaseFirestore.instance
              .collection('Projects')
              .doc(clientProjectId)
              .get();
          final contractorName = query4.data()!['contractorName'];
          // Query for the user with the specified username
          final query5 = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: contractorName)
              .get();
          String contractorEmail = ' ';
          // Check if there are any documents returned
          if (query5.docs.isNotEmpty) {
            // Access the first document in the query result
            contractorEmail = query5.docs.first.data()['email'];
            print('Contractor Email: $contractorEmail');
          } else {
            // Handle the case where no user with the specified username is found
            print('No user found with the username: $contractorName');
          }
          validUsers = [ChatUser(id: contractorEmail, name: contractorName)];
          validUsers.addAll(validUsers1);
        } else {
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
          }
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
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text('Valid Users',
                  style: TextStyle(color: Colors.black)),
        centerTitle: true,
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

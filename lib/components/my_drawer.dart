import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => MyDrawerState();
}

class MyDrawerState extends State<MyDrawer> {
  final user = FirebaseAuth.instance.currentUser;

  // Fetch username asynchronously
  Future<String> fetchUsername() async {
    try {
      // Replace 'users' with your Firestore collection name
      // Assuming the user document has a field named 'username'
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user?.email).get();
      if (userSnapshot.exists) {
        return userSnapshot['username'];
      } else {
        return 'Guest'; // Default username for guests
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
      return 'Error';
    }
  }

  // Logout user
  void logout(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromARGB(255, 177, 178, 179), // Set the overall background color
        child: FutureBuilder<String>(
          // Fetch the username asynchronously
          future: fetchUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Display a loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // Drawer header
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.white, // Set the background color
                        ),
                        accountName: Text(
                          snapshot.data ?? 'Guest',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black // Set the font weight
                          ),
                        ),
                        accountEmail: Text(
                          user?.email ?? 'guest@gmail.com',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:Colors.black // Set the font weight
                          ),
                        ),
                      ),
                      const SizedBox(height: 25,),
                      // Home tile
                      Padding(
                        padding: const EdgeInsets.only(left: 25,),
                        child: ListTile(
                          leading: const Icon(Icons.home,color: Colors.black,),
                          title: const Text('HOME',style: TextStyle(color: Colors.black)),
                          onTap: () {
                            // this is already the home screen so just pop drawer
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      // Profile tile
                      Padding(
                        padding: const EdgeInsets.only(left: 25,),
                        child: ListTile(
                          leading: const Icon(Icons.person,color: Colors.black,),
                          title: const Text('PROFILE',style: TextStyle(color: Colors.black)),
                          onTap: () {
                            // this is already the home screen so just pop drawer
                            Navigator.pop(context);
                            // navigate to profile page
                            Navigator.pushNamed(context, '/profile_page');
                          },
                        ),
                      ),
                      // Users tile
                      Padding(
                        padding: const EdgeInsets.only(left: 25,),
                        child: ListTile(
                          leading: const Icon(Icons.group,color:Colors.black),
                          title: const Text('USERS',style: TextStyle(color: Colors.black)),
                          onTap: () {
                            // this is already the home screen so just pop drawer
                            Navigator.pop(context);
                            // navigate to users page
                            Navigator.pushNamed(context, '/users_page');
                          },
                        ),
                      ),
                    ],
                  ),
                  // Logout tile
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 25,),
                    child: ListTile(
                      leading: const Icon(Icons.group,color: Colors.black,),
                      title: const Text('LOGOUT',style: TextStyle(color: Colors.black)),
                      onTap: () {
                        Navigator.pop(context);
                        logout(context);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


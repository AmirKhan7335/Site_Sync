import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/pages/profile_page.dart';
import 'package:amir_khan1/pages/users_page.dart';
import 'package:amir_khan1/screens/chatscreen.dart';
import 'package:amir_khan1/screens/createaccountscreen.dart';
import 'package:amir_khan1/screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:amir_khan1/screens/schedulescreen.dart';
import 'package:amir_khan1/screens/signinscreen.dart';
import 'package:amir_khan1/screens/splashscreen.dart';
import 'package:amir_khan1/screens/taskdetailsscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth/auth.dart';
import 'components/my_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ctrl+alt+l = format code
// signin screen = log in page
// create account screen =  register page
// signup or createaccount = login or register page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

int currentPage = 0;
int currentIndex = 0; // Index of the selected tab

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/profile_page': (context) => ProfilePage(),
        '/users_page': (context) => const UsersPage(),
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const MyHomePage(title: 'My Home Page'),
        '/signin': (context) => SigninScreen(
              onTap: () {},
            ),
        '/createaccount': (context) => CreateAccountScreen(
              onTap: () {},
            ),
        '/role': (context) => const Role(),
        '/chat': (context) => const ChatScreen(),
        '/taskdetails': (context) => const TaskDetailsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

Widget buildIndicator(int index, int currentPage) {
  return Container(
    margin: const EdgeInsets.all(4.0),
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: index == currentPage ? Colors.blue : Colors.grey,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final PageController pageController = PageController();
  final user = FirebaseAuth.instance.currentUser;

  Future<String> fetchUsername() async {
    try {
      // Replace 'users' with your Firestore collection name
      // Assuming the user document has a field named 'username'
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: const MyDrawer(),
      backgroundColor: const Color(0xFF212832),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<String>(
            // Fetch the username asynchronously
            future: fetchUsername(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Display a loading indicator while fetching data
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back!",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.yellow),
                            ),
                            const SizedBox(height: 0),
                            // Display the user's name if available
                            Text(
                              snapshot.data ?? 'Guest',
                              // _user != null ? _user!.displayName ?? "Guest" : "Guest",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                  fontSize: 22, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(), // Pushes the avatar to the end
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/image.jpg'),
                          radius: 30, // Adjusted the radius, might need further adjustment
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 48.0,
                      child: Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10.0),
                                  // Adjust this value as needed
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.white), // Set the hint text color to white
                                  prefixIcon: Icon(Icons.search, color: Colors.white),
                                  filled: true,
                                  fillColor: Color(0xFF6B8D9F),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                    borderSide: BorderSide
                                        .none, // This removes the default border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: Colors
                                            .blue), // You can adjust the focused border color as needed
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            PageView(
                              physics: const BouncingScrollPhysics(),
                              controller: pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                              children: const [
                                PageOne(),
                                PageTwo(),
                                PageThree(),
                              ],
                            ),
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < 3; i++)
                                    buildIndicator(i, currentPage),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's activity",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        // Text("See all",
                        //     style: TextStyle(
                        //         fontSize: 18, color: Colors.yellowAccent)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 10, bottom: 16, right: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8D9F),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Excavation",
                                  style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 80),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: const Center(
                                  child: Text("4 Days left",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Text("Due: 21 March",
                                  style: TextStyle(fontSize: 14)),
                              SizedBox(width: 50),
                              Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 150,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Completed",
                                              style: TextStyle(fontSize: 14)),
                                          Text("50%",
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      LinearProgressIndicator(
                                        value: 0.5,
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Upcoming activity",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left:16.0, right: 16, top: 10, bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8D9F),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Foundation", style: TextStyle(fontSize: 28)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text("Starts: 26 March",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const TaskDetailsScreen();
            }));
          } // Navigate to TaskDetailsScreen
          else if (index == 0) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const MyHomePage(title: 'My Home Page');
            })); // Navigate to TaskDetailsScreen
          } else if (index == 3) {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const ScheduleScreen();
            })); // Navigate to TaskDetailsScreen
          } else {
            // Assuming "Add" icon is at index 2
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
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

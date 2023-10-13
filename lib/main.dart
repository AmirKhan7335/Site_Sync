import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());
int currentIndex = 0; // Index of the selected tab

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final double radius = size.width * 0.9326 / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // start angle
      -2 * pi * 0.75, // sweep angle (-270 degrees)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Widget buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPageIndex == index ? Colors.blue : Colors.grey,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      backgroundColor: const Color(0xFF212832),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back!",
                        style: TextStyle(fontSize: 18, color: Colors.yellow),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Amir Khan",
                        style: TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                  Spacer(),  // Pushes the avatar to the end
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/image.jpg'),
                    radius: 40, // Adjusted the radius, might need further adjustment
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
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),  // Adjust this value as needed
                            hintText: "Search Tasks",
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Color(0xFF455A64),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide.none,  // This removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(width: 1, color: Colors.blue),  // You can adjust the focused border color as needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height:250,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 18.0, top: 10.0, bottom: 10.0, right: 0.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2935),  // Adjusted color here
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.0, 0.0, 0.0, 0, 255, // red channel
                                0.0, 0.0, 0.0, 0, 255, // green channel
                                0.0, 0.0, 0.0, 0, 0,   // blue channel to minimum
                                0.0, 0.0, 0.0, 1, 0,   // alpha channel
                              ]),
                              child: Image.asset('assets/images/progress_image.png'),
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Move "Status: On Time" text upwards
                                  Transform.translate(
                                    offset: const Offset(2, 2), // Adjust the vertical offset as needed
                                    child: const Text("Status: On Time", style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(4, 7), // Adjust the vertical offset as needed
                                    child: const Text("Start Date: 21 May, 2022", style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(6, 12), // Adjust the horizontal offset as needed
                                    child: const Text("End Date: 21 March, 2023", style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ),
                                ],
                              ), 
                              const SizedBox (width:20),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Ellipse with a thin border
                                  Container(
                                    height: 116.17,
                                    width: 116.98,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 8,
                                      ),
                                    ),
                                  ),
                                  // Inner Ellipse with custom paint
                                  SizedBox(
                                    height: 116,
                                    width: 117,
                                    child: CustomPaint(
                                      painter: ArcPainter(),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text("75%", style: TextStyle(fontSize: 30)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) => buildIndicator(index)),
                              ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 18.0, top: 2.0, bottom: 2.0, right: 0.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2935),  // Adjusted color here
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.0, 0.0, 0.0, 0, 255, // red channel
                                0.0, 0.0, 0.0, 0, 255, // green channel
                                0.0, 0.0, 0.0, 0, 0,   // blue channel to minimum
                                0.0, 0.0, 0.0, 1, 0,   // alpha channel
                              ]),
                              child: Image.asset('assets/images/budget_icon.png'),
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Move "Status: On Time" text upwards
                                  Transform.translate(
                                    offset: const Offset(2, 0), // Adjust the vertical offset as needed
                                    child: const Text("Total Budget:\n105,649,534", style: TextStyle(fontSize: 23, color: Colors.white)),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(2, 7), // Adjust the vertical offset as needed
                                    child: const Text("Received:\n 65,649,534", style: TextStyle(fontSize: 23, color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox (width:80),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Ellipse with a thin border
                                  Container(
                                    height: 116.17,
                                    width: 116.98,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 8,
                                      ),
                                    ),
                                  ),
                                  // Inner Ellipse with custom paint
                                  SizedBox(
                                    height: 116,
                                    width: 117,
                                    child: CustomPaint(
                                      painter: ArcPainter(),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text("75%", style: TextStyle(fontSize: 30)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => buildIndicator(index)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 18.0, top: 2.0, bottom: 2.0, right: 0.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2935),  // Adjusted color here
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          const Center(child: Text('Weather', style: TextStyle(fontSize:30),)),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.matrix([
                                        0.0, 0.0, 0.0, 0, 255, // red channel
                                        0.0, 0.0, 0.0, 0, 255, // green channel
                                        0.0, 0.0, 0.0, 0, 0,   // blue channel to minimum
                                        0.0, 0.0, 0.0, 1, 0,   // alpha channel
                                      ]),
                                      child: Image.asset('assets/images/cloud_icon.png'),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(2, 7), // Adjust the vertical offset as needed
                                    child: RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                              text: 'Heavy Rain',
                                              style: TextStyle(fontSize: 27, color: Colors.white) // Increased size to 40
                                          ),
                                          TextSpan(
                                              text: '\nTomorrow 11 PM',
                                              style: TextStyle(fontSize: 18, color: Colors.white)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox (width:60),
                              Transform.translate(
                                offset: const Offset(2, 7), // Adjust the vertical offset as needed
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                          text: ' 26°',
                                          style: TextStyle(fontSize: 80, color: Colors.white) // Increased size to 40
                                      ),
                                      TextSpan(
                                          text: '\nCurrent Weather',
                                          style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => buildIndicator(index)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's activity", style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("See all", style: TextStyle(fontSize: 18, color: Colors.yellowAccent)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF455A64),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Excavation", style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 110),
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text("4 Days left", style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Text("Due: 21 March", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 50),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 180,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Completed", style: TextStyle(fontSize: 16)),
                                    Text("50%", style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: 0.5,
                                  backgroundColor: Colors.grey,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
                  Text("Upcoming activity", style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF455A64),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Foundation", style: TextStyle(fontSize: 28)),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("Starts: 26 March", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow, // Set the background color
        currentIndex: currentIndex, // Set the current tab index
        onTap: (int index) {
          // Handle tab tap, change the current index
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));}
          else if (index == 2) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const TaskDetailsScreen();
            }));}  // Navigate to TaskDetailsScreen
          else if (index == 0) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const MyHomePage(title: 'My Home Page');
            }));  // Navigate to TaskDetailsScreen
          }
          else if (index == 3) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const ScheduleScreen();
            }));  // Navigate to TaskDetailsScreen
          }
          else { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const NotificationsScreen();
            }));  // Navigate to TaskDetailsScreen
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
                  child: const Icon(Icons.add,color: Colors.black, size: 30.0),
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


// splash screen
class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212832),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
                width: 300,
                height: 300,
                child: Image.asset('assets/images/logo1.png')),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text ('Construction Progress Tracking',
              style: TextStyle(fontSize: 46.0, color: Colors.white),
              textAlign: TextAlign.center, // Center-align the text within the Text widget
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          SizedBox(
            width: 376.0,
            height: 67.0,
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const CreateAccountScreen();
                }));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),  // Set the border radius to 15
                ),
                backgroundColor: Colors.yellow,
              ),
              child: const Text(
                "Let's Start",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//Create Account
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _isPasswordVisible = false;
  bool isChecked = false; // Define the _isChecked variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account Screen')),
      backgroundColor: const Color(0xFF212832),
      body:  SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              // Logo
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/logo1.png'), // Make sure you have an image named 'logo.png' in your assets/images directory
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 30,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 19.0,
                      color: Color(0xff8CAAB9), // Setting the color here
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: 58,
                  width: 376,
                  color: Colors.blueGrey,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.contacts, color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none, // Remove the default border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.yellow),
                      ),
                      fillColor: Colors.blueGrey, // Optional: Match the container color
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(
                height: 30,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text(
                    'Email Address',
                    style: TextStyle(fontSize: 19.0, color: Color(0xff8CAAB9)),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: 58,
                  width: 376,
                  color: Colors.blueGrey,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email, color: Colors.grey,),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.yellow),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.transparent), // Adjust border color as needed
                      ),
                      fillColor: Colors.blueGrey, // Optional: Match the container color
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(
                height: 30,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text(
                    'Password',
                    style: TextStyle(fontSize: 19.0, color: Color(0xff8CAAB9)),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: 58,
                  width: 376,
                  color: Colors.blueGrey,
                  child: TextField(
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.yellow),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.transparent), // Adjust border color as needed
                      ),
                      fillColor: Colors.blueGrey, // Optional: Match the container color
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading, // Position the checkbox to the left
                title: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "I have read and agreed to ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff8CAAB9), // Set the color of the first part of the text to grey
                        ),
                      ),
                      TextSpan(
                        text: "Privacy Policy, Terms and Conditions",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.yellow, // Set the color of the second part of the text to yellow
                        ),
                      ),
                    ],
                  ),
                ),
                activeColor: Colors.yellow, // Set the color of the checkbox to yellow
                value: isChecked, // Whether the checkbox is checked or not
                onChanged: (newValue) {
                  // Handle the checkbox state change
                  setState(() {
                    isChecked = newValue!;
                  });
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 376.0,
                height: 55.0,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return const Role();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),  // Set the border radius to 15
                    ),
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 376.0,
                child: Row(
                  children: [
                    Container(
                      width: 111,
                      height: 1,
                      color: const Color(0xff8CAAB9), // Color of the line
                    ),
                    const SizedBox(width:25),
                    const Text(
                      'Or continue with',
                      style: TextStyle(
                        color: Color(0xff8CAAB9),
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width:25),
                    Container(
                      width: 111,
                      height: 1,
                      color: const Color(0xff8CAAB9), // Color of the line
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300.0,
                height: 50.0,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add sign in with Google functionality
                  },
                  icon: const Icon(Icons.account_circle, color: Colors.white), // You can change this to a Google logo if you have one
                  label: const Text("Sign in with Google"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    backgroundColor: Colors.blue, // Google's color
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xff8CAAB9),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
// TODO: Navigate to Sign Up page
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.yellow,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
//Role
class Role extends StatefulWidget {
  const Role({Key? key}) : super(key: key);

  @override
  RoleState createState() => RoleState();
}

class RoleState extends State<Role> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select your role')),
      backgroundColor: const Color(0xFF212832),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              // Logo
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/logo1.png'), // Make sure you have an image named 'logo.png' in your assets/images directory
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),

              // "Create Account" text
              const Text(
                'Select your Role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ), backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0), // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                          'Engineer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ), backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0), // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Client',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ), backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0), // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Consultant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ), backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0), // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Contractor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 376.0,
                height: 67.0,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return const SigninScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),  // Set the border radius to 15
                    ),
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }
}
//Sign in Screen
class SigninScreen extends StatefulWidget {
   const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool _isPasswordVisible = false;  // Track password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212832),
      appBar: AppBar(
        title: const Text('Sign in Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/logo1.png'), // Make sure you have an image named 'logo.png' in your assets/images directory
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 30),
            const SizedBox(
              height: 30,
              width: double.infinity,
              child: Center(
                child: Text(
                    'WELCOME BACK!',
                    style: TextStyle(fontSize: 23.0, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 30,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  'Email Address',
                  style: TextStyle(fontSize: 20.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Container(
              height: 58,
              width: 376,
              color: Colors.blueGrey,
              child: const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email, color: Colors.grey,),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 30,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  'Password',
                  style: TextStyle(fontSize: 20.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Container(
              height: 58,
              width: 376,
              color: Colors.blueGrey,
              child: TextField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey,),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: TextButton(
                  onPressed: () {
                    // TODO: Add functionality for Forgot Password
                  },
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 376.0,
              height: 60.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyHomePage(title: "HOME PAGE");
                  }));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  backgroundColor: Colors.yellow,
                ),
                child: const Text(
                  "Log In",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 376.0,
              child: Row(
                children: [
                  Container(
                    width: 111,
                    height: 1,
                    color: const Color(0xff8CAAB9), // Color of the line
                  ),
                  const SizedBox(width:25),
                  const Text(
                    'Or continue with',
                    style: TextStyle(
                      color: Color(0xff8CAAB9),
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(width:25),
                  Container(
                    width: 111,
                    height: 1,
                    color: const Color(0xff8CAAB9), // Color of the line
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 376.0,
              height: 60.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add sign in with Google functionality
                },
                icon: const Icon(Icons.account_circle, color: Colors.white), // You can change this to a Google logo if you have one
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  backgroundColor: Colors.blue, // Google's color
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                TextButton(
                  onPressed: () {
// TODO: Navigate to Sign Up page
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//Task details screen
class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  // To maintain the state of the checkbox
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212832),
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 370,
                height: 50,
                color: const Color(0xFF455A64),
                child: const Center(
                  child: Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text('Due Date:\nSeptember 30, 2023', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 25),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                    ),
                    child: const Icon(Icons.group, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text('Project Team', style: TextStyle(fontSize: 16)),
                ],
              ),

              const SizedBox(height: 16),
              Container(
                width: 370,
                height: 43,
                color: const Color(0xFF455A64),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Project Details',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Task Description goes here. This is a longer description of the task that provides more details about what needs to be done.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 370,
                height: 70,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: [
                        const Text(
                          'Project Progress',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 108),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Ellipse with a thin border
                            Container(
                              height: 68,
                              width: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Inner Ellipse with custom paint
                            SizedBox(
                              height: 58,
                              width: 58,
                              child: CustomPaint(
                                painter: ArcPainter(),
                              ),
                            ),
                            const Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text("75%", style: TextStyle(fontSize: 22)),
                              ),
                            ),
                          ],
                        ),
                      ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All Tasks',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 370,
                height: 58,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Site Preparation', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 200),
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.yellow, // Yellow background color
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24, // Adjust this value
                              height: 24, // Adjust this value
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent, // Make it transparent
                              ),
                              child: Checkbox(
                                value: isChecked1,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isChecked1 = newValue ?? false;
                                  });
                                },
                                checkColor: Colors.black, // Color of the tick mark
                                fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.transparent;
                                  }
                                  return null;  // Use the default (null means transparent here)
                                }),
                                activeColor: Colors.transparent, // Make it transparent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 370,
                height: 58,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Foundation', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 233),
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.yellow, // Yellow background color
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24, // Adjust this value
                              height: 24, // Adjust this value
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent, // Make it transparent
                              ),
                              child: Checkbox(
                                value: isChecked2,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isChecked2 = newValue ?? false;
                                  });
                                },
                                checkColor: Colors.black, // Color of the tick mark
                                fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.transparent;
                                  }
                                  return null;  // Use the default (null means transparent here)
                                }),
                                activeColor: Colors.transparent, // Make it transparent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 370,
                height: 58,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Framework', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 234),
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.yellow, // Yellow background color
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24, // Adjust this value
                              height: 24, // Adjust this value
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent, // Make it transparent
                              ),
                              child: Checkbox(
                                value: isChecked3,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isChecked3 = newValue ?? false;
                                  });
                                },
                                checkColor: Colors.black, // Color of the tick mark
                                fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.transparent;
                                  }
                                  return null;  // Use the default (null means transparent here)
                                }),
                                activeColor: Colors.transparent, // Make it transparent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 370,
                height: 58,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Roofing', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 259),
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.yellow, // Yellow background color
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24, // Adjust this value
                              height: 24, // Adjust this value
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent, // Make it transparent
                              ),
                              child: Checkbox(
                                value: isChecked4,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isChecked4 = newValue ?? false;
                                  });
                                },
                                checkColor: Colors.black, // Color of the tick mark
                                fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.transparent;
                                  }
                                  return null;  // Use the default (null means transparent here)
                                }),
                                activeColor: Colors.transparent, // Make it transparent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 370,
                height: 58,
                color: const Color(0xFF455A64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Interior', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 263),
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.yellow, // Yellow background color
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24, // Adjust this value
                              height: 24, // Adjust this value
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent, // Make it transparent
                              ),
                              child: Checkbox(
                                value: isChecked5,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isChecked5 = newValue ?? false;
                                  });
                                },
                                checkColor: Colors.black, // Color of the tick mark
                                fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.transparent;
                                  }
                                  return null;  // Use the default (null means transparent here)
                                }),
                                activeColor: Colors.transparent, // Make it transparent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 376.0,
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const MyHomePage(title: "HOME PAGE");
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Text(
                    "Add Task",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],),),
      ),);
  }
}
//Chat Screen
class Message {
  final String sender;
  final String text;

  Message(this.sender, this.text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  int currentIndex1 = 0;
  final List<Message> personalChats = [
    Message('Alice', 'Hi there!'),
    Message('Bob', 'Hello!'),
    Message('Alice', 'How are you?'),
    Message('Bob', 'I am fine. How about you?'),
  ];

  final List<Message> groupChats = [
  Message('Group 1', 'Hey everyone!'),
  Message('Group 2', 'Good morning!'),
  Message('Group 1', 'What are we doing today?'),
  Message('Group 2', 'Lets plan an outing!'),
  // Add more group chat messages here
  ];

  List<Message> currentChatList = [];

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
  title: const Text("Chat Screen"),
  ),
  backgroundColor: const Color(0xFF212832),
  body: Column(
  children: [
  Row(
  children: [
  GestureDetector(
  onTap: () {
  setState(() {
  currentIndex1 = 0; // Switch to "Chat"
  currentChatList = personalChats; // Show personal chats
  });
  },
  child: Container(
  width: 200,
  height: 50,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  color: currentIndex1 == 0 ? Colors.yellow : Colors.transparent,
  child: Center(
  child: Text(
  'Chat',
  style: TextStyle(
  fontSize: 20,
  color: currentIndex1 == 0 ? Colors.black : Colors.white,
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
  width: 200,
  height: 50,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  color: currentIndex1 == 1 ? Colors.yellow : Colors.transparent,
  child: Center(
  child: Text(
  'Groups',
  style: TextStyle(
  fontSize: 20,
  color: currentIndex1 == 1 ? Colors.black : Colors.white,
  ),
  ),
  ),
  ),
  ),
  ],
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
  builder: (context) => IndividualChatScreen(sender: currentChatList[index].sender),
  ),
  );
  },
  child: ListTile(
  contentPadding: const EdgeInsets.all(10.0),
  leading: CircleAvatar(
  radius: 20,
  backgroundColor: Colors.blue,
  child: Text(currentChatList[index].sender[0], style: const TextStyle(fontSize: 18)),
  ),
  title: Text(currentChatList[index].sender, style: const TextStyle(fontSize: 18)),
  subtitle: Row(
  children: [
  Expanded(
  child: Text(currentChatList[index].text, style: const TextStyle(fontSize: 16)),
  ),
  const SizedBox(width: 20),
  Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  const Text('10:30 AM', style: TextStyle(fontSize: 12, color: Colors.white)),
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
      selectedItemColor: Colors.yellow, // Set the background color
      currentIndex: currentIndex, // Set the current tab index
      onTap: (int index) {
        // Handle tab tap, change the current index
        setState(() {
          currentIndex = index;
        });
        if (index == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()));}
        else if (index == 2) { // Assuming "Add" icon is at index 2
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return const TaskDetailsScreen();
          }));}  // Navigate to TaskDetailsScreen
        else if (index == 0) { // Assuming "Add" icon is at index 2
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return const MyHomePage(title: 'My Home Page');
          }));  // Navigate to TaskDetailsScreen
        }
        else if (index == 3) { // Assuming "Add" icon is at index 2
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return const ScheduleScreen();
          }));  // Navigate to TaskDetailsScreen
        }
        else { // Assuming "Add" icon is at index 2
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return const NotificationsScreen();
          }));  // Navigate to TaskDetailsScreen
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
                child: const Icon(Icons.add,color: Colors.black, size: 30.0),
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
            leading: CircleAvatar(backgroundColor: Colors.yellow,
                child: Icon(Icons.group_add)),
            title: Text('Create a group'),
          ),
          ChatListItem(name: 'Aslam', details: '(C - Bhittai Mess)', initial: 'A'),
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

  const ChatListItem({super.key,
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


  const IndividualChatScreen({Key? key, required this.sender}) : super(key: key);

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
                    const Text('Online', style: TextStyle(fontSize: 12, color: Colors.green)),
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
                    icon: const Icon(Icons.emoji_emotions, color: Colors.yellow),
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


//Schedule Screen
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: const Color(0xFF212832),
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        children: [
          // Container 1
          _buildActivityContainer(
            'Excavation',
            '2/10/23 - 8/10/23',
            'assets/images/excavator_icon.png',
          ),
          // Container 2
          _buildActivityContainer(
            'Foundation',
            '20/11/23 - 15/12/23',
            'assets/images/foundation_icon.png',
          ),
          _buildActivityContainer(
            'Framing',
            '20/11/23 - 15/12/23',
            'assets/images/excavator_icon.png',
          ),
          _buildActivityContainer(
            'Roofing',
            '20/11/23 - 15/12/23',
            'assets/images/excavator_icon.png',
          ),
          // Add more containers as needed
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow, // Set the background color
        currentIndex: currentIndex, // Set the current tab index
        onTap: (int index) {
          // Handle tab tap, change the current index
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));}
          else if (index == 2) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const TaskDetailsScreen();
            }));}  // Navigate to TaskDetailsScreen
          else if (index == 0) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const MyHomePage(title: 'My Home Page');
            }));  // Navigate to TaskDetailsScreen
          }
          else if (index == 3) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const ScheduleScreen();
            }));  // Navigate to TaskDetailsScreen
          }
          else { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const NotificationsScreen();
            }));  // Navigate to TaskDetailsScreen
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
                  child: const Icon(Icons.add,color: Colors.black, size: 30.0),
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

  Widget _buildActivityContainer(String mainHeading, String subHeading, String imagePath) {
    return InkWell(
      onTap: () {
        if (mainHeading == 'Foundation') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FoundationScheduleScreen(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                mainHeading: mainHeading,
                subHeading: subHeading,
                imagePath: imagePath,
              ),
            ),
          );
        }
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
      color: Colors.grey[900], // a dark grey color to match the UI in the image
      borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
      children: [
      Expanded(
      flex: 2,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      mainHeading,
      style: const TextStyle(
      color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    ),
    ),
    const SizedBox(height: 4.0),
    Text(
    subHeading,
    style: const TextStyle(
    color: Colors.grey, // grey color to match the UI in the image
    fontSize: 14.0,
    ),
    ),
    ],
    ),
    ),
    Expanded(
    flex: 1,
    child: Container(
    padding: const EdgeInsets.all(8.0),
    color: Colors.amber, // amber color to match the yellow in the image
    child: Image.asset(
    imagePath,
    fit: BoxFit.contain,
    ),
    ),
    ),
    ],
    ),
    ),
    );
  }
}
// Details screen
class DetailsScreen extends StatelessWidget {
  final String mainHeading;
  final String subHeading;
  final String imagePath;

  const DetailsScreen({super.key,
    required this.mainHeading,
    required this.subHeading,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: const Color(0xFF212832),
      ),
      backgroundColor: const Color(0xFF212832),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            const SizedBox(height: 20),
            Text(
              mainHeading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subHeading,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//foundation schedule screen
class FoundationScheduleScreen extends StatefulWidget {
  const FoundationScheduleScreen({super.key});

  @override
  State<FoundationScheduleScreen> createState() => _FoundationScheduleScreenState();
}

class _FoundationScheduleScreenState extends State<FoundationScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212832),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        children: [
          const Text(
            'Foundation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildActivityTile('Reinforcement Installation', '2/10/23 - 8/10/23'),
          _buildActivityTile('Form work', '9/10/23 - 15/10/23'),
          _buildActivityTile('Concreting', '16/10/23 - 25/11/23'),
          _buildActivityTile('Curing', '20/11/23 - 15/12/23'),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF537789),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.0,
            height: 60,
            color: const Color(0xFFFED36A),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFD2D2D2),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          const Text(
            'Tap to view',
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

//Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        children: const [
          // Add your notifications here
          NotificationItem(
            message: 'Task 3 is completed.',
            timestamp: '2023-10-05 08:30 AM',
          ),
          NotificationItem(
            message: 'New update available for the app.',
            timestamp: '2023-10-10 02:15 PM',
          ),
          // Add more notifications as needed
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow, // Set the background color
        currentIndex: currentIndex, // Set the current tab index
        onTap: (int index) {
          // Handle tab tap, change the current index
          setState(() {
            currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));}
          else if (index == 2) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const TaskDetailsScreen();
            }));}  // Navigate to TaskDetailsScreen
          else if (index == 0) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const MyHomePage(title: 'My Home Page');
            }));  // Navigate to TaskDetailsScreen
          }
          else if (index == 3) { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const ScheduleScreen();
            }));  // Navigate to TaskDetailsScreen
          }
          else { // Assuming "Add" icon is at index 2
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return const NotificationsScreen();
            }));  // Navigate to TaskDetailsScreen
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
                  child: const Icon(Icons.add,color: Colors.black, size: 30.0),
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

class NotificationItem extends StatelessWidget {
  final String message;
  final String timestamp;

  const NotificationItem({super.key, required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message),
      subtitle: Text('Received at: $timestamp'),
      // Add more widgets or actions for each notification item as needed
    );
  }
}

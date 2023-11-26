import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  String username = 'Guest';
  String userEmail = 'guest@gmail.com';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user?.email).get();
      if (userSnapshot.exists) {
        setState(() {
          username = userSnapshot.get('username');
          userEmail = user?.email ?? userEmail;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Profile'),
        backgroundColor: Color(0xFF212832),
      ),
      backgroundColor: Color(0xFF212832),
      body: ListView(
        children: <Widget>[
          UserHeader(username: username, userEmail: userEmail),
          UserInfoTile(label: 'Email', value: userEmail, icon: Icons.email),
          UserInfoTile(label: 'Password', value: '••••••••', icon: Icons.lock),
          UserInfoTile(label: 'Occupation', value: 'Engineer', icon: Icons.work),
          SettingsTile(title: 'Privacy', icon: Icons.privacy_tip),
          SettingsTile(title: 'Setting', icon: Icons.settings),
          LogoutButton(),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  final String username;
  final String userEmail;

  const UserHeader({required this.username, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/image.jpg'),
            radius: 50,
          ),
          SizedBox(height: 10),
          Text(
            username,
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            userEmail,
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const UserInfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
      ),
      trailing: Icon(icon, color: Colors.white),
      onTap: () {},
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingsTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      leading: Icon(icon, color: Colors.white),
      onTap: () {},
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.exit_to_app, color: Colors.white),
        label: Text('Logout', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error during logout: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.yellow,
          minimumSize: Size(double.infinity, 50), // Set the button's size
        ),
      ),
    );
  }
}

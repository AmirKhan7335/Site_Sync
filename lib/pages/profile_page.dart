import 'package:amir_khan1/common/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF212832),
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        children: <Widget>[
          UserHeader(username: username, userEmail: userEmail, user: user),
          UserInfoTile(label: 'Email', value: userEmail, icon: Icons.email),
          const UserInfoTile(label: 'Password', value: '••••••••', icon: Icons.lock),
          const UserInfoTile(label: 'Occupation', value: 'Engineer', icon: Icons.work),
          const SettingsTile(title: 'Privacy', icon: Icons.privacy_tip),
          const SettingsTile(title: 'Setting', icon: Icons.settings),
          const LogoutButton(),
        ],
      ),
    );
  }
}

class UserHeader extends StatefulWidget {
  final String username;
  final String userEmail;
  final User? user;
  const UserHeader({super.key, required this.username, required this.userEmail, required this.user});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  File? image;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.user?.email).get();
      if (userSnapshot.exists) {
        setState(() {
          photoUrl = userSnapshot.get('profilePic');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile picture: $e');
      }
    }
  }

  void selectImage() async {
    File? selectedImage = await pickImageFromGallery(context);
    if (selectedImage != null) {
      setState(() {
        image = selectedImage;
        saveUserDataToFirebase(profilePic: image, name: widget.username, context: context);
      });
    }
  }

  Future<void> saveUserDataToFirebase({required File? profilePic, required String name, required BuildContext context}) async {
    try {
      String email = widget.user?.email ?? '';
      if (profilePic != null) {
        // Upload the image to Firebase Storage
        final String imageUrl = await uploadImageToFirebaseStorage(profilePic, email);
        // Update the user's data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(email).update({
          'name': name,
          'profilePic': imageUrl,
        });
        setState(() {
          photoUrl = imageUrl;
        });
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  Future<String> uploadImageToFirebaseStorage(File image, String email) async {
    final Reference storageReference = FirebaseStorage.instance.ref().child('profilePic/$email');
    final UploadTask uploadTask = storageReference.putFile(image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              image == null
                  ? photoUrl == null
                  ? const CircleAvatar(
                backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                radius: 64,
              )
                  : CircleAvatar(
                backgroundImage: NetworkImage(photoUrl!),
                radius: 64,
              )
                  : CircleAvatar(
                backgroundImage: FileImage(image!),
                radius: 64,
              ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  onPressed: selectImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.username,
            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.userEmail,
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

  const UserInfoTile({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 18),
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

  const SettingsTile({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      leading: Icon(icon, color: Colors.white),
      onTap: () {},
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.exit_to_app, color: Colors.white),
        label: const Text('Logout', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            if (context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
            }
          } catch (e) {
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error during logout: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          minimumSize: const Size(double.infinity, 50), // Set the button's size
        ),
      ),
    );
  }
}

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
  String role = 'Engineer';

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
          role = userSnapshot.get('role');
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
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: ListView(
        children: <Widget>[
          UserHeader(username: username, userEmail: userEmail, user: user),
          UserNameTile(username: username,),
          UserEmailTile(userEmail: userEmail),
          UserRoleTile(role: role),
          const UserPasswordTile(),
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
                  icon: const Icon(Icons.add_a_photo, color: Color(0xFF2CF07F), size: 40,),
                  onPressed: selectImage,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // Text(
          //   widget.username,
          //   style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
          // ),
          // Text(
          //   widget.userEmail,
          //   style: const TextStyle(fontSize: 16, color: Colors.black),
          // ),
        ],
      ),
    );
  }
}

class UserPasswordTile extends StatefulWidget {
  const UserPasswordTile({super.key});

  @override
  State<UserPasswordTile> createState() => _UserPasswordTileState();
}

class _UserPasswordTileState extends State<UserPasswordTile> {
  final String email = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: ListTile(
          title: const Text(
            "Change Password",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: const Icon(Icons.settings, color: Color(0xFF2CF07F)),
          onTap: () {
            // Navigate to a new screen for changing the password
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserNameTile extends StatefulWidget {
  final String username;

  const UserNameTile({super.key, required this.username});

  @override
  State<UserNameTile> createState() => _UserNameTileState();
}

class _UserNameTileState extends State<UserNameTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: ListTile(
          title: Text(
            widget.username,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          trailing: const Icon(Icons.edit, color: Color(0xFF2CF07F)),
          leading: const Icon(Icons.account_circle_outlined, color: Color(0xFF2CF07F)),
          onTap: () {
            // Navigate to a new screen for editing the username
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileField(
                  field: 'username',
                  initialValue: widget.username,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserEmailTile extends StatefulWidget {
  final String userEmail;

  const UserEmailTile({super.key, required this.userEmail});

  @override
  State<UserEmailTile> createState() => _UserEmailTileState();
}

class _UserEmailTileState extends State<UserEmailTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: ListTile(
          title: Text(
            widget.userEmail,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          // trailing: const Icon(Icons.edit, color: Color(0xFF2CF07F)),
          leading: const Icon(Icons.email, color: Color(0xFF2CF07F)),
          onTap: () {
            // // Navigate to a new screen for editing the email
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => EditProfileField(
            //       field: 'email',
            //       initialValue: widget.userEmail,
            //     ),
            //   ),
            // );
          },
        ),
      ),
    );
  }
}

class UserRoleTile extends StatefulWidget {
  final String role;

  const UserRoleTile({super.key, required this.role});

  @override
  State<UserRoleTile> createState() => _UserRoleTileState();
}

class _UserRoleTileState extends State<UserRoleTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: ListTile(
          title: Text(
            widget.role,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: const Icon(Icons.accessibility, color: Color(0xFF2CF07F)),
          onTap: () {},
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 24.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.exit_to_app, color: Colors.black),
        label: const Text('Logout', style: TextStyle(color: Colors.black)),
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
          backgroundColor: const Color(0xFF2CF07F),
          minimumSize: const Size(double.infinity, 50), // Set the button's size
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final cred = EmailAuthProvider.credential(
          email: user!.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);

        // Password changed successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the ChangePasswordScreen
      } catch (e) {
        // Handle error (e.g., incorrect password, weak password)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: $e'),
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
        title: const Text(
            'Change Password', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        iconTheme: ThemeData().iconTheme.copyWith(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  // Add password strength validation if needed
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text(
                  'Change Password',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CF07F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileField extends StatefulWidget {
  final String field;
  final String initialValue;

  const EditProfileField({
    super.key,
    required this.field,
    required this.initialValue,
  });

  @override
  State<EditProfileField> createState() => _EditProfileFieldState();
}

class _EditProfileFieldState extends State<EditProfileField> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('users')
            .doc(user?.email)
            .update({
          widget.field: _controller.text,
        });

        // Update successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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
        title: Text(
            'Edit ${widget.field}', style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        iconTheme: ThemeData().iconTheme.copyWith(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                style: const TextStyle(color: Colors.black),
                // Text color for user input
                decoration: InputDecoration(
                  labelText: 'Enter new ${widget.field}',
                  labelStyle: const TextStyle(
                    color: Colors.black, // Label text color
                    fontSize: 24,
                    fontWeight: FontWeight.bold,// Increased font size for label
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                      0xFF2CF07F), // Green background for button
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                      color: Colors.black), // Text color for button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
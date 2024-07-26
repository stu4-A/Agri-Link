import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agriclink/pages/my_details_page.dart';
import 'dart:typed_data'; // Import this for Uint8List
import 'package:agriclink/pages/chat_list_page.dart';
import 'package:agriclink/pages/my_products_page.dart';
import 'package:agriclink/pages/login_page.dart';
import 'package:agriclink/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? _profileImageUrl;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profileImageUrl'] ?? null;
          _username =
              userDoc['username'] ?? "No Name"; // Ensure the correct field name
        });
      }
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = '${user!.uid}.jpg';

        if (fileBytes != null) {
          // Upload image to Firebase Storage
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child(fileName);
          await ref.putData(fileBytes);

          // Get the download URL
          final url = await ref.getDownloadURL();
          setState(() {
            _profileImageUrl = url;
          });

          // Save the URL in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'profileImageUrl': url});
        }
      }
    } catch (e) {
      print('Failed to pick and upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 15),
          child: GestureDetector(
            onTap: _pickAndUploadImage,
            child: CircleAvatar(
              radius: 62,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
                child: _profileImageUrl == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            _username ?? "No Name",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Center(
          child: Text(
            user?.email ?? "No Email",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        ListTile(
          title: const Text("My details"),
          leading: const Icon(IconlyLight.profile),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyDetailsPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text("Chat List"),
          leading: const Icon(IconlyLight.chat),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatListPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text("My Products"),
          leading: const Icon(IconlyLight.document),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyProductsPage(),
              ),
            );
          },
        ),
        SwitchListTile(
          title: const Text("Dark Mode"),
          secondary: const Icon(Icons.nights_stay),
          value: Provider.of<ThemeProvider>(context).currentTheme ==
              ThemeMode.dark,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
        ListTile(
          title: const Text("Logout"),
          leading: const Icon(IconlyLight.logout),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

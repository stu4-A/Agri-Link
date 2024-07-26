import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MyDetailsPage extends StatefulWidget {
  const MyDetailsPage({super.key});

  @override
  _MyDetailsPageState createState() => _MyDetailsPageState();
}

class _MyDetailsPageState extends State<MyDetailsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _otherNamesController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _surnameController.text = userDoc['surname'] ?? '';
          _otherNamesController.text = userDoc['otherNames'] ?? '';
          _countryController.text = userDoc['country'] ?? '';
          _contactController.text = userDoc['contact'] ?? '';
          _usernameController.text = userDoc['username'] ?? '';
          _locationController.text = userDoc['location'] ?? '';
          _locationLinkController.text = userDoc['locationLink'] ?? '';
          _productsController.text = userDoc['products'] ?? '';
          _profileImageUrl = userDoc['profileImageUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (user == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'surname': _surnameController.text.trim(),
        'otherNames': _otherNamesController.text.trim(),
        'country': _countryController.text.trim(),
        'contact': _contactController.text.trim(),
        'username': _usernameController.text.trim(),
        'location': _locationController.text.trim(),
        'locationLink': _locationLinkController.text.trim(),
        'products': _productsController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details updated successfully')),
      );
    } catch (e) {
      print('Failed to save user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user details')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);

        // Upload image to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user!.uid}.jpg');
        await ref.putFile(file);

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
    } catch (e) {
      print('Failed to pick and upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Details"),
        actions: [
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveUserData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/default_profile.jpg')
                                  as ImageProvider,
                          child: _profileImageUrl == null
                              ? const Icon(Icons.camera_alt, size: 30)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_surnameController, "Surname"),
                    _buildTextField(_otherNamesController, "Other Names"),
                    _buildTextField(_countryController, "Country"),
                    _buildTextField(_contactController, "Contact"),
                    _buildTextField(_usernameController, "Username"),
                    _buildTextField(_locationController, "Location"),
                    _buildTextField(_locationLinkController, "Location Link"),
                    _buildTextField(_productsController, "Products"),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _otherNamesController.dispose();
    _countryController.dispose();
    _contactController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    _locationLinkController.dispose();
    _productsController.dispose();
    super.dispose();
  }
}

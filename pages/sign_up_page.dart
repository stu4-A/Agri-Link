import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController otherNamesController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController locationLinkController = TextEditingController();
  final TextEditingController productsController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedCategory;

  final List<String> categories = [
    'Animals',
    'Animal Feeds',
    'Vegetables',
    'Fruits',
    'Machinery',
    'Hire Worker',
    'Seeds',
    'Poultry',
    'Others',
  ];

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'surname': surnameController.text.trim(),
        'otherNames': otherNamesController.text.trim(),
        'country': countryController.text.trim(),
        'contact': contactController.text.trim(),
        'email': emailController.text.trim(),
        'username': usernameController.text.trim(),
        'location': locationController.text.trim(),
        'locationLink': locationLinkController.text.trim(),
        'products': productsController.text.trim().isEmpty
            ? null
            : productsController.text.trim(),
        'category': selectedCategory,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            TextField(
              controller: otherNamesController,
              decoration: const InputDecoration(labelText: 'Other Name(s)'),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Paste Google Maps link here',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: locationLinkController,
              decoration:
                  const InputDecoration(labelText: 'Location Link (URL)'),
            ),
            TextField(
              controller: productsController,
              decoration:
                  const InputDecoration(labelText: 'Products (optional)'),
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signUp,
              icon: const Icon(IconlyLight.addUser),
              label: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

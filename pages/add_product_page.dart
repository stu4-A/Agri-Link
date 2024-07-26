import 'dart:io';
import 'dart:typed_data'; // Import this library for Uint8List
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _category = '';
  String _itemName = '';
  double _itemPrice = 0.0;
  String _description = '';
  File? _imageFile;
  Uint8List? _webImage; // This stores the image bytes for web
  double _itemQuantity = 0.0;

  final List<String> _categories = [
    'Animal feeds',
    'Animals',
    'Fruits',
    'Hire worker',
    'Machinery',
    'Others',
    'Poultry',
    'Seedlings',
    'Vegetables',
  ];

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _webImage = result.files.first.bytes;
          });
        } else {
          setState(() {
            _imageFile = File(result.files.single.path!);
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate() &&
        (_imageFile != null || _webImage != null)) {
      _formKey.currentState!.save();

      try {
        String imageUrl = '';
        String itemId =
            FirebaseFirestore.instance.collection('products').doc().id;
        String userId = FirebaseAuth.instance.currentUser!.uid;

        if (kIsWeb) {
          // Upload image to Firebase Storage for web
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef =
              FirebaseStorage.instance.ref().child('products/$fileName');
          SettableMetadata metadata =
              SettableMetadata(contentType: 'image/jpeg');
          UploadTask uploadTask = storageRef.putData(_webImage!, metadata);

          // Monitor the upload process
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            print('Task state: ${snapshot.state}'); // paused, running, complete
            print(
                'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
          });

          await uploadTask;
          imageUrl = await storageRef.getDownloadURL();
        } else {
          // Upload image to Firebase Storage for mobile
          String fileName = _imageFile!.path.split('/').last;
          Reference storageRef =
              FirebaseStorage.instance.ref().child('products/$fileName');
          SettableMetadata metadata =
              SettableMetadata(contentType: 'image/jpeg');
          UploadTask uploadTask = storageRef.putFile(_imageFile!, metadata);

          // Monitor the upload process
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            print('Task state: ${snapshot.state}'); // paused, running, complete
            print(
                'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
          });

          await uploadTask;
          imageUrl = await storageRef.getDownloadURL();
        }

        print('Image uploaded to Firebase Storage: $imageUrl');

        // Save product details to Firestore under the products collection with document ID as itemId
        await FirebaseFirestore.instance
            .collection('products')
            .doc(itemId)
            .set({
          'category': _category,
          'itemId': itemId,
          'itemName': _itemName,
          'itemPrice': _itemPrice,
          'description': _description,
          'imageUrl': imageUrl,
          'itemQuantity': _itemQuantity,
          'userId': userId, // Add the user ID
        });

        print('Product details saved under products collection');

        // Show success message and reset form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          _webImage = null;
        });
      } catch (e) {
        print("Error uploading product: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload product: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form and pick an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _category.isEmpty ? null : _category,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item quantity';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemQuantity = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemPrice = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 20),
              if (_webImage != null || _imageFile != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: kIsWeb
                          ? MemoryImage(_webImage!) as ImageProvider
                          : FileImage(_imageFile!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('No image selected')),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Image from Gallery'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:agriclink/models/product.dart';
import 'dart:typed_data';

// Ensure this import matches where flutterLocalNotificationsPlugin is defined
import 'package:agriclink/main.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Product>> getProducts() async {
    List<Product> allProducts = [];
    try {
      QuerySnapshot productsSnapshot = await _db.collection('products').get();
      for (var productDoc in productsSnapshot.docs) {
        allProducts.add(Product.fromFirestore(productDoc));
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return allProducts;
  }

  Future<List<Product>> getProductsByCategory(String? category) async {
    List<Product> filteredProducts = [];
    try {
      QuerySnapshot productsSnapshot;
      if (category == null || category.isEmpty) {
        productsSnapshot = await _db.collection('products').get();
      } else {
        productsSnapshot = await _db
            .collection('products')
            .where('category', isEqualTo: category)
            .get();
      }
      for (var productDoc in productsSnapshot.docs) {
        filteredProducts.add(Product.fromFirestore(productDoc));
      }
    } catch (e) {
      print('Error fetching products by category: $e');
    }
    return filteredProducts;
  }

  Future<List<Product>> searchProducts(String query) async {
    List<Product> searchResults = [];
    try {
      String capitalizedQuery = query.substring(0, 1).toUpperCase() +
          query.substring(1).toLowerCase();
      QuerySnapshot productsSnapshot = await _db
          .collection('products')
          .where('itemName', isGreaterThanOrEqualTo: capitalizedQuery)
          .where('itemName', isLessThanOrEqualTo: capitalizedQuery + '\uf8ff')
          .get();
      for (var productDoc in productsSnapshot.docs) {
        searchResults.add(Product.fromFirestore(productDoc));
      }
    } catch (e) {
      print('Error searching products: $e');
    }
    return searchResults;
  }

  Future<void> createOrderNotification(
      String orderId, String customerName) async {
    final notification = {
      'title': 'New Order',
      'body': 'You have a new order from $customerName',
      'orderId': orderId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    try {
      await _db.collection('notifications').add(notification);
      print('Order notification created for $orderId');
    } catch (e) {
      print('Error creating order notification: $e');
    }
  }

  Future<void> createMessageNotification(
      String messageId, String senderName) async {
    final notification = {
      'title': 'New Message',
      'body': 'You have a new message from $senderName',
      'messageId': messageId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    try {
      await _db.collection('notifications').add(notification);
      print('Message notification created for $messageId');
      _showLocalNotification(
          notification['title'] as String?, notification['body'] as String?);
    } catch (e) {
      print('Error creating message notification: $e');
    }
  }

  void _showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('message_channel', 'Message Notifications',
            channelDescription: 'Notifications for new messages',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'No Title',
      body ?? 'No Body',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> setProfileImage(String userId, Uint8List imageData) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.putData(imageData);
      final url = await ref.getDownloadURL();
      await _db
          .collection('users')
          .doc(userId)
          .update({'profileImageUrl': url});
      print('Profile image set for user $userId');
    } catch (e) {
      print('Error setting profile image: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }
}

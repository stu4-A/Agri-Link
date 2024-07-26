import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String category;
  final String itemId;
  final String itemName;
  final double itemPrice;
  final String description;
  final String imageUrl;
  final double itemQuantity;
  final String userId;

  Product({
    required this.category,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.description,
    required this.imageUrl,
    required this.itemQuantity,
    required this.userId,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError("Missing data for product: ${doc.id}");
    }

    return Product(
      category: data['category'] ?? '',
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      itemPrice: (data['itemPrice'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      itemQuantity: (data['itemQuantity'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'description': description,
      'imageUrl': imageUrl,
      'itemQuantity': itemQuantity,
      'userId': userId,
    };
  }
}

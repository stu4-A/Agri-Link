import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(category)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No products found in this category.'));
          }

          final products = snapshot.data!.docs.map((doc) {
            return Product.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.imageUrl),
                title: Text(product.itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: \$${product.itemPrice}'),
                    Text(
                        'Quantity: ${product.itemQuantity}'), // Display item quantity
                    Text('Description: ${product.description}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

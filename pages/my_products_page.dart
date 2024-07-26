import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriclink/models/product.dart'; // Ensure the path is correct
import 'package:agriclink/pages/add_product_page.dart'; // Ensure the path is correct
import 'package:agriclink/widgets/product_card.dart'; // Ensure the path is correct

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  Future<List<Product>> _fetchUserProducts(String userId) async {
    List<Product> userProducts = [];

    QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();

    for (var productDoc in productsSnapshot.docs) {
      userProducts.add(Product.fromFirestore(productDoc));
    }

    return userProducts;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["Available", "Add New"];
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Products"),
          bottom: TabBar(
            physics: const BouncingScrollPhysics(),
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: List.generate(tabs.length, (index) {
              return Tab(
                text: tabs[index],
              );
            }),
          ),
        ),
        body: TabBarView(
          children: [
            // Available Products Tab
            FutureBuilder<List<Product>>(
              future: _fetchUserProducts(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                return GridView.builder(
                  itemCount: snapshot.data!.length,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return ProductCard(product: product);
                  },
                );
              },
            ),
            // Add New Product Tab
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductPage()),
                  );
                },
                child: const Text('Add New Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

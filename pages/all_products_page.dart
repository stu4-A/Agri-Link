import 'package:flutter/material.dart';
import 'package:agriclink/models/product.dart';
import 'package:agriclink/widgets/product_card.dart';
import 'package:agriclink/services/firestore_service.dart';

class AllProductsPage extends StatefulWidget {
  final String? category;

  const AllProductsPage({super.key, this.category});

  @override
  _AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  late Future<List<Product>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts =
        FirestoreService().getProductsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? "All Products"),
      ),
      body: FutureBuilder<List<Product>>(
        future: _filteredProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error loading products: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

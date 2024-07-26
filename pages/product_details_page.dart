import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'chat_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.category,
    required this.productId,
  });

  final String category;
  final String productId;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late TapGestureRecognizer readMoreGestureRecognizer;
  bool showMore = false;
  late Future<Product> productFuture;
  String farmLocation = '';
  String locationLink = '';

  @override
  void initState() {
    super.initState();
    readMoreGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          showMore = !showMore;
        });
      };
    productFuture = fetchProduct();
  }

  Future<Product> fetchProduct() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    Product product = Product.fromFirestore(doc);
    await fetchFarmDetails(product.userId);
    return product;
  }

  Future<void> fetchFarmDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          farmLocation = userDoc['location'] ?? 'No location provided';
          locationLink = userDoc['locationLink'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching farm details: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    readMoreGestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(IconlyLight.bookmark),
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Product not found.'));
          }

          Product product = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                product.itemName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available in stock",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "shs${product.itemPrice.toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.titleLarge),
                        TextSpan(
                            text: "/${product.itemQuantity}",
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton.filledTonal(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      iconSize: 18,
                      icon: const Icon(Icons.remove),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "2 ${product.itemQuantity}",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton.filledTonal(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      iconSize: 18,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Description",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: showMore
                          ? product.description
                          : '${product.description.length > 100 ? product.description.substring(0, 100) : product.description}...',
                    ),
                    TextSpan(
                      recognizer: readMoreGestureRecognizer,
                      text: showMore ? " Read less" : " Read more",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (farmLocation.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Farm Location: $farmLocation",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (locationLink.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (await canLaunch(locationLink)) {
                            await launch(locationLink);
                          } else {
                            print('Could not launch $locationLink');
                          }
                        },
                        icon: const Icon(IconlyLight.location),
                        label: const Text("Location on Map"),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  String chatId =
                      'chat_${product.itemId}_${DateTime.now().millisecondsSinceEpoch}';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              chatId: chatId,
                              productOwnerId: product.userId,
                            )),
                  );
                },
                icon: const Icon(IconlyLight.chat),
                label: const Text("Chat"),
              ),
            ],
          );
        },
      ),
    );
  }
}

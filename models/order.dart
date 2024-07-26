import 'package:agriclink/models/product.dart'; // Adjust the import as per your actual path

class Order {
  final String id;
  final List<Product> products;
  final DateTime date;

  Order({
    required this.id,
    required this.products,
    required this.date,
  });
}

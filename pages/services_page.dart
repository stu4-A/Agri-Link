import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agriclink/pages/all_products_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: services.length,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllProductsPage(
                    category: services[index].name,
                  ),
                ),
              );
            },
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(services[index].image),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      services[index].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Service {
  final String name;
  final String image;

  const Service({required this.name, required this.image});
}

List<Service> services = [
  const Service(
    name: "Seedlings",
    image: "assets/services/seedlings.jpg",
  ),
  const Service(
    name: "Machinery",
    image: "assets/services/machinery.jpg",
  ),
  const Service(
    name: "Hire worker",
    image: "assets/services/workers.jpg",
  ),
  const Service(
    name: "Vegetables",
    image: "assets/services/cultivation.jpg",
  ),
  const Service(
    name: "Animal feeds",
    image: "assets/services/animalfeeds.png",
  ),
  const Service(
    name: "Animals",
    image: "assets/services/Farmanimals.jpg",
  ),
  const Service(
    name: "Fruits",
    image: "assets/services/fruits.jpg",
  ),
  const Service(
    name: "Poultry",
    image: "assets/services/Poultry.jpg",
  ),
  const Service(
    name: "Others",
    image: "assets/services/plussign.jpg",
  ),
];

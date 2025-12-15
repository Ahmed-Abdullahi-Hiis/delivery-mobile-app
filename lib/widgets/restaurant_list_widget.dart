import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_model.dart';
import '../providers/cart_provider.dart';
import 'custom_button.dart';

class RestaurantListWidget extends StatelessWidget {
  final List<RestaurantModel> restaurants;

  const RestaurantListWidget({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const Center(child: Text("No restaurants found"));
    }

    return ListView.builder(
      padding: EdgeInsets.zero, // 🔥 VERY IMPORTANT
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏪 Restaurant image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.asset(
                      restaurant.image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.black.withOpacity(0.55),
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🍽 Menu items
            ...restaurant.menu.map((food) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      food.image,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("Ksh ${food.price.toStringAsFixed(0)}"),
                  trailing: CustomButton(
                    text: 'Add',
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .addItem(food);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

 import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import 'menu_screen.dart';

class RestaurantScreen extends StatelessWidget {
  final RestaurantModel restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(restaurant.image, width: double.infinity, height: 180, fit: BoxFit.cover),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(restaurant.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MenuScreen(restaurant: restaurant)),
                );
              },
              child: const Text('View Menu'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class FoodDetailsScreen extends StatelessWidget {
  final FoodModel food;
  const FoodDetailsScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: Column(
        children: [
          Image.asset( // Use Image.asset since your images are local assets
            food.image,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Ksh ${food.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                const Text('Delicious and fresh. Add special instructions below.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    cart.addItem(food); // ✅ corrected method
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

 import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'food_details_screen.dart';

class MenuScreen extends StatelessWidget {
  final RestaurantModel restaurant;
  const MenuScreen({super.key, required this.restaurant});

  // mock menu (replace with real data)
  List<FoodModel> get sampleMenu => [
        FoodModel(id: 'f1', name: 'Chicken Burger', price: 450.0, image: 'https://via.placeholder.com/120'),
        FoodModel(id: 'f2', name: 'French Fries', price: 120.0, image: 'https://via.placeholder.com/120'),
        FoodModel(id: 'f3', name: 'Coke', price: 80.0, image: 'https://via.placeholder.com/120'),
      ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('${restaurant.name} — Menu')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: sampleMenu.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final f = sampleMenu[i];
          return ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailsScreen(food: f))),
            leading: Image.network(f.image, width: 56, height: 56, fit: BoxFit.cover),
            title: Text(f.name),
            subtitle: Text('Ksh ${f.price.toStringAsFixed(0)}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                cart.addToCart(f);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
              },
            ),
          );
        },
      ),
    );
  }
}

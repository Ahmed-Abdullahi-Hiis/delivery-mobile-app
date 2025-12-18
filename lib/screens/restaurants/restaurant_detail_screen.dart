import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  static const route = '/restaurant-details';
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.restaurant.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                restaurant.name,
                style: const TextStyle(fontWeight: FontWeight.bold, shadows: [
                  Shadow(blurRadius: 8, color: Colors.black),
                ]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(restaurant.image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                    restaurant.isFavorite = isFavorite;
                  });
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(restaurant.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(restaurant.deliveryTime),
                  const Spacer(),
                  if (restaurant.freeDelivery)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        'FREE DELIVERY',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final food = restaurant.menu[index];
                return _FoodTile(food: food);
              },
              childCount: restaurant.menu.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final FoodModel food;
  const _FoodTile({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(food.image, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(food.name),
        subtitle: Text('KES ${food.price}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            cart.addItem(food);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${food.name} added to cart'), duration: const Duration(seconds: 1)),
            );
          },
        ),
      ),
    );
  }
}

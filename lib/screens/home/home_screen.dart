import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/food_categories_widget.dart';
import '../../widgets/restaurant_carousel_widget.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  static const route = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample restaurants
    final List<RestaurantModel> sampleRestaurants = [
      RestaurantModel(
        id: 'r1',
        name: "Mama's Kitchen",
        image: 'assets/images/mama-kitchen.jpeg',
        menu: [
          FoodModel(id: 'f1', name: 'Sushi Platter', price: 500, image: 'assets/images/sushi.jpg'),
          FoodModel(id: 'f2', name: 'Pasta Alfredo', price: 250, image: 'assets/images/pasta.jpeg'),
        ],
      ),
      RestaurantModel(
        id: 'r2',
        name: 'Sambusa House',
        image: 'assets/images/sambus.jpeg',
        menu: [
          FoodModel(id: 'f3', name: 'Somali Rice', price: 300, image: 'assets/images/Somali-Rice-1.jpg'),
          FoodModel(id: 'f4', name: 'Meat Curry', price: 100, image: 'assets/images/meat.jpeg'),
        ],
      ),
      RestaurantModel(
        id: 'r3',
        name: 'Liver Onion Spice',
        image: 'assets/images/liver-onions-2.jpg',
        menu: [
          FoodModel(id: 'f5', name: 'Anjera Somali', price: 350, image: 'assets/images/Anjera.jpg'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, CartScreen.route);
                  },
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        cart.items.length.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 🍕 Food categories
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FoodCategoriesWidget(),
              ),
            ),

            // 📺 Promo carousel (auto sliding)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RestaurantCarouselWidget(
                  restaurants: sampleRestaurants,
                ),
              ),
            ),

            // 📝 Restaurant list with small images + Add to Cart
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final restaurant = sampleRestaurants[index];
                  final firstMenuItem = restaurant.menu.first;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            restaurant.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.menu.map((f) => f.name).join(', '),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addItem(firstMenuItem);
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: sampleRestaurants.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

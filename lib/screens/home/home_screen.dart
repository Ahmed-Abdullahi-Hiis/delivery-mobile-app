// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../models/restaurant_model.dart';
// import '../../models/food_model.dart';
// import '../../providers/cart_provider.dart';
// import '../../providers/theme_provider.dart';
// import '../../widgets/restaurant_carousel_widget.dart';
// import '../../widgets/floating_cart_button.dart';
// import '../cart/cart_screen.dart';
// import '../restaurants/restaurant_detail_screen.dart';

// class HomeScreen extends StatefulWidget {
//   static const route = "/home";
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String _searchQuery = '';
//   bool _showFreeDeliveryOnly = false;

//   List<RestaurantModel> get _filteredRestaurants {
//     return _sampleRestaurants.where((r) {
//       // ✅ Fix: make sure freeDelivery is not null
//       final matchesFree = !_showFreeDeliveryOnly || (r.freeDelivery ?? false);
//       final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase());
//       return matchesFree && matchesSearch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final restaurants = _filteredRestaurants;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Food Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () => context.read<ThemeProvider>().toggleTheme(),
//             icon: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
//               child: Icon(
//                 context.watch<ThemeProvider>().isDark ? Icons.dark_mode : Icons.light_mode,
//                 key: ValueKey(context.watch<ThemeProvider>().isDark),
//               ),
//             ),
//           ),
//           Consumer<CartProvider>(
//             builder: (_, cart, __) => Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart_outlined),
//                   onPressed: () => Navigator.pushNamed(context, CartScreen.route),
//                 ),
//                 if (cart.totalItems > 0)
//                   Positioned(
//                     right: 6,
//                     top: 6,
//                     child: CircleAvatar(
//                       radius: 8,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         cart.totalItems.toString(),
//                         style: const TextStyle(fontSize: 10, color: Colors.white),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search restaurants or food",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) => setState(() => _searchQuery = value),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _showFreeDeliveryOnly,
//                         onChanged: (val) => setState(() => _showFreeDeliveryOnly = val ?? false),
//                       ),
//                       const Text("Show Free Delivery Only"),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: RestaurantCarouselWidget(restaurants: restaurants),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final restaurant = restaurants[index];
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           PageRouteBuilder(
//                             transitionDuration: const Duration(milliseconds: 300),
//                             pageBuilder: (_, __, ___) => RestaurantDetailScreen(restaurant: restaurant),
//                             transitionsBuilder: (_, animation, __, child) {
//                               return SlideTransition(
//                                 position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 4,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Hero(
//                               tag: restaurant.id,
//                               child: ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                                 child: Image.asset(
//                                   restaurant.image,
//                                   height: 160,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       restaurant.name,
//                                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   if (restaurant.freeDelivery ?? false)
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: Colors.green.withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Text(
//                                         "Free Delivery",
//                                         style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: restaurants.length,
//                 ),
//               ),
//             ],
//           ),
//           const Positioned(left: 0, right: 0, bottom: 0, child: FloatingCartButton()),
//         ],
//       ),
//     );
//   }
// }

// /// ===============================
// /// SAMPLE RESTAURANTS
// /// ===============================
// final List<RestaurantModel> _sampleRestaurants = [
//   RestaurantModel(
//     id: 'r1',
//     name: "Mama's Kitchen",
//     image: 'assets/images/mama-kitchen.jpeg',
//     freeDelivery: true,
//     menu: [
//       FoodModel(id: 'f1', name: 'Spicy Chicken', image: 'assets/images/spice.jpeg', price: 400),
//       FoodModel(id: 'f2', name: 'Burger', image: 'assets/images/burger.webp', price: 350),
//     ],
//     rating: 4.8,
//     deliveryTime: '30-40 min',
//     isFavorite: false,
//   ),
//   RestaurantModel(
//     id: 'r2',
//     name: 'Sambusa House',
//     image: 'assets/images/sambus.jpeg',
//     freeDelivery: false,
//     menu: [
//       FoodModel(id: 'f3', name: 'Sambusa', image: 'assets/images/sambus.jpeg', price: 100),
//       FoodModel(id: 'f4', name: 'Pizza', image: 'assets/images/pizza.jpeg', price: 450),
//     ],
//     rating: 4.5,
//     deliveryTime: '25-35 min',
//     isFavorite: false,
//   ),
// ];










import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/restaurant_carousel_widget.dart';
import '../../widgets/floating_cart_button.dart';
import '../cart/cart_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const route = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _showFreeDeliveryOnly = false;

  // Filter restaurants based on search & free delivery toggle
  List<RestaurantModel> get _filteredRestaurants {
    return _sampleRestaurants.where((r) {
      final matchesFree = !_showFreeDeliveryOnly || r.freeDelivery;
      final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFree && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = _filteredRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Food Delivery",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 🌙 Dark mode toggle
          IconButton(
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                context.watch<ThemeProvider>().isDark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                key: ValueKey(context.watch<ThemeProvider>().isDark),
              ),
            ),
          ),

          // 🛒 Cart icon with badge
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () =>
                      Navigator.pushNamed(context, CartScreen.route),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 🔍 Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search restaurants or food",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),

              // ✅ Free delivery toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showFreeDeliveryOnly,
                        onChanged: (val) =>
                            setState(() => _showFreeDeliveryOnly = val ?? false),
                      ),
                      const Text("Show Free Delivery Only"),
                    ],
                  ),
                ),
              ),

              // 📢 Restaurant carousel (optional widget)
              SliverToBoxAdapter(
                child: RestaurantCarouselWidget(restaurants: restaurants),
              ),

              // 🏪 Restaurant list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = restaurants[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 300),
                            pageBuilder: (_, __, ___) =>
                                RestaurantDetailScreen(restaurant: restaurant),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: restaurant.id,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.asset(
                                  restaurant.image,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (restaurant.freeDelivery)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Free Delivery",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: restaurants.length,
                ),
              ),
            ],
          ),

          // Floating cart button
          const Positioned(left: 0, right: 0, bottom: 0, child: FloatingCartButton()),
        ],
      ),
    );
  }
}

/// ===============================
/// SAMPLE RESTAURANTS
/// ===============================
final List<RestaurantModel> _sampleRestaurants = [
  RestaurantModel(
    id: 'r1',
    name: "Mama's Kitchen",
    image: 'assets/images/mama-kitchen.jpeg',
    freeDelivery: true,
    menu: [
      FoodModel(id: 'f1', name: 'Spicy Chicken', image: 'assets/images/spice.jpeg', price: 400),
      FoodModel(id: 'f2', name: 'Burger', image: 'assets/images/burger.webp', price: 350),
    ],
    rating: 4.8,
    deliveryTime: '30-40 min',
    isFavorite: false,
  ),
  RestaurantModel(
    id: 'r2',
    name: 'Sambusa House',
    image: 'assets/images/sambus.jpeg',
    freeDelivery: false,
    menu: [
      FoodModel(id: 'f3', name: 'Sambusa', image: 'assets/images/sambus.jpeg', price: 100),
      FoodModel(id: 'f4', name: 'Pizza', image: 'assets/images/pizza.jpeg', price: 450),
    ],
    rating: 4.5,
    deliveryTime: '25-35 min',
    isFavorite: false,
  ),
];

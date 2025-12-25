import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MyAuthProvider.dart';

import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/restaurant_carousel_widget.dart';
import '../../widgets/floating_cart_button.dart';
import '../cart/cart_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const route = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _freeDeliveryOnly = false;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Somali',
    'Fast Food',
    'Pizza',
    'Rice',
  ];

  final List<RestaurantModel> _sampleRestaurants = [
    RestaurantModel(
      id: 'r1',
      name: "Mama's Kitchen",
      image: 'assets/images/mama-kitchen.jpeg',
      freeDelivery: true,
      category: 'Somali',
      rating: 4.8,
      menu: [
        FoodModel(
          id: 'f1',
          name: 'Spicy Chicken',
          image: 'assets/images/spice.jpeg',
          price: 400,
        ),
      ],
    ),
    RestaurantModel(
      id: 'r2',
      name: 'Sambusa House',
      image: 'assets/images/sambus.jpeg',
      freeDelivery: false,
      category: 'Fast Food',
      rating: 4.5,
      menu: [
        FoodModel(
          id: 'f2',
          name: 'Sambusa',
          image: 'assets/images/sambus.jpeg',
          price: 100,
        ),
      ],
    ),
    RestaurantModel(
      id: 'r3',
      name: 'Pizza Palace',
      image: 'assets/images/pizza.jpeg',
      freeDelivery: true,
      category: 'Pizza',
      rating: 4.6,
      menu: [
        FoodModel(
          id: 'f3',
          name: 'Cheese Pizza',
          image: 'assets/images/pizza.jpeg',
          price: 500,
        ),
      ],
    ),
    RestaurantModel(
      id: 'r4',
      name: 'Rice & Curry',
      image: 'assets/images/Somali-Rice-1.jpg',
      freeDelivery: false,
      category: 'Rice',
      rating: 4.4,
      menu: [
        FoodModel(
          id: 'f4',
          name: 'Rice & Meat',
          image: 'assets/images/Somali-Rice-1.jpg',
          price: 400,
        ),
      ],
    ),
  ];

  List<RestaurantModel> get _filteredRestaurants {
    return _sampleRestaurants.where((r) {
      final matchesSearch =
          r.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFree = !_freeDeliveryOnly || r.freeDelivery;
      final matchesCategory =
          _selectedCategory == 0 || r.category == _categories[_selectedCategory];
      return matchesSearch && matchesFree && matchesCategory;
    }).toList();
  }

  void _openFAQs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("FAQs"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• How do I place an order?\nAdd food → Cart → Checkout.\n"),
            Text("• How do I pay?\nCash or mobile payment.\n"),
            Text("• Can I cancel an order?\nYes, before confirmation."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _openSupport() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Text(
          "📱 WhatsApp: +254 796 739 051\n"
          "📧 Email: ahmedabdullahihiis@gmail.com\n\n"
          "We are available 24/7 to assist you.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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
  IconButton(
    onPressed: () => context.read<ThemeProvider>().toggleTheme(),
    icon: Icon(
      context.watch<ThemeProvider>().isDark
          ? Icons.dark_mode
          : Icons.light_mode,
    ),
  ),

  // PROFILE AVATAR
  Consumer<MyAuthProvider>(
    builder: (context, auth, _) {
      return GestureDetector(
        onTap: () {
          if (auth.isLoggedIn) {
            // Navigate to profile if logged in
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            // Navigate to login if not logged in
            Navigator.pushNamed(context, '/login'); // make sure you have a login route
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orange,
            child: Text(
              (auth.user?.displayName ?? "U")[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    },
  ),

  // CART ICON
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
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
  ),
],





//         actions: [
//           IconButton(
//             onPressed: () => context.read<ThemeProvider>().toggleTheme(),
//             icon: Icon(
//               context.watch<ThemeProvider>().isDark
//                   ? Icons.dark_mode
//                   : Icons.light_mode,
//             ),
//           ),

//           /// PROFILE (ONLY ADDITION)
//           // IconButton(
//           //   icon: const Icon(Icons.person_outline),
//           //   onPressed: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (_) => const ProfileScreen(),
//           //       ),
//           //     );
//           //   },
//           // ),

//           Consumer<MyAuthProvider>(
//   builder: (context, auth, _) {
//     if (!auth.isLoggedIn) return const SizedBox.shrink();

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const ProfileScreen(),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: CircleAvatar(
//           radius: 16,
//           backgroundColor: Colors.orange,
//           // child: Text(
//           //   auth.user!.name[0].toUpperCase(),
//           //   style: const TextStyle(
//           //     color: Colors.white,
//           //     fontWeight: FontWeight.bold,

//           child: Text(
//   (auth.user?.displayName ?? "U")[0].toUpperCase(),
//   style: const TextStyle(
//     color: Colors.white,
//     fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   },
// ),


//           Consumer<CartProvider>(
//             builder: (_, cart, __) => Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart_outlined),
//                   onPressed: () =>
//                       Navigator.pushNamed(context, CartScreen.route),
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
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search restaurants",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final selected = i == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.orange
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _categories[i],
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _freeDeliveryOnly,
                        onChanged: (v) =>
                            setState(() => _freeDeliveryOnly = v ?? false),
                      ),
                      const Text("Free delivery only"),
                    ],
                  ),
                ),
              ),

              if (restaurants.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                      RestaurantCarouselWidget(restaurants: restaurants),
                ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Popular Restaurants",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = restaurants[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          restaurant.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        restaurant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(restaurant.rating.toString()),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailScreen(
                                restaurant: restaurant),
                          ),
                        );
                      },
                    );
                  },
                  childCount: restaurants.length,
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: _openFAQs,
                            child: const Text("FAQs"),
                          ),
                          TextButton(
                            onPressed: _openSupport,
                            child: const Text("Help & Support"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "📱 +254 796 739 051 | 📧 ahmedabdullahihiis@gmail.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Afro Delivery",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "© 2025 Afro Delivery. All rights reserved.",
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingCartButton(),
          ),
        ],
      ),
    );
  }
}










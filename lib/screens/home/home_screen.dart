
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../models/restaurant_model.dart';
// import '../../models/food_model.dart';
// import '../../providers/cart_provider.dart';
// import '../../providers/theme_provider.dart';
// import '../../providers/favorite_provider.dart';
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
//   bool _freeDeliveryOnly = false;
//   int _selectedCategory = 0;

//   final List<String> _categories = [
//     'All',
//     'Somali',
//     'Fast Food',
//     'Pizza',
//     'Rice',
//   ];

//   List<RestaurantModel> get _filteredRestaurants {
//     return _sampleRestaurants.where((r) {
//       final matchesSearch =
//           r.name.toLowerCase().contains(_searchQuery.toLowerCase());

//       final matchesFree = !_freeDeliveryOnly || r.freeDelivery;

//       final matchesCategory = _selectedCategory == 0 ||
//           r.category == _categories[_selectedCategory];

//       return matchesSearch && matchesFree && matchesCategory;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final restaurants = _filteredRestaurants;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Food Delivery",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         actions: [
//           /// THEME TOGGLE
//           IconButton(
//             onPressed: () => context.read<ThemeProvider>().toggleTheme(),
//             icon: Icon(
//               context.watch<ThemeProvider>().isDark
//                   ? Icons.dark_mode
//                   : Icons.light_mode,
//             ),
//           ),

//           /// CART ICON
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
//                             fontSize: 10, color: Colors.white),
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
//               /// SEARCH
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search restaurants",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (v) => setState(() => _searchQuery = v),
//                   ),
//                 ),
//               ),

//               /// CATEGORIES
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height: 45,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: _categories.length,
//                     itemBuilder: (_, i) {
//                       final selected = i == _selectedCategory;
//                       return GestureDetector(
//                         onTap: () => setState(() => _selectedCategory = i),
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 10),
//                           padding:
//                               const EdgeInsets.symmetric(horizontal: 18),
//                           decoration: BoxDecoration(
//                             color: selected
//                                 ? Colors.orange
//                                 : Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             _categories[i],
//                             style: TextStyle(
//                               color:
//                                   selected ? Colors.white : Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),

//               /// FREE DELIVERY FILTER
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _freeDeliveryOnly,
//                         onChanged: (v) =>
//                             setState(() => _freeDeliveryOnly = v ?? false),
//                       ),
//                       const Text("Free delivery only"),
//                     ],
//                   ),
//                 ),
//               ),

//               /// CAROUSEL (SAFE)
//               if (restaurants.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: RestaurantCarouselWidget(
//                     restaurants: restaurants,
//                   ),
//                 ),

//               /// EMPTY STATE
//               if (restaurants.isEmpty)
//                 const SliverFillRemaining(
//                   child: Center(
//                     child: Text(
//                       "No restaurants found 🍽️",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 )

//               /// RESTAURANT LIST
//               else
//                 SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final restaurant = restaurants[index];

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => RestaurantDetailScreen(
//                                   restaurant: restaurant),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           margin: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 4,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Hero(
//                                 tag: restaurant.id,
//                                 child: ClipRRect(
//                                   borderRadius:
//                                       const BorderRadius.vertical(
//                                           top: Radius.circular(12)),
//                                   child: Image.asset(
//                                     restaurant.image,
//                                     height: 160,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         restaurant.name,
//                                         style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                     Consumer<FavoriteProvider>(
//                                       builder: (_, fav, __) => IconButton(
//                                         icon: Icon(
//                                           restaurant.isFavorite
//                                               ? Icons.favorite
//                                               : Icons.favorite_border,
//                                           color: restaurant.isFavorite
//                                               ? Colors.red
//                                               : Colors.grey,
//                                         ),
//                                         onPressed: () =>
//                                             fav.toggleFavorite(restaurant),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (restaurant.freeDelivery)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 12, bottom: 12),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color:
//                                           Colors.green.withOpacity(0.15),
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                     ),
//                                     child: const Text(
//                                       "Free Delivery",
//                                       style: TextStyle(
//                                           color: Colors.green,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: restaurants.length,
//                   ),
//                 ),
//             ],
//           ),

//           /// FLOATING CART
//           const Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: FloatingCartButton(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// SAMPLE DATA (ALL CATEGORIES INCLUDED)
// final List<RestaurantModel> _sampleRestaurants = [
//   RestaurantModel(
//     id: 'r1',
//     name: "Mama's Kitchen",
//     image: 'assets/images/mama-kitchen.jpeg',
//     freeDelivery: true,
//     category: 'Somali',
//     menu: [
//       FoodModel(
//           id: 'f1',
//           name: 'Spicy Chicken',
//           image: 'assets/images/spice.jpeg',
//           price: 400),
//     ],
//     rating: 4.8,
//   ),
//   RestaurantModel(
//     id: 'r2',
//     name: 'Sambusa House',
//     image: 'assets/images/sambus.jpeg',
//     freeDelivery: false,
//     category: 'Fast Food',
//     menu: [
//       FoodModel(
//           id: 'f2',
//           name: 'Sambusa',
//           image: 'assets/images/sambus.jpeg',
//           price: 100),
//     ],
//     rating: 4.5,
//   ),
//   RestaurantModel(
//     id: 'r3',
//     name: 'Pizza Palace',
//     image: 'assets/images/pizza.jpeg',
//     freeDelivery: true,
//     category: 'Pizza',
//     menu: [
//       FoodModel(
//           id: 'f3',
//           name: 'Cheese Pizza',
//           image: 'assets/images/pizza.jpeg',
//           price: 500),
//     ],
//     rating: 4.6,
//   ),
//   RestaurantModel(
//     id: 'r4',
//     name: 'Rice & Curry',
//     image: 'assets/images/Somali-Rice-1.jpg',
//     freeDelivery: false,
//     category: 'Rice',
//     menu: [
//       FoodModel(
//           id: 'f4',
//           name: 'Rice & Meat',
//           image: 'assets/images/Somali-Rice-1.jpg',
//           price: 400),
//     ],
//     rating: 4.4,
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

  /// SUPPORT DIALOG
  void _openSupport() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Text(
          "Need help?\n\n"
          "📧 Email: support@fooddelivery.app\n"
          "⏰ Available 24/7\n\n"
          "We usually respond within a few hours.",
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
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              /// SEARCH
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

              /// CATEGORIES
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
                            color:
                                selected ? Colors.orange : Colors.grey.shade300,
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

              /// FREE DELIVERY
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

              /// CAROUSEL
              if (restaurants.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                      RestaurantCarouselWidget(restaurants: restaurants),
                ),

              /// POPULAR TITLE
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

              /// COMPACT PROFESSIONAL LIST
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
                          if (restaurant.freeDelivery) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.delivery_dining,
                                color: Colors.green, size: 18),
                          ],
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

              /// FAQs
              const SliverToBoxAdapter(
                child: ExpansionTile(
                  leading: Icon(Icons.help_outline),
                  title: Text("FAQs"),
                  children: [
                    ListTile(
                      title: Text("How do I place an order?"),
                      subtitle:
                          Text("Choose food → add to cart → checkout."),
                    ),
                    ListTile(
                      title: Text("How do I pay?"),
                      subtitle:
                          Text("Cash on delivery or mobile payment."),
                    ),
                    ListTile(
                      title: Text("Can I cancel an order?"),
                      subtitle:
                          Text("Yes, before the restaurant confirms."),
                    ),
                  ],
                ),
              ),

              /// HELP & SUPPORT
              SliverToBoxAdapter(
                child: ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text("Help & Support"),
                  subtitle: const Text("Ask questions or contact us"),
                  onTap: _openSupport,
                ),
              ),

              /// FOOTER
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Divider(),
                      Text(
                        "© 2025 Food Delivery App",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// FLOATING CART
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

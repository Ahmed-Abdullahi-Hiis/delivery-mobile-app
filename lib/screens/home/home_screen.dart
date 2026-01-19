import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/MyAuthProvider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';

import '../../widgets/floating_cart_button.dart';
import '../../widgets/firestore_restaurant_carousel.dart';

import '../cart/cart_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../profile/profile_screen.dart';

// INFO PAGES
import '../info/faq_screen.dart';
import '../info/about_screen.dart';
import '../info/contact_screen.dart';
import '../info/privacy_screen.dart';
import '../info/terms_and_conditions_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<MyAuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Afro Delivery 🍔",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: theme.toggleTheme,
          ),
          GestureDetector(
            onTap: () {
              if (auth.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  (auth.user?.displayName ?? "U")[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, CartScreen.route),
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
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("restaurants")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              final allRestaurants = docs
                  .map((e) => e.data() as Map<String, dynamic>)
                  .toList();

              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final category = (data['category'] ?? '').toString();
                final free = data['freeDelivery'] == true;

                final matchSearch = name.contains(_searchQuery.toLowerCase());
                final matchFree = !_freeDeliveryOnly || free;
                final matchCategory = _selectedCategory == 0 ||
                    category.toLowerCase() ==
                        _categories[_selectedCategory].toLowerCase();

                return matchSearch && matchFree && matchCategory;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 🔥 CAROUSEL
                  FirestoreRestaurantCarousel(
                    restaurants: allRestaurants.take(6).toList(),
                  ),

                  const SizedBox(height: 16),

                  // SEARCH
                  TextField(
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

                  const SizedBox(height: 16),

                  // CATEGORIES
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final selected = i == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color:
                                  selected ? Colors.orange : Colors.grey[300],
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[i],
                              style: TextStyle(
                                color:
                                    selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: _freeDeliveryOnly,
                        onChanged: (v) =>
                            setState(() => _freeDeliveryOnly = v ?? false),
                      ),
                      const Text("Free delivery only"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (filteredDocs.isEmpty)
                    const Center(child: Text("No restaurants found 😢")),

                  ...filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(data['name']),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(data['rating'].toString()),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailScreen(
                                restaurantId: doc.id,
                                restaurantName: data['name'],
                                imageUrl: data['imageUrl'],
                                rating: (data['rating'] as num).toDouble(),
                                freeDelivery: data['freeDelivery'] == true,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 40),
                  const Divider(),

                  // FOOTER
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _footerLink(context, "FAQ"),
                            _footerLink(context, "About"),
                            _footerLink(context, "Contact"),
                            _footerLink(context, "Privacy Policy"),
                            _footerLink(context, "Terms"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "© 2026 Afro Delivery · All rights reserved",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            },
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

  static Widget _footerLink(BuildContext context, String title) {
    Widget page;
    switch (title) {
      case "FAQ":
        page = const FaqScreen();
        break;
      case "About":
        page = const AboutScreen();
        break;
      case "Contact":
        page = const ContactScreen();
        break;
      case "Privacy Policy":
        page = const PrivacyScreen();
        break;
      default:
        page = const TermsAndConditionsScreen();
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

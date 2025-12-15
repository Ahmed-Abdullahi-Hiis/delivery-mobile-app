import 'package:flutter/material.dart';

class FoodCategoriesWidget extends StatelessWidget {
  const FoodCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        "name": "Pizza",
        "image": "assets/images/pizza.jpeg",
      },
      {
        "name": "Burger",
        "image": "assets/images/burger.webp", // replace with real asset
      },
      {
        "name": "Sushi",
        "image": "assets/images/sushi.jpg", // replace with real asset
      },
    ];

    return SizedBox(
      height: 100, // height of the category row
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  item['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 4),
              Text(item['name']!),
            ],
          );
        },
      ),
    );
  }
}

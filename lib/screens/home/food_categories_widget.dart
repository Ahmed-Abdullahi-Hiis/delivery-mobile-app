 import 'package:flutter/material.dart';

class FoodCategoriesWidget extends StatelessWidget {
  const FoodCategoriesWidget({super.key});

  final categories = const [
    'All',
    'Pizza',
    'Burgers',
    'Sushi',
    'Dessert',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          return Chip(label: Text(c));
        },
      ),
    );
  }
}

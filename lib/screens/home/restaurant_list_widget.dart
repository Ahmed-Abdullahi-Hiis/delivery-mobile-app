 import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../restaurants/restaurant_screen.dart';

class RestaurantListWidget extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  const RestaurantListWidget({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const Center(child: Text('No restaurants found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, index) {
        final r = restaurants[index];
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantScreen(restaurant: r),
            ),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(r.image, width: 64, height: 64, fit: BoxFit.cover),
          ),
          title: Text(r.name),
          subtitle: const Text('30-40 min • Ksh 120 delivery'),
          trailing: const Icon(Icons.chevron_right),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: restaurants.length,
    );
  }
}

import 'food_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final List<FoodModel> menu;

  final double rating;
  final String deliveryTime;
  final bool freeDelivery;
  bool isFavorite;

  final String category; // ✅ NEW

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.menu,
    required this.category, // ✅ REQUIRED
    this.rating = 4.5,
    this.deliveryTime = '30–40 min',
    this.freeDelivery = false,
    this.isFavorite = false,
  });
}

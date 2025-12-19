import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<RestaurantModel> _favorites = [];

  List<RestaurantModel> get favorites => _favorites;

  bool isFavorite(RestaurantModel restaurant) {
    return _favorites.contains(restaurant);
  }

  void toggleFavorite(RestaurantModel restaurant) {
    if (_favorites.contains(restaurant)) {
      _favorites.remove(restaurant);
      restaurant.isFavorite = false;
    } else {
      _favorites.add(restaurant);
      restaurant.isFavorite = true;
    }
    notifyListeners();
  }
}

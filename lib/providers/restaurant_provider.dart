 import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';

class RestaurantProvider extends ChangeNotifier {
  final List<RestaurantModel> _restaurants = [];

  List<RestaurantModel> get restaurants => _restaurants;

  void setRestaurants(List<RestaurantModel> list) {
    _restaurants.clear();
    _restaurants.addAll(list);
    notifyListeners();
  }
}

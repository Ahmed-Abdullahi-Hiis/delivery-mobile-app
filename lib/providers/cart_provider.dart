 import 'package:flutter/material.dart';
import '../models/food_model.dart';

class CartProvider extends ChangeNotifier {
  final List<FoodModel> _items = [];

  List<FoodModel> get items => _items;

  void addItem(FoodModel food) {
    _items.add(food);
    notifyListeners();
  }

  void removeItem(FoodModel food) {
    _items.remove(food);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  int get itemCount => _items.length;
}

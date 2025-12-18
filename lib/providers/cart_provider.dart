import 'package:flutter/material.dart';
import '../models/food_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + (item.food.price * item.quantity));

  void addItem(FoodModel food) {
    if (_items.containsKey(food.id)) {
      _items[food.id]!.quantity++;
    } else {
      _items[food.id] = CartItem(food: food);
    }
    notifyListeners();
  }

  void decreaseItem(String foodId) {
    if (!_items.containsKey(foodId)) return;

    if (_items[foodId]!.quantity > 1) {
      _items[foodId]!.quantity--;
    } else {
      _items.remove(foodId);
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final FoodModel food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

 import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/food_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void addOrder({
    required List<FoodModel> items,
    required double totalAmount,
  }) {
    _orders.insert(
      0,
      OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        items: items,
        totalAmount: totalAmount,
      ),
    );
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}

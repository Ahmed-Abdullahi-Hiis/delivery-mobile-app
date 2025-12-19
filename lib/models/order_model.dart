 import 'food_model.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final List<FoodModel> items;
  final double totalAmount;
  final String status; // Pending, Completed, Cancelled

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.status = 'Completed',
  });
}

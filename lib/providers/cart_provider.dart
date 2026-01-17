






// import 'package:flutter/material.dart';
// import '../models/food_model.dart';

// class CartProvider extends ChangeNotifier {
//   final Map<String, CartItem> _items = {};

//   Map<String, CartItem> get items => _items;

//   int get totalItems =>
//       _items.values.fold(0, (sum, item) => sum + item.quantity);

//   double get totalPrice => _items.values.fold(
//       0, (sum, item) => sum + (item.price * item.quantity));

//   // ================= OLD METHOD (FOR LOCAL MODELS) =================
//   void addItem(FoodModel food) {
//     if (_items.containsKey(food.id)) {
//       _items[food.id]!.quantity++;
//     } else {
//       _items[food.id] = CartItem(
//         id: food.id,
//         name: food.name,
//         price: food.price.toDouble(),
//         imageUrl: food.image,
//       );
//     }
//     notifyListeners();
//   }

//   // ================= NEW METHOD (FOR FIRESTORE FOODS) =================
//   void addItemFromFirestore(Map<String, dynamic> food, String foodId) {
//     if (_items.containsKey(foodId)) {
//       _items[foodId]!.quantity++;
//     } else {
//       _items[foodId] = CartItem(
//         id: foodId,
//         name: food['name'],
//         price: (food['price'] as num).toDouble(),
//         imageUrl: food['imageUrl'],
//       );
//     }
//     notifyListeners();
//   }

//   void decreaseItem(String foodId) {
//     if (!_items.containsKey(foodId)) return;

//     if (_items[foodId]!.quantity > 1) {
//       _items[foodId]!.quantity--;
//     } else {
//       _items.remove(foodId);
//     }
//     notifyListeners();
//   }

//   void removeItem(String foodId) {
//     _items.remove(foodId);
//     notifyListeners();
//   }

//   void clearCart() {
//     _items.clear();
//     notifyListeners();
//   }
// }

// // ================= CART ITEM =================
// class CartItem {
//   final String id;
//   final String name;
//   final double price;
//   final String imageUrl;
//   int quantity;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     this.quantity = 1,
//   });
// }
    




import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // ✅ Add item from Firestore food
  void addItemFromFirestore({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  // ✅ Add item from cart itself ( + button )
  void addItemFromCartItem(CartItem item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity++;
    } else {
      _items[item.id] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void decreaseItem(String id) {
    if (!_items.containsKey(id)) return;

    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

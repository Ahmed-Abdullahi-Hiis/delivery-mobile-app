 import 'dart:async';
import 'package:flutter/material.dart';

import '../models/restaurant_model.dart';

class RestaurantCarouselWidget extends StatefulWidget {
  final List<RestaurantModel> restaurants;

  const RestaurantCarouselWidget({super.key, required this.restaurants});

  @override
  State<RestaurantCarouselWidget> createState() =>
      _RestaurantCarouselWidgetState();
}

class _RestaurantCarouselWidgetState
    extends State<RestaurantCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage =
            (_currentPage + 1) % widget.restaurants.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = widget.restaurants[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.asset(
                    restaurant.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withOpacity(0.55),
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

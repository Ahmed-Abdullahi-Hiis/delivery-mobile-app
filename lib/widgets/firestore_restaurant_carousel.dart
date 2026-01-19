 import 'dart:async';
import 'package:flutter/material.dart';

class FirestoreRestaurantCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;

  const FirestoreRestaurantCarousel({
    super.key,
    required this.restaurants,
  });

  @override
  State<FirestoreRestaurantCarousel> createState() =>
      _FirestoreRestaurantCarouselState();
}

class _FirestoreRestaurantCarouselState
    extends State<FirestoreRestaurantCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients && widget.restaurants.isNotEmpty) {
        _page = (_page + 1) % widget.restaurants.length;
        _controller.animateToPage(
          _page,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurants.isEmpty) return const SizedBox();

    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.restaurants.length,
        itemBuilder: (context, index) {
          final r = widget.restaurants[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(
                    r['imageUrl'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      r['name'],
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

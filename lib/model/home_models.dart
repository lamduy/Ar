import 'package:flutter/material.dart';

class ProductArrival {
  final String name;
  final String edition;
  final double price;
  final Color color;

  const ProductArrival({
    required this.name,
    required this.edition,
    required this.price,
    required this.color,
  });
}

class HomeCategory {
  final String name;
  final IconData icon;

  const HomeCategory({required this.name, required this.icon});
}

import 'package:flutter/material.dart';

class Product {
  final String name;
  final String edition;
  final double price;
  final Color color;

  const Product({
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

import 'package:flutter/material.dart';
import 'package:world_casa/model/home_models.dart';

class ProductHomeViewModel extends ChangeNotifier {
  final List<Product> _arrivals = const [
    Product(
      name: 'The Aurelius Armchair',
      edition: 'COGNAC LEATHER EDITION',
      price: 1240.00,
      color: Color(0xFF9E3A2B),
    ),
    Product(
      name: 'Luna Coffee Table',
      edition: 'NATURAL STONE EDITION',
      price: 890.00,
      color: Color(0xFF2F3E33),
    ),
    Product(
      name: 'Luna Coffee Table1',
      edition: 'NATURAL STONE EDITION',
      price: 890.00,
      color: Color.fromARGB(255, 133, 10, 37),
    ),
    Product(
      name: 'Luna Coffee Table2',
      edition: 'NATURAL STONE EDITION',
      price: 890.00,
      color: Color.fromARGB(255, 228, 228, 228),
    ),
    Product(
      name: 'Luna Coffee Table3',
      edition: 'NATURAL STONE EDITION',
      price: 890.00,
      color: Color.fromARGB(255, 223, 105, 105),
    ),
    Product(
      name: 'Luna Coffee Table4',
      edition: 'NATURAL STONE EDITION',
      price: 890.00,
      color: Color.fromARGB(255, 153, 184, 161),
    ),
  ];

  final List<HomeCategory> _categories = const [
    HomeCategory(name: 'SEATING', icon: Icons.chair_outlined),
    HomeCategory(name: 'TABLES', icon: Icons.table_restaurant_outlined),
    HomeCategory(name: 'LIGHTING', icon: Icons.lightbulb_outline),
    HomeCategory(name: 'DECOR', icon: Icons.inventory),
    HomeCategory(name: 'STORAGE', icon: Icons.shelves),
    HomeCategory(name: 'BEDROOM', icon: Icons.bed_outlined),
    HomeCategory(name: 'OUTDOOR', icon: Icons.deck_outlined),
    HomeCategory(name: 'KITCHEN', icon: Icons.kitchen_outlined),
  ];

  int _selectedIndex = -1;

  List<Product> get arrivals => List.unmodifiable(_arrivals);
  List<HomeCategory> get categories => List.unmodifiable(_categories);
  int get selectedIndex => _selectedIndex;

  Product? get selectedProduct {
    if (_selectedIndex < 0 || _selectedIndex >= _arrivals.length) {
      return null;
    }
    return _arrivals[_selectedIndex];
  }

  void selectProduct(int index) {
    if (index < 0 || index >= _arrivals.length) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  void onViewAllTapped() {
    debugPrint('View all tapped');
  }
}

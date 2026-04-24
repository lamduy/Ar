import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        iconTheme: const IconThemeData(color: Color(0xFF7D4F4A)),
        centerTitle: true,
      ),
      body: Center(
        // Center này sẽ căn giữa Column vào giữa màn hình
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

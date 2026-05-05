import 'package:flutter/material.dart';
import 'package:world_casa/views/widgets/RoomCategoryCard.dart';

class ShopByRoomScreen extends StatelessWidget {
  const ShopByRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop by Room',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RoomCategoryCard(
                  title: 'Bedroom',
                  imageUrl: 'assets/banner_home.jpg',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RoomCategoryCard(
                  title: 'Office',
                  imageUrl: 'assets/banner_home.jpg',
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          RoomCategoryCard(
            title: 'Kitchen & Dining',
            imageUrl: 'assets/banner_home.jpg',
            aspectRatio: 2.0,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

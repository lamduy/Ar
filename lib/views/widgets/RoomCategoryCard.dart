import 'package:flutter/material.dart';

class RoomCategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final double aspectRatio; // Để điều chỉnh hình vuông hoặc chữ nhật

  const RoomCategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.aspectRatio = 1.0, // Mặc định là hình vuông
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            // 1. Hình nền
            Positioned.fill(child: Image.asset(imageUrl, fit: BoxFit.cover)),
            // 2. Chữ và đường gạch chân ở giữa
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40, // Độ dài đường gạch chân
                    height: 2,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

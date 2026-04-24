import 'package:flutter/material.dart';

class ProductItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ProductItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260, // Độ rộng cố định cho mỗi card khi lướt ngang
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Phần hình ảnh sản phẩm
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.chair_outlined,
                    size: 120,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 📝 Thông tin chữ
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif', // Tạo cảm giác cao cấp
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

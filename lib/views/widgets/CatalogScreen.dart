import 'package:flutter/material.dart';
import 'package:world_casa/views/widgets/ShopByRoomScreen.dart';
import 'package:world_casa/views/widgets/common_banner.dart';

class CataLogScreen extends StatelessWidget {
  const CataLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard way to handle the notch/status bar area
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: topPadding),

            // Search bar and category strip above banner
            _buildCatalogTopBar(),
            _buildCatalogCategories(),

            // Banner
            CommonBanner(
              imagePath: 'assets/banner_home.jpg',
              topLabel: 'THE CURATED ROOM',
              title: 'Quiet Luxury:\nThe Autumn\nEdit',
              buttonText: 'DISCOVERY THE COLLECTION',
              onButtonPressed: () {},
            ),

            // 🏷️ Header Section (Filters/Title)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: const ShopByRoomScreen(),
            ),

            // TODO: Add your Product Grid here
          ],
        ),
      ),
    );
  }
}

Widget _buildCatalogTopBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Search pieces or rooms',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: const Icon(Icons.tune, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Widget _buildCatalogCategories() {
  final categories = [
    _CatalogCategory(label: 'LIVING', icon: Icons.chair_alt),
    _CatalogCategory(label: 'DINING', icon: Icons.table_restaurant_outlined),
    _CatalogCategory(label: 'BEDROOM', icon: Icons.bed_outlined),
    _CatalogCategory(label: 'LIGHTING', icon: Icons.lightbulb_outline),
  ];

  return SizedBox(
    height: 100, // Giảm chiều cao tổng xuống vì không còn Spacer()
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          width: 80, // Thu nhỏ chiều rộng cho cân đối
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Thu gọn Column theo nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category.icon,
                  color: const Color(0xFF7D4F4A),
                  size: 24,
                ),
              ),
              // THAY THẾ Spacer() BẰNG KHOẢNG CÁCH CỐ ĐỊNH
              const SizedBox(height: 8),
              Text(
                category.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _CatalogCategory {
  final String label;
  final IconData icon;

  const _CatalogCategory({required this.label, required this.icon});
}

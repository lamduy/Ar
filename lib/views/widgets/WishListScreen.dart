import 'package:flutter/material.dart';
import 'package:world_casa/model/home_models.dart';

class WishListScreen extends StatelessWidget {
  const WishListScreen({super.key});

  final List<Product> _wishlistItems = const [
    Product(
      name: "CURVED BOUNCLE SOFA",
      edition: "Personal Curation Edition",
      price: 2450.00,
      color: Color(0xFFE5E5E5),
      image: 'assets/banner_home.jpg',
    ),
    Product(
      name: "ARCHITECTURAL ARMCHAIR",
      edition: "Limited Statement Series",
      price: 1800.00,
      color: Color(0xFFD4CFC9),
      image: 'assets/banner_home.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Nền sáng đặc trưng của Stitch
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PERSONAL CURATION",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Color(0xFF8C7355),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "WISHLIST",
                      style: TextStyle(
                        fontSize: 48,
                        fontFamily:
                            'Serif', // Nên dùng GoogleFonts.playfairDisplay
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(width: 45, height: 1, color: Colors.black),
                    const SizedBox(height: 24),
                    const Text(
                      "A curated selection of your most coveted pieces. These architectural statements are waiting to define your living space.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- PRODUCT LIST ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductItem(_wishlistItems[index]),
                  childCount: _wishlistItems.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khung ảnh sản phẩm
          AspectRatio(
            aspectRatio: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: product.color.withOpacity(
                  0.3,
                ), // Dùng màu từ class Product làm nền
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              child:
                  // Stack(
                  //   children: [
                  // Center(
                  //   child:
                  Image(
                    image: product.image.isNotEmpty
                        ? AssetImage(product.image)
                        : AssetImage('assets/placeholder.png'),
                    fit: BoxFit.cover,
                  ),
              //),
              // Nút xóa (Top Right)
              // Positioned(
              //   top: 16,
              //   right: 16,
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.close,
              //       size: 20,
              //       color: Colors.black,
              //     ),
              //     onPressed: () {},
              //   ),
              // ),
              // Nút AR (Bottom Right)
              // Positioned(
              //   bottom: 16,
              //   right: 16,
              //   child: FloatingActionButton.small(
              //     heroTag: product.name,
              //     elevation: 0,
              //     backgroundColor: Colors.black,
              //     child: const Icon(Icons.view_in_ar, color: Colors.white),
              //     onPressed: () {},
              //   ),
              // ),
              //],
            ),
          ),
          //),
          const SizedBox(height: 16),
          // Thông tin sản phẩm từ Class
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.edition,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

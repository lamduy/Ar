import 'package:flutter/material.dart';
import 'package:world_casa/model/home_models.dart';
import 'package:world_casa/view_model/product_home_viewmodel.dart';
import 'package:world_casa/views/widgets/ARScreen.dart';
import 'package:world_casa/views/widgets/common_banner.dart';
import 'package:world_casa/views/widgets/new_arrivals_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductHomeViewModel _productVM;

  @override
  void initState() {
    super.initState();
    _productVM = ProductHomeViewModel();
  }

  @override
  void dispose() {
    _productVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: _productVM,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: topPadding),
              CommonBanner(
                imagePath: 'assets/banner_home.jpg',
                onButtonPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ARScreen()),
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Categories',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: _productVM.onViewAllTapped,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'VIEW ALL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCategoryGrid(_productVM.categories),
              _buildNewArrivals(_productVM),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildNewArrivals(ProductHomeViewModel vm) {
  return NewArrivalsSection(items: vm.arrivals, onItemTap: vm.selectProduct);
}

Widget _buildCategoryGrid(List<HomeCategory> categories) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(20),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 15,
      childAspectRatio: 0.8,
    ),
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(
                  category.icon,
                  color: const Color(0xFF7D4F4A),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
        ],
      );
    },
  );
}

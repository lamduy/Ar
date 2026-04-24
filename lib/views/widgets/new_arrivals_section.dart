import 'package:flutter/material.dart';
import 'package:world_casa/model/home_models.dart';

class NewArrivalsSection extends StatelessWidget {
  final List<ProductArrival> items;
  final ValueChanged<int>? onItemTap;
  final String title;
  final String label;

  const NewArrivalsSection({
    super.key,
    required this.items,
    this.onItemTap,
    this.title = 'New Arrivals',
    this.label = 'CURATED OBJECTS',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 450,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => onItemTap?.call(index),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chair,
                              size: 150,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.edition,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

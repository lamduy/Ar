import 'package:flutter/material.dart';

class CommonBanner extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onButtonPressed;
  final String topLabel;
  final String title;
  final String buttonText;
  final double height;

  const CommonBanner({
    super.key,
    required this.imagePath,
    this.onButtonPressed,
    this.topLabel = 'NEW SEASON COLLECTION',
    this.title = 'Artisan\nCraftsmanship for\nModern Living',
    this.buttonText = 'AR Test',
    this.height = 550,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        Container(height: 400, color: Colors.black.withValues(alpha: 0.2)),
        Positioned(
          bottom: 40,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF7D4F4A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Color(0xFF7D4F4A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

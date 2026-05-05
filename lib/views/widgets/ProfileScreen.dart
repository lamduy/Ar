import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Màu nền hơi xám nhẹ
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Danh sách các tùy chọn
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(Icons.list_alt, 'My Orders'),
                _buildMenuItem(
                  Icons.location_on_outlined,
                  'Shipping Addresses',
                ),
                _buildMenuItem(Icons.credit_card, 'Payment Methods'),
                _buildMenuItem(Icons.palette_outlined, 'Style Preferences'),
                _buildMenuItem(Icons.notifications_none, 'Notifications'),
                _buildMenuItem(Icons.shield_outlined, 'Security & Privacy'),
              ],
            ),
          ),
          // Nút Sign Out ở dưới cùng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Text(
                'SIGN OUT',
                style: TextStyle(
                  color: Colors.redAccent,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600], size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF424242),
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFFEEEEEE),
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        onTap: () {
          // Xử lý điều hướng tại đây
        },
      ),
    );
  }
}

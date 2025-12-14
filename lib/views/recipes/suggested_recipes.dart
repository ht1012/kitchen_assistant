import 'package:flutter/material.dart';
class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
          ],
        ),
      ),
    );
  }
}
// Widget con: Header
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7BF1A8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.restaurant_menu, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gợi ý món ăn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Gợi ý cá nhân hóa dựa trên tủ đựng thức ăn của bạn',
          style: TextStyle(color: Color(0xFF495565), fontSize: 14),
        ),
      ],
    ),
  );
}

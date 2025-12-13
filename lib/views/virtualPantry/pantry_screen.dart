import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Kho nguyên liệu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Quản lý nguyên liệu của bạn',
              style: TextStyle(
                color: Color(0xFF697282),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


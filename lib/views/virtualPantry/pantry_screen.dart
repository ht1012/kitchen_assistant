import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== Nền Gradient =====
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kho nguyên liệu",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF101727)),
                ),
                SizedBox(height: 4),
                Text(
                  "Quản lý nguyên liệu của bạn",
                  style: TextStyle(
                      fontSize: 14.8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF697282)),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

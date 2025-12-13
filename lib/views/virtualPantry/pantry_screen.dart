import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  PantryPage({super.key});
  final List<Map<String, String>> fruits = [
    {
      "name": "Táo",
      "quantity": "6 quả",
      "expiry": "8/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "https://placehold.co/60x63"
    },
    {
      "name": "Chuối",
      "quantity": "10 quả",
      "expiry": "9/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "https://placehold.co/60x60"
    },
  ];

  final List<Map<String, String>> dairy = [
    {
      "name": "Sữa",
      "quantity": "6 L",
      "expiry": "8/12/2025",
      "status": "Sắp hết hạn",
      "color": "0xFFA65F00",
      "image": "https://placehold.co/60x57"
    },
    {
      "name": "Trứng",
      "quantity": "6 quả",
      "expiry": "6/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "https://placehold.co/60x59"
    },
    {
      "name": "Sữa chua",
      "quantity": "500g",
      "expiry": "5/12/2025",
      "status": "Hết hạn",
      "color": "0xFFC10007",
      "image": "https://placehold.co/60x56"
    },
  ];

  final List<Map<String, String>> meatAndFish = [
    {
      "name": "Thịt bò",
      "quantity": "500g",
      "expiry": "10/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "https://placehold.co/60x60"
    },
    {
      "name": "Cá hồi",
      "quantity": "300g",
      "expiry": "9/12/2025",
      "status": "Sắp hết hạn",
      "color": "0xFFA65F00",
      "image": "https://placehold.co/60x60"
    },
  ];

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
                Row(
                  children: const [
                    _StatusCard(
                      count: '6',
                      label: 'Tươi',
                      bgColor: Colors.white,
                      textColor: Color(0xFF00A63D),
                    ),
                    SizedBox(width: 12),
                    _StatusCard(
                      count: '2',
                      label: 'Sắp hết hạn',
                      bgColor: Color(0xFFFDFBE8),
                      textColor: Color(0xFFD08700),
                    ),
                    SizedBox(width: 12),
                    _StatusCard(
                      count: '1',
                      label: 'Hết hạn',
                      bgColor: Color(0xFFFEF2F2),
                      textColor: Color(0xFFE7000A),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String count;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: TextStyle(fontSize: 24, color: textColor)),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF495565)),
            ),
          ],
        ),
      ),
    );
  }
}

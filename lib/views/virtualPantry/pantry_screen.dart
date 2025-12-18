import 'package:flutter/material.dart';
import 'add_ingredients.dart';
class PantryPage extends StatelessWidget {
  const PantryPage({super.key});
  static const List<Map<String, String>> fruits = [
    {
      "name": "Táo",
      "quantity": "6 quả",
      "expiry": "8/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "assets/images/tao.png"
    },
  ];

  static const List<Map<String, String>> dairy = [
    {
      "name": "Sữa",
      "quantity": "6 L",
      "expiry": "8/12/2025",
      "status": "Sắp hết hạn",
      "color": "0xFFA65F00",
      "image": "assets/images/sua.png"
    },
    {
      "name": "Trứng",
      "quantity": "6 quả",
      "expiry": "6/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "assets/images/trung.png"
    },
    {
      "name": "Sữa chua",
      "quantity": "500g",
      "expiry": "5/12/2025",
      "status": "Hết hạn",
      "color": "0xFFC10007",
      "image": "assets/images/suachua.png"
    },
  ];
  static const List<Map<String, String>> meatAndFish = [
    {
      "name": "Thịt gà",
      "quantity": "500g",
      "expiry": "10/12/2025",
      "status": "Tươi",
      "color": "0xFF008235",
      "image": "assets/images/thitga.png"
    },
    {
      "name": "Cá hồi",
      "quantity": "300g",
      "expiry": "9/12/2025",
      "status": "Sắp hết hạn",
      "color": "0xFFA65F00",
      "image": "assets/images/cahoi.png"
    },
  ];

  Widget ingredientSection(BuildContext context,String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF101727)),
        ),
        SizedBox(height: 12),
        Column(
          children: items.map((item) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddIngredientPage(
                    ingredientData: item, // ⭐ TRUYỀN DỮ LIỆU
                  ),
                ),
              );
            },
            child: IngredientCard(
              name: item['name']!,
              quantity: item['quantity']!,
              expiry: item['expiry']!,
              status: item['status']!,
              color: Color(int.parse(item['color']!)),
              image: item['image']!,
            ),
          )).toList(),
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7BF1A8),
        shape: const CircleBorder(), 
          child: const Icon(
            Icons.add,
            color: Colors.white, 
            size: 28,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddIngredientPage(),
            ),
          );
        },
      ),
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
                ingredientSection(context,"Quả & rau", fruits),
                ingredientSection(context,"Trứng & Sữa", dairy),
                ingredientSection(context,"Thịt & Cá", meatAndFish),
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
class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String expiry;
  final String status;
  final Color color;
  final String image;

  IngredientCard({
    required this.name,
    required this.quantity,
    required this.expiry,
    required this.status,
    required this.color,
    required this.image,
  });

  Color getBackgroundColor() {
    switch (status) {
      case 'Tươi':
        return Color(0xFFEFFAF1); // xanh nhạt
      case 'Sắp hết hạn':
        return Color(0xFFFFFBE8); // vàng nhạt
      case 'Hết hạn':
        return Color(0xFFFFF2F2); // đỏ nhạt
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      height: 76,
      decoration: BoxDecoration(
        color: getBackgroundColor(), // dùng màu nền theo status
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14.8, color: Color(0xFF101727))),
                Text(status, style: TextStyle(fontSize: 10, color: color)),
                Text("Số lượng: $quantity", style: TextStyle(fontSize: 10, color: Color(0xFF495565))),
                Text("Hạn sử dụng: $expiry", style: TextStyle(fontSize: 10, color: Color(0xFF495565))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

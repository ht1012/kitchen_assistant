import 'package:flutter/material.dart';
import 'package:kitchen_assistant/views/recipes/suggested_recipes.dart';
import '../widgets/bottom_nav.dart';
import '../notification/notification.dart';
import '../shoppingList/shopping_list.dart';
import '../mealPlanner/meal_planner.dart';

import '../virtualPantry/pantry_screen.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}
  
class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children:  [
          _HomePage(),        // Trang chủ
          PantryPage(),      // Kho
          ShoppingPage(),    // Mua sắm
          PlanPage(),        // Kế hoạch
          NotificationPage() // Thông báo
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao của phần tai thỏ (top padding)
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDF4), Colors.white], // Màu nền đồng nhất
        ),
      ),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 16),
          children: const [
            _Header(),
            SizedBox(height: 16),
            _IngredientStatus(),
            SizedBox(height: 24),
            _SuggestSection(),
          ],
        ),
      )
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // quan trọng
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/img_cook.png',
            width: 65,
            height: 65,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bếp Nhà Trang',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075B33),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text(
                      'Mã: 24356182',
                      style: TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.copy, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: const [
              Icon(Icons.logout, size: 20, color: Color(0xFF075B33)),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Color(0xFF075B33),
                  fontSize: 10,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}


class _IngredientStatus extends StatelessWidget {
  const _IngredientStatus();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng nguyên liệu',
          style: TextStyle(fontSize: 14, color: Color(0xFF697282)),
        ),
        const SizedBox(height: 12),
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

class _SuggestSection extends StatelessWidget {
  const _SuggestSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SuggestHeader(),
        SizedBox(height: 12),
        _RecipeCard(title: 'Salad', time: '15 min'),
        SizedBox(height: 12),
        _RecipeCard(title: 'Mỳ Ý kem', time: '15 min'),
      ],
    );
  }
}

class _SuggestHeader extends StatelessWidget {
  const _SuggestHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bạn muốn nấu gì hôm nay?',
          style: TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
          builder: (context) => Recipes(),
          fullscreenDialog: false,
            ),
        );
          },
          child: Text(
        'Các gợi ý khác',
          style: TextStyle(
          color: Color(0xFF00C850),
          fontWeight: FontWeight.w700,
          ),
          ),
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final String time;

  const _RecipeCard({
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2F4F6)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/img_fresh_garden_salad.png',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(time,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF697282))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

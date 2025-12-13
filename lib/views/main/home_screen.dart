import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

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
        children: const [
          _HomePage(),        // Trang chủ
          _PantryPage(),      // Kho
          _ShoppingPage(),    // Mua sắm
          _PlanPage(),        // Kế hoạch
          _NotificationPage() // Thông báo
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
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDF4), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _Header(),
            SizedBox(height: 16),
            _IngredientStatus(),
            SizedBox(height: 24),
            _SuggestSection(),
          ],
        ),
      ),
    );
  }
}


class _PantryPage extends StatelessWidget {
  const _PantryPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Màn hình Kho', style: TextStyle(fontSize: 22)),
    );
  }
}

class _ShoppingPage extends StatelessWidget {
  const _ShoppingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mua sắm', style: TextStyle(fontSize: 22)),
    );
  }
}

class _PlanPage extends StatelessWidget {
  const _PlanPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Kế hoạch', style: TextStyle(fontSize: 22)),
    );
  }
}

class _NotificationPage extends StatelessWidget {
  const _NotificationPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Thông báo', style: TextStyle(fontSize: 22)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/img_cook.png',
          width: 77,
          height: 73,
        ),
        const SizedBox(width: 12),
        const Text(
          'Chào buổi sáng',
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFF075B33),
          ),
        ),
      ],
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
      children: const [
        Text(
          'Bạn muốn nấu gì hôm nay?',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Các gợi ý khác',
          style: TextStyle(
            color: Color(0xFF00C850),
            fontWeight: FontWeight.w700,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
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

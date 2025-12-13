import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              //_SuggestSection(),
            ],
          ),
        ),
      )
      //bottomNavigationBar: _BottomNav(),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({super.key});

  @override
  State<_Header> createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
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
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF697282),
          ),
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
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF495565),
              ),
            ),
          ],
        ),
      ),
    );
  }
}